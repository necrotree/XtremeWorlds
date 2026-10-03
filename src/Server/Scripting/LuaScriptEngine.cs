using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using MoonSharp.Interpreter;

namespace Server;

/// <summary>
/// Managed Lua runtime for XtremeWorlds server scripts.
/// All .lua files in the scripts directory are loaded into one Lua state.
/// colors.lua is loaded first, helper files next, and Main.lua last.
/// </summary>
public sealed class LuaScriptEngine : IDisposable
{
    private readonly string _scriptsPath;
    private readonly ServerSettings _settings;
    private readonly Action<string> _log;
    private readonly Action<string> _globalMessage;
    private readonly object _sync = new();
    private Script? _script;

    public LuaScriptEngine(string scriptsPath, ServerSettings settings, Action<string> log, Action<string> globalMessage)
    {
        _scriptsPath = scriptsPath;
        _settings = settings;
        _log = log;
        _globalMessage = globalMessage;
        Directory.CreateDirectory(_scriptsPath);
    }

    public string MainScriptPath => Path.Combine(_scriptsPath, "Main.lua");
    public string ColorsScriptPath => Path.Combine(_scriptsPath, "colors.lua");

    public IReadOnlyList<string> ScriptFiles => Directory.Exists(_scriptsPath)
        ? Directory.EnumerateFiles(_scriptsPath, "*.lua").OrderBy(Path.GetFileName, StringComparer.OrdinalIgnoreCase).ToArray()
        : Array.Empty<string>();

    public bool Reload()
    {
        lock (_sync)
        {
            try
            {
                EnsureDefaultScripts();

                var script = new Script(CoreModules.Preset_Complete);
                InstallApi(script);

                var files = Directory.EnumerateFiles(_scriptsPath, "*.lua")
                    .OrderBy(path => LoadOrder(Path.GetFileName(path)))
                    .ThenBy(path => Path.GetFileName(path), StringComparer.OrdinalIgnoreCase)
                    .ToArray();

                foreach (var path in files)
                    script.DoString(File.ReadAllText(path), codeFriendlyName: path);

                _script = script;

                var serverSet = script.Globals.Get("ServerSet");
                if (serverSet.Type is DataType.Function or DataType.ClrFunction)
                    script.Call(serverSet);

                _log($"Lua scripts loaded: {string.Join(", ", files.Select(Path.GetFileName))}");
                return true;
            }
            catch (InterpreterException ex)
            {
                _log($"Lua error: {ex.DecoratedMessage}");
                return false;
            }
            catch (Exception ex)
            {
                _log($"Lua load error: {ex.Message}");
                return false;
            }
        }
    }

    public bool Call(string functionName, params object[] args)
    {
        lock (_sync)
        {
            if (_script is null || string.IsNullOrWhiteSpace(functionName))
                return false;

            try
            {
                var function = _script.Globals.Get(functionName);
                if (function.Type is DataType.Nil or DataType.Void)
                    return false;
                if (function.Type != DataType.Function && function.Type != DataType.ClrFunction)
                    return false;

                _script.Call(function, args);
                return true;
            }
            catch (InterpreterException ex)
            {
                _log($"Lua {functionName} error: {ex.DecoratedMessage}");
                return false;
            }
            catch (Exception ex)
            {
                _log($"Lua {functionName} error: {ex.Message}");
                return false;
            }
        }
    }

    private void InstallApi(Script script)
    {
        script.Globals["Log"] = (Action<string>)(message => _log($"[Lua] {message}"));
        script.Globals["GlobalMsg"] = (Action<string, int>)((message, _) => _globalMessage(message));
        script.Globals["GlobalMessage"] = (Action<string, int>)((message, _) => _globalMessage(message));
        script.Globals["AdminMessage"] = (Action<string, int>)((message, _) => _globalMessage(message));
        script.Globals["ServerMessage"] = (Action<string>)(message => _globalMessage(message));

        script.Globals["SetServerName"] = (Action<string>)(value => _settings.GameName = value ?? string.Empty);
        script.Globals["SetWebsite"] = (Action<string>)(value => _settings.Website = value ?? string.Empty);
        script.Globals["SetServerPort"] = (Action<int>)(value => _settings.Port = Math.Max(1, value));
        script.Globals["SetMaxPlayers"] = (Action<int>)(value => _settings.MaxPlayers = Math.Max(1, value));

        script.Globals["SetMaxMaps"] = (Action<int>)(value => _settings.MaxMaps = Math.Max(0, value));
        script.Globals["SetMaxItems"] = (Action<int>)(value => _settings.MaxItems = Math.Max(0, value));
        script.Globals["SetMaxShops"] = (Action<int>)(value => _settings.MaxShops = Math.Max(0, value));
        script.Globals["SetMaxSpells"] = (Action<int>)(value => _settings.MaxSpells = Math.Max(0, value));
        script.Globals["SetMaxSigns"] = (Action<int>)(value => _settings.MaxSigns = Math.Max(0, value));
        script.Globals["SetMaxNPCs"] = (Action<int>)(value => _settings.MaxNpcs = Math.Max(0, value));
        script.Globals["SetMaxGuilds"] = (Action<int>)(value => _settings.MaxGuilds = Math.Max(0, value));
        script.Globals["SetMaxGuildMembers"] = (Action<int>)(value => _settings.MaxGuildMembers = Math.Max(0, value));
        script.Globals["SetMaxQuests"] = (Action<int>)(value => _settings.MaxQuests = Math.Max(0, value));
        script.Globals["SetMaxArrows"] = (Action<int>)(value => _settings.MaxArrows = Math.Max(0, value));
        script.Globals["SetMaxClasses"] = (Action<int>)(value => _settings.MaxClasses = Math.Max(0, value));

        script.Globals["SetStartPosition"] = (Action<int, int, int>)((_, _, _) => { });
        script.Globals["SetDebugScripting"] = (Action<int>)(_ => { });
        script.Globals["GetServerName"] = (Func<string>)(() => _settings.GameName);
    }

    private static int LoadOrder(string? fileName)
    {
        if (string.Equals(fileName, "colors.lua", StringComparison.OrdinalIgnoreCase)) return 0;
        if (string.Equals(fileName, "Main.lua", StringComparison.OrdinalIgnoreCase)) return 2;
        return 1;
    }

    private void EnsureDefaultScripts()
    {
        if (!File.Exists(ColorsScriptPath))
        {
            File.WriteAllText(ColorsScriptPath, """
BLACK = 0
BLUE = 1
GREEN = 2
CYAN = 3
RED = 4
MAGENTA = 5
BROWN = 6
GREY = 7
DARKGREY = 8
BRIGHTBLUE = 9
BRIGHTGREEN = 10
BRIGHTCYAN = 11
BRIGHTRED = 12
PINK = 13
YELLOW = 14
WHITE = 15
NO = 0
YES = 1
""");
        }

        if (!File.Exists(MainScriptPath))
        {
            File.WriteAllText(MainScriptPath, """
function ServerSet()
    Log("Lua scripting initialized.")
end
""");
        }
    }

    public void Dispose()
    {
        lock (_sync)
            _script = null;
    }
}
