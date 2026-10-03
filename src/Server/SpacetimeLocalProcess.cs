using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;

namespace Server;

internal sealed class SpacetimeLocalProcess : IDisposable
{
    private static readonly Regex DatabaseNamePattern =
        new("^[a-z0-9]+(-[a-z0-9]+)*$", RegexOptions.Compiled | RegexOptions.CultureInvariant);

    private readonly ServerSettings _settings;
    private readonly Action<string> _log;
    private Process? _process;
    private bool _startedByServer;

    public SpacetimeLocalProcess(ServerSettings settings, Action<string> log)
    {
        _settings = settings;
        _log = log;
    }

    public async Task<bool> EnsureStartedAsync(
        Func<CancellationToken, Task> pingAsync,
        CancellationToken cancellationToken)
    {
        if (await CanPingAsync(pingAsync, cancellationToken).ConfigureAwait(false))
        {
            _log("SpacetimeDB is already running.");
            return true;
        }

        if (!_settings.AutoStartSpacetimeDb)
        {
            _log("SpacetimeDB auto-start is disabled.");
            return false;
        }

        if (!TryGetLocalEndpoint(out string listenAddress))
        {
            _log($"SpacetimeDB auto-start skipped because {_settings.SpacetimeUri} is not a local endpoint.");
            return false;
        }

        string? cliPath = ResolveCliPath();
        if (cliPath is null)
        {
            _log("Unable to find the SpacetimeDB CLI. Set SpacetimeCliPath in appsettings.json or install 'spacetime' in PATH.");
            return false;
        }

        try
        {
            var start = CreateProcessStartInfo(cliPath, AppContext.BaseDirectory);
            start.ArgumentList.Add("start");
            start.ArgumentList.Add("--listen-addr");
            start.ArgumentList.Add(listenAddress);

            _process = new Process { StartInfo = start, EnableRaisingEvents = true };
            _process.OutputDataReceived += (_, e) =>
            {
                if (!string.IsNullOrWhiteSpace(e.Data))
                    _log($"[SpacetimeDB] {e.Data}");
            };
            _process.ErrorDataReceived += (_, e) =>
            {
                if (!string.IsNullOrWhiteSpace(e.Data))
                    _log($"[SpacetimeDB] {e.Data}");
            };
            if (!_process.Start())
            {
                _log("SpacetimeDB could not be started.");
                return false;
            }

            _startedByServer = true;
            _process.BeginOutputReadLine();
            _process.BeginErrorReadLine();
            _log($"Starting local SpacetimeDB on {listenAddress} using {cliPath}...");
        }
        catch (Exception ex)
        {
            _log($"Unable to launch the SpacetimeDB CLI. ({ex.Message})");
            return false;
        }

        int timeoutSeconds = Math.Max(1, _settings.SpacetimeStartupTimeoutSeconds);
        DateTime deadline = DateTime.UtcNow.AddSeconds(timeoutSeconds);

        while (DateTime.UtcNow < deadline && !cancellationToken.IsCancellationRequested)
        {
            if (await CanPingAsync(pingAsync, cancellationToken).ConfigureAwait(false))
            {
                _log("SpacetimeDB is ready.");
                return true;
            }

            if (_process is { HasExited: true })
            {
                int exitCode = _process.ExitCode;

                // Another SpacetimeDB process may have won the startup race and
                // acquired spacetime.pid between our initial ping and the CLI start.
                // Give that process a brief grace period to finish binding the port.
                if (await WaitForPingAsync(
                        pingAsync,
                        TimeSpan.FromSeconds(2),
                        cancellationToken).ConfigureAwait(false))
                {
                    _startedByServer = false;
                    _log("SpacetimeDB is ready (another local instance won the startup race).");
                    return true;
                }

                _log($"SpacetimeDB process exited with code {exitCode} before the endpoint became ready.");
                return false;
            }

            try
            {
                await Task.Delay(250, cancellationToken).ConfigureAwait(false);
            }
            catch (OperationCanceledException)
            {
                return false;
            }
        }

        _log($"SpacetimeDB did not become ready within {timeoutSeconds} seconds.");
        return false;
    }

