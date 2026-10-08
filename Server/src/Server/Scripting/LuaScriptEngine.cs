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

    // Scripts belong to events; no standalone Main.lua or colors.lua files are created.

    public IReadOnlyList<string> ScriptFiles => Directory.Exists(_scriptsPath)
        ? Directory.EnumerateFiles(_scriptsPath, "*.lua").OrderBy(Path.GetFileName, StringComparer.OrdinalIgnoreCase).ToArray()
        : Array.Empty<string>();

    public bool Reload()
    {
        lock (_sync)
        {
            try
            {

                var script = new Script(CoreModules.Preset_Complete);
                InstallApi(script);

                var files = Array.Empty<string>();

                _script = script;


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

    public bool RunEvent(string code, IReadOnlyDictionary<string, object?> properties)
    {
        lock (_sync)
        {
            try
            {
                var script = new Script(CoreModules.Preset_SoftSandbox);
                foreach (var (name, value) in properties)
                    if (!string.IsNullOrWhiteSpace(name)) script.Globals[name] = DynValue.FromObject(script, value);
                script.DoString(code);
                return true;
            }
            catch (InterpreterException ex) { _log($"Event Lua error: {ex.DecoratedMessage}"); return false; }
            catch (Exception ex) { _log($"Event Lua error: {ex.Message}"); return false; }
        }
    }

    public void Dispose()
    {
        lock (_sync)
            _script = null;
    }
}
