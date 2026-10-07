using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace Server
{

    public sealed class PacketRouter
    {
        private readonly ServerSettings _settings;
        private readonly MirrorTcpHost _network;
        private readonly SpacetimeRepository _db;
        private readonly ConcurrentDictionary<int, PlayerSession> _sessions;
        private readonly LegacyGameService _legacy;
        private readonly XtremeWorlds.Tools.ToolService _tools;
        private readonly XtremeWorlds.Tools.AdminToolsService _adminTools;
        private readonly Action<string>? _log;

        public PacketRouter(ServerSettings settings, MirrorTcpHost network, SpacetimeRepository db, ConcurrentDictionary<int, PlayerSession> sessions, Action<string>? log = null, Action<BugReportInfo>? bugReport = null)
        {
            _settings = settings;
            _network = network;
            _db = db;
            _sessions = sessions;
            _log = log;
            _legacy = new LegacyGameService(settings, network, db, sessions, log, bugReport);
            _adminTools = new XtremeWorlds.Tools.AdminToolsService(
                () => _sessions.Values.Where(s => s.IsPlaying && s.Character is not null).Select(s => new XtremeWorlds.Tools.AdminPlayer {
                    ConnectionId = s.ConnectionId, Name = s.Character!.Name, Login = s.Login, Access = s.Character.Access,
                    Sprite = s.Character.Sprite, Map = s.Character.Map, X = s.Character.X, Y = s.Character.Y,
                    IpAddress = s.IpAddress, HardwareId = s.HardwareId, IsMuted = s.IsMuted, IsJailed = s.IsJailed
                }).ToArray(),
                async changed =>
                {
                    if (!_sessions.TryGetValue(changed.ConnectionId, out var target) || target.Character is not { } character
                        || character.Name != changed.Name) return;
                    character.Access = (byte)changed.Access; character.Sprite = (short)changed.Sprite;
                    target.IsMuted = changed.IsMuted; target.IsJailed = changed.IsJailed;
                    character.Map = (short)changed.Map; character.X = (byte)changed.X; character.Y = (byte)changed.Y;
                    character.PixelX = changed.X * 32; character.PixelY = changed.Y * 32;
                    await _db.SaveCharacterAsync(target.Login, target.CharacterSlot, character);
                    await SendCurrentMapAsync(target.ConnectionId);
                },
                (actor, target) => _db.AddBanAsync(new BanDefinition { BannedIP = target.IpAddress, BannedCharacter = target.Name, BannedBy = actor.Name, BannedHardwareId = target.HardwareId }),
                _db.ClearBansAsync, _network.Disconnect,
                (id, message) => _network.SendText(id, PacketCodec.Compose("playermsg", message, 15)),
                SendCurrentMapAsync);
            _network.Disconnected += _adminTools.ForgetPlayer;
            _tools = new XtremeWorlds.Tools.ToolService(
                id => _sessions.TryGetValue(id, out var actor) && actor.IsPlaying && actor.Character is not null ? actor.Character.Access : 0,
                kind => _db.LoadContentAsync<System.Text.Json.Nodes.JsonObject>(kind),
                async (kind, slot, definition) =>
                {
                    await _db.UpsertContentAsync(kind, slot, XtremeWorlds.Tools.ToolSchema.Text(definition, kind == "emote" ? "Command" : "Name"), definition);
                    if (kind == "map")
                    {
                        var map = System.Text.Json.JsonSerializer.Deserialize<MapDefinition>(definition.ToJsonString());
                        if (map is not null) SendWorldSnapshot(slot, map);
                    }
                },
                (id, command, arguments) => _network.SendText(id, PacketCodec.Compose(command, arguments)),
                new Dictionary<string, int> {
                    ["item"] = settings.MaxItems, ["npc"] = settings.MaxNpcs, ["shop"] = settings.MaxShops,
                    ["spell"] = settings.MaxSpells, ["sign"] = settings.MaxSigns, ["arrow"] = settings.MaxArrows,
                    ["class"] = settings.MaxClasses, ["quest"] = settings.MaxQuests, ["book"] = settings.MaxBooks,
                    ["emote"] = settings.MaxEmotes, ["map"] = settings.MaxMaps
                });
        }

        public async Task HandleAsync(int connectionId, string data)
        {
            string[] p = PacketCodec.SplitPacket(data);
            if (p.Length == 0)
                return;
            string command = (p[0] ?? string.Empty).Trim().ToLowerInvariant();
            if (_sessions.TryGetValue(connectionId, out var session) &&
                ModerationPolicy.Rejection(session, command) is string rejection)
            {
                _network.SendText(connectionId, PacketCodec.Compose("playermsg", rejection, 15));
                return;
            }
            try
            {
                if (XtremeWorlds.Tools.AdminToolsService.Recognizes(command))
                {
                    await _adminTools.HandleAsync(connectionId, p);
                    return;
                }
                if (XtremeWorlds.Tools.ToolService.Recognizes(command))
                {
                    await _tools.HandleAsync(connectionId, p);
                    return;
                }
                switch (command)
                {
                    case "muteplayer":
                    case "unmuteplayer":
                    case "jailplayer":
                    case "unjailplayer":
                        ModeratePlayer(connectionId, command, p);
                        break;
                    case "getclasses":
                        {
                            await SendClassesAsync(connectionId);
                            break;
                        }
                    case "newaccount":
                        {
                            await NewAccountAsync(connectionId, p);
                            break;
                        }
                    case "login":
                        {
                            await LoginAsync(connectionId, p);
                            break;
                        }
                    case "addchar":
                        {
                            await AddCharacterAsync(connectionId, p);
                            break;
                        }
                    case "delchar":
                        {
                            await DeleteCharacterAsync(connectionId, p);
                            break;
                        }
                    case "usechar":
                        {
                            await UseCharacterAsync(connectionId, p);
                            break;
                        }

                    case "playermove":
                        await MoveAsync(connectionId, p);
                        break;
                    case "warpto":
                    case "warptotile":
                    case "warpmeto":
                    case "warptome":
                        await TeleportAsync(connectionId, command, p);
                        break;
                    case "needmap":
                    case "requestnewmap":
                        await SendCurrentMapAsync(connectionId);
                        break;
                    default:
                        {
                            await _legacy.HandleAsync(connectionId, command, p);
                            break;
                        }
                }
            }
            catch (Exception ex)
            {
                _log?.Invoke($"[{connectionId}] {command}: {ex.Message}");
                string clientMessage = ex is System.Net.Http.HttpRequestException ? "Database service is unavailable. Please try again after SpacetimeDB is started." : "Server error handling packet.";
                _network.SendText(connectionId, PacketCodec.Compose("alertmsg", clientMessage));
            }
        }

        private void ModeratePlayer(int id, string command, string[] fields)
        {
            void Reply(string message) => _network.SendText(id, PacketCodec.Compose("playermsg", message, 15));
            if (!_sessions.TryGetValue(id, out var actor) || !actor.IsPlaying || actor.Character is null || actor.Character.Access < 1)
            {
                Reply("Only admins may moderate players.");
                return;
            }
            string name = fields.Length > 1 ? fields[1].Trim() : string.Empty;
            if (name.Length == 0)
            {
                Reply($"Usage: /{command.Replace("player", "")} <player name>");
                return;
            }
            var target = _sessions.Values.FirstOrDefault(s => s.IsPlaying && s.Character is not null &&
                string.Equals(s.Character.Name, name, StringComparison.OrdinalIgnoreCase));
            if (target is null)
            {
                Reply($"Player '{name}' is not online.");
                return;
            }
            if (target.ConnectionId == id || target.Character!.Access >= actor.Character.Access)
            {
                Reply("You may only moderate players with lower access than yours.");
                return;
            }
            string action;
            switch (command)
            {
                case "muteplayer": target.IsMuted = true; action = "muted"; break;
                case "unmuteplayer": target.IsMuted = false; action = "unmuted"; break;
                case "jailplayer": target.IsJailed = true; action = "jailed"; break;
                default: target.IsJailed = false; action = "released from jail"; break;
            }
            string message = $"{target.Character.Name} has been {action} by {actor.Character.Name}.";
            Reply(message);
            _network.SendText(target.ConnectionId, PacketCodec.Compose("playermsg", message, 15));
            _log?.Invoke(message);
        }

        public void Tick()
        {
            _legacy.Tick();
        }

        private async Task NewAccountAsync(int id, string[] p)
        {
            if (p.Length < 3)
                return;
            string login = p[1].Trim();
            string password = p[2];
            string trimmedPassword = password.Trim();

            // Match the TwinBasic server's minimum of three characters, but keep
            // this check separate from character/name validation so a four-character
            // account name can never receive the minimum-length error for another reason.
            if (login.Length < 3)
            {
                _log?.Invoke($"[{id}] newaccount rejected: account name length was {login.Length}.");
                _network.SendText(id, PacketCodec.Compose("alertmsg", "Your account name must be at least three characters in length."));
                return;
            }

            if (trimmedPassword.Length < 3)
            {
                _log?.Invoke($"[{id}] newaccount rejected: password length was {trimmedPassword.Length}.");
                _network.SendText(id, PacketCodec.Compose("alertmsg", "Your password must be at least three characters in length."));
                return;
            }

            if (login.Length > GameLimits.NameLength)
            {
                _network.SendText(id, PacketCodec.Compose("alertmsg", $"Your account name cannot be longer than {GameLimits.NameLength} characters."));
                return;
            }

            if (!login.All(ch => char.IsLetterOrDigit(ch) || ch == '_' || ch == ' '))
            {
                _network.SendText(id, PacketCodec.Compose("alertmsg", "Invalid name, only letters, numbers, spaces, and _ are allowed in names."));
                return;
            }
            if (await _db.AccountExistsAsync(login))
            {
                _network.SendText(id, PacketCodec.Compose("alertmsg", "Sorry, that account name is already taken!"));
                return;
            }
            await _db.CreateAccountAsync(login, password, "");
            _network.SendText(id, PacketCodec.Compose("alertmsg", "Your account has been created!"));
        }

        private async Task LoginAsync(int id, string[] p)
        {
            if (p.Length < 3)
                return;
            if (!_sessions.TryGetValue(id, out PlayerSession? session) || session is null)
                return;
            string login = p[1].Trim();
            string password = p[2];
            var account = await _db.GetAccountAsync(login);
            if (account is null || !PasswordHasher.Verify(password, account.PasswordHash, account.PasswordSalt))
            {
                _network.SendText(id, PacketCodec.Compose("alertmsg", "Incorrect account name or password."));
                return;
            }
            if (await _db.IsBannedAsync(session.IpAddress, session.HardwareId))
            {
                _network.SendText(id, PacketCodec.Compose("alertmsg", $"You have been banned from {_settings.GameName}."));
                return;
            }
            session.Login = account.Login;
            session.IsLoggedIn = true;
            await SendCharactersAsync(id, account.Login);
        }

        private async Task AddCharacterAsync(int id, string[] p)
        {
            if (p.Length < 5)
                return;
            if (!_sessions.TryGetValue(id, out PlayerSession? session) || session is null || !session.IsLoggedIn)
                return;
            string name = p[1].Trim();
            byte sex = byte.Parse(p[2], CultureInfo.InvariantCulture);
            byte classId = byte.Parse(p[3], CultureInfo.InvariantCulture);
            int slot = int.Parse(p[4], CultureInfo.InvariantCulture);
            if (slot < 1 || slot > GameLimits.MaxCharacters || !ValidName(name))
            {
                _network.SendText(id, PacketCodec.Compose("alertmsg", "Invalid character."));
                return;
            }
            var existingCharacters = await _db.GetCharactersAsync(session.Login);
            var existingInSlot = existingCharacters.FirstOrDefault(c => c.Slot == slot);

            // Treat a repeated addchar packet for the same character as success.
            // This makes character creation idempotent and prevents a second
            // click/queued packet from hitting SpacetimeDB's unique name index.
            if (existingInSlot?.Character is not null)
            {
                if (string.Equals(existingInSlot.Character.Name, name, StringComparison.OrdinalIgnoreCase))
                {
                    await SendCharactersAsync(id, session.Login);
                    return;
                }

                _network.SendText(id, PacketCodec.Compose("alertmsg", "That character slot is already in use."));
                return;
            }

            if (await _db.CharacterNameExistsAsync(name))
            {
                _network.SendText(id, PacketCodec.Compose("alertmsg", "That character name is already in use."));
                return;
            }

            var character = new PlayerCharacter() { Name = name, Sex = sex, ClassId = classId, Level = 1 };
            await _db.SaveCharacterAsync(session.Login, slot, character);
            await SendCharactersAsync(id, session.Login);
        }

        private async Task DeleteCharacterAsync(int id, string[] p)
        {
            if (p.Length < 2)
                return;
            if (!_sessions.TryGetValue(id, out PlayerSession? session) || session is null || !session.IsLoggedIn)
                return;
            int slot = int.Parse(p[1], CultureInfo.InvariantCulture);
            await _db.DeleteCharacterAsync(session.Login, slot);
            await SendCharactersAsync(id, session.Login);
        }

        private async Task UseCharacterAsync(int id, string[] p)
        {
            if (p.Length < 2)
                return;
            if (!_sessions.TryGetValue(id, out PlayerSession? session) || session is null || !session.IsLoggedIn)
                return;

            int slot = int.Parse(p[1], CultureInfo.InvariantCulture);
            var chars = await _db.GetCharactersAsync(session.Login);
            var selected = chars.FirstOrDefault(c => c.Slot == slot);
            if (selected is null || selected.Character is null)
                return;

            session.CharacterSlot = slot;
            session.Character = selected.Character;
            session.IsPlaying = true;
            var player = selected.Character;
            var maps = await _db.LoadContentAsync<MapDefinition>("map");
            if (!maps.TryGetValue(player.Map, out var map) || map is null)
            {
                // Missing maps are still sent as a valid blank 16x12 map. This lets
                // an administrator enter the world and open the map editor instead
                // of being blocked because the content database has no map row yet.
                map = CreateEmptyMap(player.Map);
                _log?.Invoke($"[{id}] Map {player.Map} has no map data in the server database; sending an empty editable map.");
            }

            if (player.Sprite <= 0)
            {
                var classes = await _db.LoadContentAsync<ClassDefinition>("class");
                if (classes.TryGetValue(player.ClassId, out var definition))
                    player.Sprite = player.Sex == 1 ? definition.MaleSprite : definition.FemaleSprite;
            }

            _network.SendText(id, PacketCodec.Compose("ingame"));
            SendWorldSnapshot(player.Map, map);
            _network.SendText(id, PacketCodec.Compose("playerdata",
                selected.Character.Name, selected.Character.Level, selected.Character.Map, selected.Character.X, selected.Character.Y, selected.Character.Direction));
        }

        private async Task MoveAsync(int id, string[] fields)
        {
            if (!_sessions.TryGetValue(id, out var session) || !session.IsPlaying || session.Character is not { } player
                || fields.Length < 2 || !byte.TryParse(fields[1], out var direction) || direction > 3) return;
            var mapId = player.Map;
            var map = await _db.GetContentAsync<MapDefinition>("map", mapId) ?? CreateEmptyMap(mapId);
            if (!session.IsPlaying || session.Character != player || player.Map != mapId) return;
            double x = player.PixelX ?? player.X * 32;
            double y = player.PixelY ?? player.Y * 32;
            x += direction == 2 ? -4 : direction == 3 ? 4 : 0;
            y += direction == 0 ? -4 : direction == 1 ? 4 : 0;
            int tileX = (int)Math.Floor(x / 32.0), tileY = (int)Math.Floor(y / 32.0);
            player.Direction = direction;
            if (tileX >= 0 && tileX <= GameLimits.MaxMapX && tileY >= 0 && tileY <= GameLimits.MaxMapY)
            {
                var tile = map.Tiles.ElementAtOrDefault(tileY * (GameLimits.MaxMapX + 1) + tileX);
                if (tile?.Type != 1)
                {
                    player.PixelX = x; player.PixelY = y;
                    player.X = (byte)tileX; player.Y = (byte)tileY;
                    if (tile?.Type == 2 && tile.Data1 > 0)
                    {
                        await SetPositionAsync(session, tile.Data1, tile.Data2, tile.Data3);
                        return;
                    }
                }
            }
            SendWorldSnapshot(mapId, map);
        }

        private async Task TeleportAsync(int id, string command, string[] fields)
        {
            if (!_sessions.TryGetValue(id, out var actor) || !actor.IsPlaying || actor.Character is not { Access: >= 1 } player
                || fields.Length < 2) return;
            if (command == "warptotile")
            {
                if (actor.IsJailed || fields.Length != 3 || !int.TryParse(fields[1], out var tileX)
                    || !int.TryParse(fields[2], out var tileY)) return;
                await SetPositionAsync(actor, player.Map, tileX, tileY);
                return;
            }
            if (command == "warpto")
            {
                if (!short.TryParse(fields[1], out var map) || map <= 0) return;
                int x = player.X, y = player.Y;
                if (fields.Length > 2 && !int.TryParse(fields[2], out x)) return;
                if (fields.Length > 3 && !int.TryParse(fields[3], out y)) return;
                await SetPositionAsync(actor, map, x, y);
                return;
            }
            var target = _sessions.Values.FirstOrDefault(s => s.IsPlaying && s.Character != null
                && string.Equals(s.Character.Name, fields[1], StringComparison.OrdinalIgnoreCase));
            if (target?.Character is not { } destination) return;
            if (command == "warpmeto") await SetPositionAsync(actor, destination.Map, destination.X, destination.Y);
            else if (!target.IsJailed && destination.Access < player.Access)
                await SetPositionAsync(target, player.Map, player.X, player.Y);
        }

        private async Task SetPositionAsync(PlayerSession session, int map, int x, int y)
        {
            if (map <= 0 || map > Math.Min(_settings.MaxMaps, short.MaxValue) || x < 0 || x > GameLimits.MaxMapX || y < 0 || y > GameLimits.MaxMapY
                || session.Character is not { } player) return;
            player.Map = (short)map; player.X = (byte)x; player.Y = (byte)y;
            player.PixelX = x * 32; player.PixelY = y * 32;
            await SendCurrentMapAsync(session.ConnectionId);
        }
        private void SendWorldSnapshot(int mapId, MapDefinition map)
        {
            var viewers = _sessions.Values.Where(s => s.IsPlaying && s.Character?.Map == mapId).ToArray();
            var players = viewers.Select(s => s.Character!).ToArray();
            foreach (var viewer in viewers)
                _network.SendText(viewer.ConnectionId, PacketCodec.Compose("worldstate",
                    System.Text.Json.JsonSerializer.Serialize(new { MapId = mapId, Map = map, Player = viewer.Character, Players = players })));
        }
        private static MapDefinition CreateEmptyMap(int mapId)
        {
            var map = new MapDefinition
            {
                Name = $"Map {mapId}",
                Revision = 0,
                Tileset = 0,
                LayerTileset = new List<byte> { 0, 0, 0, 0, 0 }
            };

            int tileCount = (GameLimits.MaxMapX + 1) * (GameLimits.MaxMapY + 1);
            for (int i = 0; i < tileCount; i++)
                map.Tiles.Add(new TileDefinition());

            return map;
        }

        private async Task SendCurrentMapAsync(int id)
        {
            if (!_sessions.TryGetValue(id, out var session) || !session.IsLoggedIn || !session.IsPlaying || session.Character is null)
                return;
            // The session determines the map; clients cannot request unrelated maps.
            var player = session.Character;
            int mapId = player.Map;
            var map = await _db.GetContentAsync<MapDefinition>("map", mapId) ?? CreateEmptyMap(mapId);
            if (!_sessions.TryGetValue(id, out var current) || !ReferenceEquals(current, session)
                || !session.IsPlaying || !ReferenceEquals(session.Character, player) || player.Map != mapId)
                return;
            SendWorldSnapshot(mapId, map);
        }

        private async Task SendCharactersAsync(int id, string login)
        {
            var chars = await _db.GetCharactersAsync(login);
            var classes = await _db.LoadContentAsync<ClassDefinition>("class");
            var args = new List<object>();

            for (int slot = 1; slot <= GameLimits.MaxCharacters; slot++)
            {
                var row = chars.FirstOrDefault(x => x.Slot == slot);
                var character = row?.Character;

                if (character is null)
                {
                    args.Add(string.Empty);
                    args.Add(string.Empty);
                    args.Add(0);
                    args.Add(0);
                    continue;
                }

                string className = string.Empty;
                int sprite = character.Sprite;

                if (classes.TryGetValue(character.ClassId, out var classDefinition))
                {
                    className = classDefinition.Name;
                    if (sprite <= 0)
                    {
                        sprite = character.Sex == 0
                            ? classDefinition.MaleSprite
                            : classDefinition.FemaleSprite;
                    }
                }

                args.Add(character.Name);
                args.Add(className);
                args.Add(character.Level);
                args.Add(sprite);
            }

            _network.SendText(id, PacketCodec.Compose("allchars", args.ToArray()));
        }

        private async Task SendClassesAsync(int id)
        {
            var classes = await _db.LoadContentAsync<ClassDefinition>("class");
            foreach (var kv in classes.OrderBy(x => x.Key))
            {
                var c = kv.Value;
                _network.SendText(id, PacketCodec.Compose("newcharclasses", kv.Key, c.Name, c.MaleSprite, c.FemaleSprite, c.Strength, c.Defense, c.Speed, c.Magic));
            }
        }

        private static bool ValidName(string value)
        {
            if (value.Length < 3 || value.Length > GameLimits.NameLength)
                return false;
            return value.All(ch => char.IsLetterOrDigit(ch) || ch == '_' || ch == ' ');
        }
    }
}
