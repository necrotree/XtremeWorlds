using XtremeWorlds.Networking;
using System.Threading;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.IO;
using System.Threading.Tasks;

namespace Server
{

    public sealed class PacketRouter
    {
        private long _serverTick;
        private int _snapshotPhase;
        private readonly ConcurrentDictionary<int, MapDefinition> _mapCache = new();
        // Editable game definitions are stored as plain JSON text in SpacetimeDB.
        // All definitions are loaded before the TCP listener accepts clients.
        private IReadOnlyDictionary<int, ItemDefinition> _items = new Dictionary<int, ItemDefinition>();
        private IReadOnlyDictionary<int, NpcDefinition> _npcs = new Dictionary<int, NpcDefinition>();
        private IReadOnlyDictionary<int, ShopDefinition> _shops = new Dictionary<int, ShopDefinition>();
        private IReadOnlyDictionary<int, SpellDefinition> _spells = new Dictionary<int, SpellDefinition>();
        private IReadOnlyDictionary<int, SignDefinition> _signs = new Dictionary<int, SignDefinition>();
        private IReadOnlyDictionary<int, GuildDefinition> _guilds = new Dictionary<int, GuildDefinition>();
        private IReadOnlyDictionary<int, QuestDefinition> _quests = new Dictionary<int, QuestDefinition>();
        private IReadOnlyDictionary<int, ArrowDefinition> _arrows = new Dictionary<int, ArrowDefinition>();
        private IReadOnlyDictionary<int, ClassDefinition> _classes = new Dictionary<int, ClassDefinition>();

        public async Task LoadDefinitionsAsync()
        {
            var maps = await _db.LoadContentAsync<MapDefinition>("map");
            foreach (var (id, map) in maps) _mapCache[id] = map;
            if (maps.Count == 0)
            {
                // Seed only an absent world, never replace existing administrator edits.
                var first = CreateEmptyMap(1);
                await _db.UpsertContentAsync("map", 1, first.Name, first);
                _mapCache[1] = first;
            }
            _items = await _db.LoadContentAsync<ItemDefinition>("item");
            _npcs = await _db.LoadContentAsync<NpcDefinition>("npc");
            _shops = await _db.LoadContentAsync<ShopDefinition>("shop");
            _spells = await _db.LoadContentAsync<SpellDefinition>("spell");
            _signs = await _db.LoadContentAsync<SignDefinition>("sign");
            _guilds = await _db.LoadContentAsync<GuildDefinition>("guild");
            _quests = await _db.LoadContentAsync<QuestDefinition>("quest");
            _arrows = await _db.LoadContentAsync<ArrowDefinition>("arrow");
            _classes = await _db.LoadContentAsync<ClassDefinition>("class");
            _log?.Invoke($"Loaded game data from SpacetimeDB (JSON): {_mapCache.Count} maps, {_items.Count} items, {_npcs.Count} NPCs, {_shops.Count} shops, {_spells.Count} spells, {_signs.Count} signs, {_guilds.Count} guilds, {_quests.Count} quests, {_arrows.Count} arrows, {_classes.Count} classes.");
        }

        private readonly ServerSettings _settings;
        private readonly MirrorTcpHost _network;
        private readonly SpacetimeRepository _db;
        private readonly ConcurrentDictionary<int, PlayerSession> _sessions;
        private readonly LegacyGameService _legacy;
        private readonly Action<string>? _log;

        public PacketRouter(ServerSettings settings, MirrorTcpHost network, SpacetimeRepository db, ConcurrentDictionary<int, PlayerSession> sessions, Action<string>? log = null, Action<BugReportInfo>? bugReport = null)
        {
            _settings = settings;
            _network = network;
            _db = db;
            _sessions = sessions;
            _log = log;
            _legacy = new LegacyGameService(settings, network, db, sessions, log, bugReport);
        }