    public async Task<bool> EnsureDatabaseAsync(
        Func<CancellationToken, Task<bool>> databaseExistsAsync,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(_settings.SpacetimeDatabase))
        {
            _log("SpacetimeDatabase is empty; database bootstrap was skipped.");
            return false;
        }

        if (!DatabaseNamePattern.IsMatch(_settings.SpacetimeDatabase))
        {
            _log($"Spacetime database name '{_settings.SpacetimeDatabase}' is invalid. Use lowercase letters/numbers with optional single dashes.");
            return false;
        }

        try
        {
            if (await databaseExistsAsync(cancellationToken).ConfigureAwait(false))
            {
                _log($"SpacetimeDB database '{_settings.SpacetimeDatabase}' already exists.");
                return true;
            }
        }
        catch (Exception ex)
        {
            _log($"Could not check whether database '{_settings.SpacetimeDatabase}' exists. ({LeafMessage(ex)})");
            return false;
        }

        if (!_settings.AutoCreateSpacetimeDatabase)
        {
            _log($"SpacetimeDB database '{_settings.SpacetimeDatabase}' does not exist and automatic creation is disabled.");
            return false;
        }

        string? cliPath = ResolveCliPath();
        if (cliPath is null)
        {
            _log($"Cannot create database '{_settings.SpacetimeDatabase}' because the SpacetimeDB CLI was not found. Set SpacetimeCliPath.");
            return false;
        }

        string moduleDirectory = ResolveModuleDirectory();
        if (!Directory.Exists(moduleDirectory))
        {
            _log($"Cannot create database '{_settings.SpacetimeDatabase}': module directory not found at '{moduleDirectory}'. Set SpacetimeModulePath.");
            return false;
        }

        string? dotnetPath = ResolveDotNetPath();
        if (dotnetPath is null)
        {
            _log("Cannot publish the SpacetimeDB C# module because dotnet was not found. Set SpacetimeDotNetPath or install the .NET 10 SDK.");
            return false;
        }

        if (!await HasDotNet10SdkAsync(dotnetPath, cancellationToken).ConfigureAwait(false))
        {
            _log($"Cannot publish database '{_settings.SpacetimeDatabase}': the .NET 10 SDK was not found by '{dotnetPath}'. Install a .NET 10 SDK or set SpacetimeDotNetPath to the correct dotnet executable.");
            return false;
        }

        EnsureModuleGlobalJson(moduleDirectory);
        _log($"Creating SpacetimeDB database '{_settings.SpacetimeDatabase}' from module '{moduleDirectory}' using .NET 10...");

