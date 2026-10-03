using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace Server
{

    // Modern landing point for the remaining original modGameLogic/modHandleData behavior.
    // The original packet names are all recognized here so the protocol surface is preserved.
    public sealed class LegacyGameService
    {
        private readonly ServerSettings _settings;
        private readonly MirrorTcpHost _network;
        private readonly SpacetimeRepository _db;
        private readonly ConcurrentDictionary<int, PlayerSession> _sessions;
        private readonly Action<string>? _log;
        private readonly Action<BugReportInfo>? _bugReport;

        private static readonly HashSet<string> SupportedCommands = new HashSet<string>(StringComparer.OrdinalIgnoreCase) { "delaccount", "saymsg", "emotemsg", "broadcastmsg", "globalmsg", "adminmsg", "playermsg", "playermove", "playerdir", "useitem", "attack", "usestatpoint", "playerinforequest", "warpmeto", "requesteditsign", "editsign", "savesign", "requestsign", "editarrow", "savearrow", "requesteditarrow", "requesteditclass", "editclass", "saveclass", "warptome", "warpto", "setsprite", "playersprite", "getstats", "requestnewmap", "mapdata", "needmap", "mapgetitem", "mapdropitem", "shutdown", "rebootserver", "innsleep", "maprespawn", "mapreport", "signnames", "kickplayer", "banlist", "bandestroy", "banplayer", "unbanplayer", "hdserial", "getgamename", "getgamemaxes", "getgamesite", "requesteditmap", "requestedititem", "edititem", "saveitem", "saveguild", "requesteditnpc", "editnpc", "savenpc", "requesteditshop", "editshop", "saveshop", "requesteditspell", "editspell", "savespell", "setaccess", "whosonline", "onlinelist", "setmotd", "bugreport", "trade", "traderequest", "fixitem", "search", "warpsearch", "party", "joinparty", "leaveparty", "spells", "cast", "forgetspell", "resync", "requestlocation" };

        public LegacyGameService(ServerSettings settings, MirrorTcpHost network, SpacetimeRepository db, ConcurrentDictionary<int, PlayerSession> sessions, Action<string>? log = null, Action<BugReportInfo>? bugReport = null)
        {
            _settings = settings;
            _network = network;
            _db = db;
            _sessions = sessions;
            _log = log;
            _bugReport = bugReport;
        }

        public async Task HandleAsync(int id, string command, string[] p)
        {
            if (!SupportedCommands.Contains(command))
            {
                Console.WriteLine($"[{id}] Unknown command: {command}");
                return;
            }

            switch (command)
            {
                case "getgamename":
                    {
                        _network.SendText(id, PacketCodec.Compose("gamename", _settings.GameName));
                        break;
                    }
                case "getgamesite":
                    {
                        _network.SendText(id, PacketCodec.Compose("gamesite", _settings.Website));
                        break;
                    }
                case "hdserial":
                    {
                        if (_sessions.TryGetValue(id, out PlayerSession? session) && session is not null && p.Length > 1)
                            session.HardwareId = p[1];
                        break;
                    }
                case "saymsg":
                case "emotemsg":
                case "globalmsg":
                case "broadcastmsg":
                    {
                        if (p.Length > 1)
                            Broadcast(PacketCodec.Compose(command, p[1]));
                        break;
                    }
                case "requestlocation":
                    {
                        if (_sessions.TryGetValue(id, out PlayerSession? s) && s is not null && s.Character is not null)
                        {
                            _network.SendText(id, PacketCodec.Compose("location", s.Character.Map, s.Character.X, s.Character.Y));
                        }

                        break;
                    }
                case "bugreport":
                    {
                        HandleBugReport(id, p);
                        break;
                    }

                default:
                    {
                        // The full legacy implementation remains in LegacySource/modHandleData.bas and modGameLogic.bas.
                        // This modern router deliberately keeps DB/network access asynchronous and isolated.
                        await Task.CompletedTask;
                        break;
                    }
            }
        }

        private void HandleBugReport(int id, string[] p)
        {
            if (p.Length < 5)
                return;

            _sessions.TryGetValue(id, out var session);
            string player = session?.Character?.Name ?? session?.Login ?? $"Connection {id}";
            string type = BugTypeLabel(ParseByte(p[2]));
            string occurs = BugOccursLabel(ParseByte(p[3]));
            string repeat = ParseByte(p[4]) switch { 1 => "Yes", 2 => "No", _ => "Unknown" };
            string message = p[1].Trim();
            if (message.Length == 0)
                message = "(no description)";

            var report = new BugReportInfo(DateTimeOffset.Now, id, player, type, occurs, repeat, message);
            _bugReport?.Invoke(report);
            _log?.Invoke($"Bug report received from {player}.");
            _network.SendText(id, PacketCodec.Compose("playermsg", $"Thank you for reporting this bug, {player}", 15));
        }

        private static byte ParseByte(string value) => byte.TryParse(value, out var result) ? result : (byte)0;
        private static string BugTypeLabel(byte value) => value switch { 1 => "Mapping", 2 => "Programming", 3 => "Other", _ => "Unknown" };
        private static string BugOccursLabel(byte value) => value switch { 1 => "Often", 2 => "Sometimes", 3 => "Once", _ => "Unknown" };

        public void Tick()
        {
            // World/NPC/projectile timers from the original server can be moved here incrementally.
        }

        private void Broadcast(string packet)
        {
            foreach (var id in _sessions.Keys)
                _network.SendText(id, packet);
        }
    }
}