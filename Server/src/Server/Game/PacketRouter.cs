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
            string command = p[0].Trim().ToLowerInvariant();
            try
            {
                switch (command ?? "")
                {
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
            PlayerSession session = null;
            if (!_sessions.TryGetValue(id, out session))
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
            PlayerSession session = null;
            if (!_sessions.TryGetValue(id, out session) || !session.IsLoggedIn)
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
            var character = new PlayerCharacter() { Name = name, Sex = sex, ClassId = classId, Level = 1 };
            await _db.SaveCharacterAsync(session.Login, slot, character);
            await SendCharactersAsync(id, session.Login);
        }

        private async Task DeleteCharacterAsync(int id, string[] p)
        {
            if (p.Length < 2)
                return;
            PlayerSession session = null;
            if (!_sessions.TryGetValue(id, out session) || !session.IsLoggedIn)
                return;
            int slot = int.Parse(p[1], CultureInfo.InvariantCulture);
            await _db.DeleteCharacterAsync(session.Login, slot);
            await SendCharactersAsync(id, session.Login);
        }

        private async Task UseCharacterAsync(int id, string[] p)
        {
            if (p.Length < 2)
                return;
            PlayerSession session = null;
            if (!_sessions.TryGetValue(id, out session) || !session.IsLoggedIn)
                return;
            int slot = int.Parse(p[1], CultureInfo.InvariantCulture);
            var chars = await _db.GetCharactersAsync(session.Login);
            var selected = chars.FirstOrDefault(c => c.Slot == slot);
            if (selected is null || selected.Character is null)
                return;
            session.CharacterSlot = slot;
            session.Character = selected.Character;
            session.IsPlaying = true;
            _network.SendText(id, PacketCodec.Compose("ingame"));
            _network.SendText(id, PacketCodec.Compose("playerdata", selected.Character.Name, selected.Character.Level, selected.Character.Map, selected.Character.X, selected.Character.Y, selected.Character.Direction));
        }

        private async Task SendCharactersAsync(int id, string login)
        {
            var chars = await _db.GetCharactersAsync(login);
            var args = new List<object>();
            for (int slot = 1; slot <= GameLimits.MaxCharacters; slot++)
            {
                var c = chars.FirstOrDefault(x => x.Slot == slot);
                args.Add((c?.Name) ?? "");
            }
            _network.SendText(id, PacketCodec.Compose("chars", args.ToArray()));
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