        try
        {
            string? wasmPath = await BuildModuleWasmAsync(
                dotnetPath,
                moduleDirectory,
                cancellationToken).ConfigureAwait(false);

            if (wasmPath is null)
            {
                _log("SpacetimeDB module build failed; database was not created.");
                return false;
            }

            _log($"Publishing compiled SpacetimeDB module '{wasmPath}' as database '{_settings.SpacetimeDatabase}'...");

            using var publish = new Process
            {
                StartInfo = CreateProcessStartInfo(cliPath, moduleDirectory),
                EnableRaisingEvents = false
            };

            ConfigureDotNetEnvironment(publish.StartInfo, dotnetPath);

            publish.StartInfo.ArgumentList.Add("publish");
            publish.StartInfo.ArgumentList.Add(_settings.SpacetimeDatabase);
            publish.StartInfo.ArgumentList.Add("--server");
            publish.StartInfo.ArgumentList.Add(_settings.SpacetimeUri);
            publish.StartInfo.ArgumentList.Add("--bin-path");
            publish.StartInfo.ArgumentList.Add(wasmPath);
            publish.StartInfo.ArgumentList.Add("--yes=all");
            publish.StartInfo.ArgumentList.Add("--no-config");

            if (!publish.Start())
            {
                _log("SpacetimeDB publish process could not be started.");
                return false;
            }

            Task<string> stdout = publish.StandardOutput.ReadToEndAsync(cancellationToken);
            Task<string> stderr = publish.StandardError.ReadToEndAsync(cancellationToken);
            await publish.WaitForExitAsync(cancellationToken).ConfigureAwait(false);

            string outText = await stdout.ConfigureAwait(false);
            string errText = await stderr.ConfigureAwait(false);

            foreach (string line in SplitLines(outText))
                _log($"[SpacetimeDB publish] {line}");
            foreach (string line in SplitLines(errText))
                _log($"[SpacetimeDB publish] {line}");

            if (publish.ExitCode != 0)
            {
                _log($"SpacetimeDB database creation failed with exit code {publish.ExitCode}.");
                return false;
            }

            bool exists = await WaitForDatabaseAsync(databaseExistsAsync, cancellationToken).ConfigureAwait(false);
            if (exists)
            {
                _log($"SpacetimeDB database '{_settings.SpacetimeDatabase}' is ready.");
                return true;
            }

            _log($"SpacetimeDB publish completed, but database '{_settings.SpacetimeDatabase}' could not be confirmed.");
            return false;
        }
        catch (OperationCanceledException)
        {
            return false;
        }
        catch (Exception ex)
        {
            _log($"Unable to create SpacetimeDB database '{_settings.SpacetimeDatabase}'. ({LeafMessage(ex)})");
            return false;
        }
    }

    public async Task<string?> TryGetCliAuthTokenAsync(CancellationToken cancellationToken)
    {
        string? cliPath = ResolveCliPath();
        if (cliPath is null)
            return null;

        try
        {
            using var process = new Process
            {
                StartInfo = CreateProcessStartInfo(cliPath, AppContext.BaseDirectory),
                EnableRaisingEvents = false
            };

            process.StartInfo.ArgumentList.Add("login");
            process.StartInfo.ArgumentList.Add("show");
            process.StartInfo.ArgumentList.Add("--token");

            if (!process.Start())
                return null;

            Task<string> stdoutTask = process.StandardOutput.ReadToEndAsync(cancellationToken);
            Task<string> stderrTask = process.StandardError.ReadToEndAsync(cancellationToken);
            await process.WaitForExitAsync(cancellationToken).ConfigureAwait(false);

            string stdout = await stdoutTask.ConfigureAwait(false);
            string stderr = await stderrTask.ConfigureAwait(false);
            string combined = stdout + Environment.NewLine + stderr;

            if (process.ExitCode != 0)
                return null;

            // Current CLI output is:
            // "Your auth token (don't share this!) is <token>"
            Match labeled = Regex.Match(
                combined,
                @"Your auth token.*?\bis\s+([^\s]+)",
                RegexOptions.IgnoreCase | RegexOptions.CultureInvariant);

            if (labeled.Success)
                return labeled.Groups[1].Value.Trim();

            // Fallback for CLI versions that print only the JWT/token.
            foreach (string line in SplitLines(combined))
            {
                string candidate = line.Trim();
                if (candidate.Count(ch => ch == '.') >= 2 && candidate.Length > 40)
                    return candidate;
            }
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch
        {
            // Startup logs a clear message if no owner credential can be obtained.
        }

        return null;
    }

    private async Task<string?> BuildModuleWasmAsync(
        string dotnetPath,
        string moduleDirectory,
        CancellationToken cancellationToken)
    {
        string projectPath = Path.Combine(moduleDirectory, "StdbModule.csproj");
        if (!File.Exists(projectPath))
        {
            _log($"SpacetimeDB module project was not found at '{projectPath}'.");
            return null;
        }

        EnsureModuleRuntimeIdentifier(projectPath);

        string binBuildRoot = Path.Combine(moduleDirectory, "bin", "Release");
        string objBuildRoot = Path.Combine(moduleDirectory, "obj", "Release");
        DateTime buildStartedUtc = DateTime.UtcNow;

        _log($"Building SpacetimeDB module with explicit runtime identifier 'wasi-wasm' using '{dotnetPath}'...");

        using var build = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = dotnetPath,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true,
                WorkingDirectory = moduleDirectory
            },
            EnableRaisingEvents = false
        };

        ConfigureDotNetEnvironment(build.StartInfo, dotnetPath);

        build.StartInfo.ArgumentList.Add("publish");
        build.StartInfo.ArgumentList.Add("StdbModule.csproj");
        build.StartInfo.ArgumentList.Add("-c");
        build.StartInfo.ArgumentList.Add("Release");
        build.StartInfo.ArgumentList.Add("-f");
        build.StartInfo.ArgumentList.Add("net10.0");
        build.StartInfo.ArgumentList.Add("-r");
        build.StartInfo.ArgumentList.Add("wasi-wasm");
        build.StartInfo.ArgumentList.Add("--self-contained");
        build.StartInfo.ArgumentList.Add("true");
        build.StartInfo.ArgumentList.Add("-v");
        build.StartInfo.ArgumentList.Add("minimal");

        if (!build.Start())
        {
            _log("Could not start dotnet publish for the SpacetimeDB module.");
            return null;
        }

        Task<string> stdout = build.StandardOutput.ReadToEndAsync(cancellationToken);
        Task<string> stderr = build.StandardError.ReadToEndAsync(cancellationToken);

        await build.WaitForExitAsync(cancellationToken).ConfigureAwait(false);

        string outText = await stdout.ConfigureAwait(false);
        string errText = await stderr.ConfigureAwait(false);

        foreach (string line in SplitLines(outText))
            _log($"[SpacetimeDB build] {line}");
        foreach (string line in SplitLines(errText))
            _log($"[SpacetimeDB build] {line}");

        if (build.ExitCode != 0)
        {
            _log($"SpacetimeDB module build failed with exit code {build.ExitCode}.");
            return null;
        }

        var searchRoots = new[] { objBuildRoot, binBuildRoot }
            .Where(Directory.Exists)
            .Select(path => new DirectoryInfo(path))
            .ToArray();

        if (searchRoots.Length == 0)
        {
            _log("SpacetimeDB module build completed but neither obj/Release nor bin/Release exists.");
            return null;
        }

        // SpacetimeDB's .NET 10 NativeAOT-LLVM target normally writes the
        // publishable module to:
        // obj/Release/net10.0/wasi-wasm/wasm/for-publish/StdbModule.wasm
        FileInfo? wasm = searchRoots
            .SelectMany(root => root.EnumerateFiles("*.wasm", SearchOption.AllDirectories))
            .Where(file => file.LastWriteTimeUtc >= buildStartedUtc.AddSeconds(-2))
            .OrderByDescending(file =>
                file.FullName.Contains(
                    $"{Path.DirectorySeparatorChar}wasm{Path.DirectorySeparatorChar}for-publish{Path.DirectorySeparatorChar}",
                    StringComparison.OrdinalIgnoreCase))
            .ThenByDescending(file => file.LastWriteTimeUtc)
            .FirstOrDefault();

        if (wasm is null)
        {
            wasm = searchRoots
                .SelectMany(root => root.EnumerateFiles("*.wasm", SearchOption.AllDirectories))
                .OrderByDescending(file =>
                    file.FullName.Contains(
                        $"{Path.DirectorySeparatorChar}wasm{Path.DirectorySeparatorChar}for-publish{Path.DirectorySeparatorChar}",
                        StringComparison.OrdinalIgnoreCase))
                .ThenByDescending(file => file.LastWriteTimeUtc)
                .FirstOrDefault();
        }

        if (wasm is null)
        {
            _log("dotnet publish succeeded, but no .wasm module could be found under obj/Release or bin/Release.");
            return null;
        }

        _log($"SpacetimeDB module build OK: {wasm.FullName}");
        return wasm.FullName;
    }

    private static void EnsureModuleRuntimeIdentifier(string projectPath)
    {
        try
        {
            string project = File.ReadAllText(projectPath);

            if (!project.Contains("<RuntimeIdentifier>", StringComparison.Ordinal))
            {
                project = project.Replace(
                    "<TargetFramework>net10.0</TargetFramework>",
                    "<TargetFramework>net10.0</TargetFramework>" +
                    Environment.NewLine +
                    "    <RuntimeIdentifier>wasi-wasm</RuntimeIdentifier>",
                    StringComparison.Ordinal);

                File.WriteAllText(projectPath, project);
            }
            else if (!project.Contains("<RuntimeIdentifier>wasi-wasm</RuntimeIdentifier>", StringComparison.Ordinal))
            {
                project = Regex.Replace(
                    project,
                    "<RuntimeIdentifier>.*?</RuntimeIdentifier>",
                    "<RuntimeIdentifier>wasi-wasm</RuntimeIdentifier>");

                File.WriteAllText(projectPath, project);
            }
        }
        catch
        {
            // The bundled module already carries this setting. If the file is
            // read-only, dotnet publish still receives -r wasi-wasm explicitly.
        }
    }

    private async Task<bool> WaitForDatabaseAsync(
        Func<CancellationToken, Task<bool>> databaseExistsAsync,
        CancellationToken cancellationToken)
    {
        DateTime deadline = DateTime.UtcNow.AddSeconds(Math.Max(3, _settings.SpacetimeStartupTimeoutSeconds));
        while (DateTime.UtcNow < deadline && !cancellationToken.IsCancellationRequested)
        {
            try
            {
                if (await databaseExistsAsync(cancellationToken).ConfigureAwait(false))
                    return true;
            }
            catch
            {
                // The database may still be registering after publish.
            }

            await Task.Delay(250, cancellationToken).ConfigureAwait(false);
        }
        return false;
    }

    private ProcessStartInfo CreateProcessStartInfo(string cliPath, string workingDirectory)
    {
        return new ProcessStartInfo
        {
            FileName = cliPath,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            StandardOutputEncoding = Encoding.UTF8,
            StandardErrorEncoding = Encoding.UTF8,
            CreateNoWindow = true,
            WorkingDirectory = workingDirectory
        };
    }

    private string? ResolveDotNetPath()
    {
        if (!string.IsNullOrWhiteSpace(_settings.SpacetimeDotNetPath))
        {
            string configured = Environment.ExpandEnvironmentVariables(_settings.SpacetimeDotNetPath.Trim());
            if (File.Exists(configured))
                return Path.GetFullPath(configured);

            if (!configured.Contains(Path.DirectorySeparatorChar) &&
                !configured.Contains(Path.AltDirectorySeparatorChar))
            {
                string? resolved = FindInPath(configured);
                if (resolved is not null)
                    return resolved;
            }
        }

        string executable = RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
            ? "dotnet.exe"
            : "dotnet";

        string? inPath = FindInPath(executable);
        if (inPath is not null)
            return inPath;

        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            string programFiles = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFiles);
            string candidate = Path.Combine(programFiles, "dotnet", "dotnet.exe");
            if (File.Exists(candidate))
                return candidate;

            string programFilesX86 = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
            candidate = Path.Combine(programFilesX86, "dotnet", "dotnet.exe");
            if (File.Exists(candidate))
                return candidate;
        }
        else
        {
            foreach (string candidate in new[] { "/usr/local/share/dotnet/dotnet", "/usr/share/dotnet/dotnet", "/opt/homebrew/bin/dotnet" })
                if (File.Exists(candidate))
                    return candidate;
        }

        return null;
    }

    private static async Task<bool> HasDotNet10SdkAsync(string dotnetPath, CancellationToken cancellationToken)
    {
        try
        {
            using var probe = new Process
            {
                StartInfo = new ProcessStartInfo
                {
                    FileName = dotnetPath,
                    UseShellExecute = false,
                    RedirectStandardOutput = true,
                    RedirectStandardError = true,
                    CreateNoWindow = true
                }
            };
            probe.StartInfo.ArgumentList.Add("--list-sdks");
            if (!probe.Start())
                return false;

            string stdout = await probe.StandardOutput.ReadToEndAsync(cancellationToken).ConfigureAwait(false);
            await probe.WaitForExitAsync(cancellationToken).ConfigureAwait(false);
            if (probe.ExitCode != 0)
                return false;

            foreach (string line in SplitLines(stdout))
            {
                string version = line.Split(' ', StringSplitOptions.RemoveEmptyEntries)[0];
                if (version.StartsWith("10.", StringComparison.OrdinalIgnoreCase))
                    return true;
            }
        }
        catch
        {
            // Fall through to false.
        }

        return false;
    }

    private static void ConfigureDotNetEnvironment(ProcessStartInfo startInfo, string dotnetPath)
    {
        string? dotnetDirectory = Path.GetDirectoryName(dotnetPath);
        if (string.IsNullOrWhiteSpace(dotnetDirectory))
            return;

        startInfo.Environment["DOTNET_ROOT"] = dotnetDirectory;
        startInfo.Environment["DOTNET_HOST_PATH"] = dotnetPath;

        string currentPath = startInfo.Environment.TryGetValue("PATH", out string? value)
            ? value ?? string.Empty
            : Environment.GetEnvironmentVariable("PATH") ?? string.Empty;

        if (!currentPath.Split(Path.PathSeparator, StringSplitOptions.RemoveEmptyEntries)
            .Any(entry => string.Equals(entry.Trim().Trim('"'), dotnetDirectory, StringComparison.OrdinalIgnoreCase)))
        {
            startInfo.Environment["PATH"] = dotnetDirectory + Path.PathSeparator + currentPath;
        }
    }

    private static void EnsureModuleGlobalJson(string moduleDirectory)
    {
        string globalJson = Path.Combine(moduleDirectory, "global.json");
        const string required = "{\"sdk\":{\"version\":\"10.0.100\",\"rollForward\":\"latestMinor\"}}";

        try
        {
            if (!File.Exists(globalJson) || !File.ReadAllText(globalJson).Contains("10.0.100", StringComparison.Ordinal))
                File.WriteAllText(globalJson, required + Environment.NewLine);
        }
        catch
        {
            // The module bundled with the app should already contain global.json.
            // If it is read-only, SpacetimeDB will report the precise SDK error.
        }
    }

    private string? ResolveCliPath()
    {
        if (!string.IsNullOrWhiteSpace(_settings.SpacetimeCliPath))
        {
            string configured = Environment.ExpandEnvironmentVariables(_settings.SpacetimeCliPath.Trim());
            if (File.Exists(configured))
                return Path.GetFullPath(configured);

            // Also allow a command name such as "spacetime" to be supplied explicitly.
            if (!configured.Contains(Path.DirectorySeparatorChar) &&
                !configured.Contains(Path.AltDirectorySeparatorChar))
                return configured;
        }

        string executable = RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
            ? "spacetime.exe"
            : "spacetime";

        string? found = FindInPath(executable);
        if (found is not null)
            return found;

        string home = Environment.GetFolderPath(Environment.SpecialFolder.UserProfile);
        string[] candidates = RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
            ? new[]
            {
                Path.Combine(home, ".spacetime", "bin", "spacetime.exe"),
                Path.Combine(home, ".local", "bin", "spacetime.exe")
            }
            : new[]
            {
                Path.Combine(home, ".spacetime", "bin", "spacetime"),
                Path.Combine(home, ".local", "bin", "spacetime"),
                "/usr/local/bin/spacetime",
                "/opt/homebrew/bin/spacetime"
            };

        foreach (string candidate in candidates)
            if (File.Exists(candidate))
                return candidate;

        return null;
    }

    private string ResolveModuleDirectory()
    {
        string configured = string.IsNullOrWhiteSpace(_settings.SpacetimeModulePath)
            ? "spacetimedb"
            : Environment.ExpandEnvironmentVariables(_settings.SpacetimeModulePath.Trim());

        if (Path.IsPathRooted(configured))
            return Path.GetFullPath(configured);

        string besideExe = Path.GetFullPath(Path.Combine(AppContext.BaseDirectory, configured));
        if (Directory.Exists(besideExe))
            return besideExe;

        // Development tree fallback when running from bin/Debug/... .
        DirectoryInfo? dir = new(AppContext.BaseDirectory);
        for (int i = 0; i < 8 && dir is not null; i++, dir = dir.Parent)
        {
            string candidate = Path.Combine(dir.FullName, configured);
            if (Directory.Exists(candidate))
                return candidate;
        }

        return besideExe;
    }

    private bool TryGetLocalEndpoint(out string listenAddress)
    {
        listenAddress = "127.0.0.1:3000";

        if (!Uri.TryCreate(_settings.SpacetimeUri, UriKind.Absolute, out Uri? uri))
            return false;

        bool local =
            uri.IsLoopback ||
            string.Equals(uri.Host, "localhost", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(uri.Host, "127.0.0.1", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(uri.Host, "::1", StringComparison.OrdinalIgnoreCase);

        if (!local)
            return false;

        string host = uri.Host == "::1" ? "[::1]" : uri.Host;
        listenAddress = $"{host}:{uri.Port}";
        return true;
    }

    private static string? FindInPath(string executable)
    {
        string? path = Environment.GetEnvironmentVariable("PATH");
        if (string.IsNullOrWhiteSpace(path))
            return null;

        foreach (string part in path.Split(Path.PathSeparator, StringSplitOptions.RemoveEmptyEntries))
        {
            try
            {
                string candidate = Path.Combine(part.Trim().Trim('"'), executable);
                if (File.Exists(candidate))
                    return candidate;
            }
            catch
            {
                // Ignore malformed PATH entries.
            }
        }

        return null;
    }

    private static async Task<bool> WaitForPingAsync(
        Func<CancellationToken, Task> pingAsync,
        TimeSpan timeout,
        CancellationToken cancellationToken)
    {
        DateTime deadline = DateTime.UtcNow.Add(timeout);

        while (DateTime.UtcNow < deadline && !cancellationToken.IsCancellationRequested)
        {
            if (await CanPingAsync(pingAsync, cancellationToken).ConfigureAwait(false))
                return true;

            try
            {
                await Task.Delay(100, cancellationToken).ConfigureAwait(false);
            }
            catch (OperationCanceledException)
            {
                return false;
            }
        }

        return false;
    }

    private static async Task<bool> CanPingAsync(
        Func<CancellationToken, Task> pingAsync,
        CancellationToken cancellationToken)
    {
        using var pingTimeout = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        pingTimeout.CancelAfter(TimeSpan.FromSeconds(1));

        try
        {
            await pingAsync(pingTimeout.Token).ConfigureAwait(false);
            return true;
        }
        catch (OperationCanceledException) when (!cancellationToken.IsCancellationRequested)
        {
            return false;
        }
        catch
        {
            return false;
        }
    }

    private static string[] SplitLines(string value) =>
        value.Split(new[] { "\r\n", "\n" }, StringSplitOptions.RemoveEmptyEntries);

    private static string LeafMessage(Exception ex)
    {
        Exception leaf = ex;
        while (leaf.InnerException is not null)
            leaf = leaf.InnerException;
        return leaf.Message;
    }

    public void Dispose()
    {
        if (_startedByServer && _process is not null)
        {
            try
            {
                if (!_process.HasExited)
                {
                    _log("Stopping SpacetimeDB started by this server...");
                    _process.Kill(entireProcessTree: true);
                    _process.WaitForExit(3000);
                }
            }
            catch (Exception ex)
            {
                _log($"Could not stop SpacetimeDB cleanly: {ex.Message}");
            }
        }

        _process?.Dispose();
        _process = null;
        _startedByServer = false;
    }
}