        public async Task HandleAsync(int connectionId, string data)
        {
            string[] p = PacketCodec.SplitPacket(data);
            if (p.Length == 0)
                return;
            string command = (p[0] ?? string.Empty).Trim().ToLowerInvariant();
            if (command is "netping" or "netresync") { HandleNetworkControl(connectionId, p, command == "netresync"); return; }
            if (_sessions.TryGetValue(connectionId, out var session) &&
                ModerationPolicy.Rejection(session, command) is string rejection)
            {
                _network.SendText(connectionId, PacketCodec.Compose("playermsg", rejection, 15));
                return;
            }
            try
            {
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
                    case "gfxlist":
                    case "gfxget":
                    case "gfxput":
                        TransferGraphics(connectionId, command, p);
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
            lock (target)
            {
                switch (command)
                {
                    case "muteplayer": target.IsMuted = true; action = "muted"; break;
                    case "unmuteplayer": target.IsMuted = false; action = "unmuted"; break;
                    case "jailplayer": target.IsJailed = true; action = "jailed"; break;
                    default: target.IsJailed = false; action = "released from jail"; break;
                }
                if (command is "jailplayer" or "unjailplayer")
                    target.NetworkState.Begin(Pose(target.Character!), Interlocked.Read(ref _serverTick), NetworkClock.Seconds);
            }
            string message = $"{target.Character.Name} has been {action} by {actor.Character.Name}.";
            Reply(message);
            _network.SendText(target.ConnectionId, PacketCodec.Compose("playermsg", message, 15));
            _log?.Invoke(message);
        }

        public void Tick()
        {
            _legacy.Tick();
            long tick = Interlocked.Increment(ref _serverTick);
            double now = NetworkClock.Seconds;
            foreach (var session in _sessions.Values)
            {
                bool disconnect = false;
                lock (session)
                {
                    if (!session.IsPlaying || session.Character == null) continue;
                    var state = session.NetworkState;
                    if (state.IsInactive(now, 2) && !state.Frozen) Restore(session, state.Rollback(tick));
                    disconnect = state.IsInactive(now, 10);
                }
                if (disconnect) _network.Disconnect(session.ConnectionId);
            }
            int tickRate = Math.Clamp(_settings.TickRate, 1, 240);
            _snapshotPhase += Math.Clamp(_settings.SnapshotRate, 1, tickRate);
            if (_snapshotPhase >= tickRate)
            {
                _snapshotPhase -= tickRate;
                foreach (var mapId in _sessions.Values.Where(s => s.IsPlaying && s.Character != null).Select(s => (int)s.Character!.Map).Distinct())
                    SendSnapshot(mapId, null);
            }
        }

        private static bool IsAllowedGraphic(string name) =>
            name.Length is > 4 and <= 100 &&
            name.EndsWith(".png", StringComparison.OrdinalIgnoreCase) &&
            name[..^4].All(c => char.IsAsciiLetterOrDigit(c) || c is '_' or '-');

        private void TransferGraphics(int id, string command, string[] fields)
        {
            void Error(string message) => _network.SendText(id, PacketCodec.Compose("gfxerror", message));
            if (!_sessions.TryGetValue(id, out var session) || !session.IsPlaying ||
                session.Character is not { Access: >= 9 })
            {
                Error("Graphic management requires administrator access level 9.");
                return;
            }
            if (command == "gfxlist")
            {
                string directory = Path.Combine(AppContext.BaseDirectory, "gfx");
                var names = Directory.Exists(directory)
                    ? Directory.EnumerateFiles(directory, "*.png", SearchOption.TopDirectoryOnly)
                        .Select(Path.GetFileName).Where(name => name is not null)
                        .Select(name => name!).Where(IsAllowedGraphic).OrderBy(name => name).Take(1000).ToArray()
                    : Array.Empty<string>();
                _network.SendText(id, PacketCodec.Compose("gfxlist", string.Join(",", names)));
                return;
            }
            if (fields.Length < 2) { Error("Select a graphic."); return; }
            string name = fields[1];
            bool allowed = IsAllowedGraphic(name);
            if (!allowed) { Error("Unsupported graphic filename."); return; }
            string folder = Path.Combine(AppContext.BaseDirectory, "gfx");
            string path = Path.Combine(folder, name);
            if (command == "gfxget")
            {
                if (!File.Exists(path)) { Error("Graphic not found on the server."); return; }
                byte[] data = File.ReadAllBytes(path);
                if (data.Length > 4194304) { Error("Graphic exceeds 4 MiB."); return; }
                _network.SendText(id, PacketCodec.Compose("gfxdata", name, Convert.ToBase64String(data)));
                return;
            }
            if (fields.Length < 3) { Error("No graphic data supplied."); return; }
            byte[] png;
            try { png = Convert.FromBase64String(fields[2]); }
            catch (FormatException) { Error("Invalid graphic data."); return; }
            if (png.Length is < 24 or > 4194304 ||
                !png.AsSpan(0, 8).SequenceEqual(new byte[] {137,80,78,71,13,10,26,10}))
            {
                Error("Only PNG images up to 4 MiB are supported.");
                return;
            }
            Directory.CreateDirectory(folder);
            string temp = path + "." + Guid.NewGuid().ToString("N") + ".tmp";
            try
            {
                File.WriteAllBytes(temp, png);
                File.Move(temp, path, true);
            }
            finally { if (File.Exists(temp)) File.Delete(temp); }
            _network.SendText(id, PacketCodec.Compose("gfxsaved", name));
            _log?.Invoke($"Administrator updated graphic {name}.");
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
            session.IsPlaying = false;
            var player = selected.Character;
            var maps = await _db.LoadContentAsync<MapDefinition>("map");
            if (!maps.TryGetValue(player.Map, out var map) || map is null)
            {
                // Missing maps are still sent as a valid blank 16x12 map. This lets
                // an administrator enter the world and open the map editor instead
                // of being blocked because the content database has no map row yet.
                map = CreateEmptyMap(player.Map);
            }

            if (player.Sprite <= 0)
            {
                var classes = await _db.LoadContentAsync<ClassDefinition>("class");
                if (classes.TryGetValue(player.ClassId, out var definition))
                    player.Sprite = player.Sex == 1 ? definition.MaleSprite : definition.FemaleSprite;
            }

            if (!_sessions.TryGetValue(id, out var currentSession) || !ReferenceEquals(currentSession, session)) return;
            _mapCache[player.Map] = map;
            lock (session) { session.NetworkState.Begin(Pose(player), Interlocked.Read(ref _serverTick), NetworkClock.Seconds); session.IsPlaying = true; }
            _network.SendText(id, PacketCodec.Compose("ingame"));
            SendWorldSnapshot(player.Map, map);
            _network.SendText(id, PacketCodec.Compose("playerdata",
                selected.Character.Name, selected.Character.Level, selected.Character.Map, selected.Character.X, selected.Character.Y, selected.Character.Direction));
        }

        private async Task MoveAsync(int id, string[] fields)
        {
            if (!_sessions.TryGetValue(id, out var session) || !session.IsPlaying || session.Character is not { } player) return;
            var mapId = player.Map;
            var map = await GetMapAsync(mapId);
            int warpMap = 0, warpX = 0, warpY = 0;
            bool rolledBack = false;
            lock (session)
            {
                if (!_sessions.TryGetValue(id, out var current) || !ReferenceEquals(current, session)
                    || !session.IsPlaying || session.Character != player || player.Map != mapId) return;
                if (session.NetworkState.Epoch.Length == 0)
                    session.NetworkState.Begin(Pose(player), Interlocked.Read(ref _serverTick), NetworkClock.Seconds);
                int direction = fields.Length >= 2 && int.TryParse(fields[1], out var parsedDirection) ? parsedDirection : -1;
                if (fields.Length != 2)
                {
                    InputAcceptance acceptance = InputAcceptance.Rejected;
                    if (fields.Length == 7 && long.TryParse(fields[2], out var sequence)
                        && long.TryParse(fields[3], out var clientTick) && long.TryParse(fields[4], out var ackTick)
                        && long.TryParse(fields[5], out var ackSequence))
                        acceptance = session.NetworkState.Accept(new(sequence, clientTick, direction, ackTick, ackSequence, fields[6]), NetworkClock.Seconds);
                    if (acceptance is InputAcceptance.Duplicate or InputAcceptance.StaleEpoch) return;
                    if (acceptance == InputAcceptance.Rejected)
                    {
                        Restore(session, session.NetworkState.Rollback(Interlocked.Read(ref _serverTick)));
                        rolledBack = true;
                    }
                }
                else if (session.NetworkState.ProtocolEnabled || direction is < 0 or > 3) return;
                if (!rolledBack)
                {
                    var moved = Pose(player).Move(direction);
                    int tileX = (int)(moved.X / 32), tileY = (int)(moved.Y / 32);
                    var tile = map.Tiles.ElementAtOrDefault(tileY * (GameLimits.MaxMapX + 1) + tileX);
                    player.Direction = (byte)direction;
                    if (tile?.Type != 1)
                    {
                        Restore(session, moved);
                        if (tile?.Type == 2 && tile.Data1 > 0) { warpMap = tile.Data1; warpX = tile.Data2; warpY = tile.Data3; }
                    }
                }
            }
            if (warpMap > 0) { await SetPositionAsync(session, warpMap, warpX, warpY); return; }
            // Modern clients receive lightweight snapshots at the server snapshot rate.
            if (rolledBack || !session.NetworkState.ProtocolEnabled) SendSnapshot(mapId, null);
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
            lock (session) {
                player.Map = (short)map; player.X = (byte)x; player.Y = (byte)y;
                player.PixelX = x * 32; player.PixelY = y * 32;
                session.NetworkState.Begin(Pose(player), Interlocked.Read(ref _serverTick), NetworkClock.Seconds);
            }
            await SendCurrentMapAsync(session.ConnectionId);
        }
        private static MovementState Pose(PlayerCharacter player) => new(player.Map, player.PixelX ?? player.X * 32.0,
            player.PixelY ?? player.Y * 32.0, player.Direction);
        private static void Restore(PlayerSession session, MovementState pose)
        {
            if (session.Character is not { } player) return;
            player.Map = (short)pose.Map; player.PixelX = pose.X; player.PixelY = pose.Y;
            player.X = (byte)(pose.X / 32); player.Y = (byte)(pose.Y / 32); player.Direction = (byte)pose.Direction;
        }
        private async Task<MapDefinition> GetMapAsync(int id)
        {
            if (_mapCache.TryGetValue(id, out var cached)) return cached;
            var loaded = await _db.GetContentAsync<MapDefinition>("map", id) ?? CreateEmptyMap(id);
            return _mapCache.GetOrAdd(id, loaded);
        }
        public void RollbackConnection(int id)
        {
            if (!_sessions.TryGetValue(id, out var session)) return;
            lock (session)
                if (session.IsPlaying && session.Character != null && session.NetworkState.Epoch.Length > 0)
                    Restore(session, session.NetworkState.Rollback(Interlocked.Read(ref _serverTick)));
        }
        private void HandleNetworkControl(int id, string[] fields, bool resync)
        {
            if (!_sessions.TryGetValue(id, out var session) || !session.IsPlaying || session.Character == null) return;
            int mapId;
            lock (session)
            {
                var state = session.NetworkState;
                if (state.Epoch.Length == 0) return;
                mapId = session.Character.Map;
                // Old queued heartbeats cannot roll back a new connection epoch.
                if (fields.Length >= 2 && fields[1] != state.Epoch) return;
                bool valid = fields.Length == 5 && long.TryParse(fields[2], out var tick)
                    && long.TryParse(fields[3], out var sequence) && long.TryParse(fields[4], out var clientTick)
                    && clientTick >= 0 && state.Acknowledge(fields[1], tick, sequence, NetworkClock.Seconds);
                if (!valid || resync) Restore(session, state.Rollback(Interlocked.Read(ref _serverTick)));
            }
            if (resync || session.NetworkState.Frozen) SendSnapshot(mapId, null);
        }
        private void SendWorldSnapshot(int mapId, MapDefinition map) => SendSnapshot(mapId, map);
        private void SendSnapshot(int mapId, MapDefinition? map)
        {
            var viewers = _sessions.Values.Where(s => s.IsPlaying && s.Character?.Map == mapId).ToArray();
            var actors = new Dictionary<int, object>();
            foreach (var session in viewers)
                lock (session)
                    if (session.IsPlaying && session.Character is { } player && player.Map == mapId)
                        actors[session.ConnectionId] = new { player.Name, player.Sprite, player.X, player.Y, player.Direction,
                            PixelX = player.PixelX ?? player.X * 32.0, PixelY = player.PixelY ?? player.Y * 32.0 };
            foreach (var viewer in viewers)
            {
                string payload;
                lock (viewer)
                {
                    if (!viewer.IsPlaying || viewer.Character?.Map != mapId || !actors.ContainsKey(viewer.ConnectionId)) continue;
                    long tick = Interlocked.Read(ref _serverTick);
                    // Re-capture the viewer under its lock, matching the history pose to the serialized pose.
                    var player = viewer.Character;
                    var local = new { player.Name, player.Sprite, player.X, player.Y, player.Direction,
                        PixelX = player.PixelX ?? player.X * 32.0, PixelY = player.PixelY ?? player.Y * 32.0 };
                    if (viewer.NetworkState.Epoch.Length == 0) viewer.NetworkState.Begin(Pose(player), tick, NetworkClock.Seconds);
                    viewer.NetworkState.Record(tick, Pose(player));
                    payload = System.Text.Json.JsonSerializer.Serialize(new { MapId = mapId, Map = map, Player = local,
                        Players = actors.Where(p => p.Key != viewer.ConnectionId).Select(p => p.Value).Append(local).ToArray(),
                        ServerTick = tick, AckInputSequence = viewer.NetworkState.LastInputSequence,
                        NetworkEpoch = viewer.NetworkState.Epoch, TickRate = Math.Clamp(_settings.TickRate, 1, 240),
                        NetworkFrozen = viewer.NetworkState.Frozen || viewer.IsJailed });
                    // Capture and enqueue under the same lock so async map sends cannot arrive behind a newer tick.
                    _network.SendText(viewer.ConnectionId, PacketCodec.Compose(map == null ? "worldtick" : "worldstate", payload));
                }
            }
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
            var map = await GetMapAsync(mapId);
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
