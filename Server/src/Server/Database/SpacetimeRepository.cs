using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;

namespace Server
{

    public sealed class SpacetimeRepository : IDisposable
    {

        private readonly SpacetimeHttpClient _client;

        public SpacetimeRepository(ServerSettings settings)
        {
            _client = new SpacetimeHttpClient(settings);
        }

        public Task PingAsync(System.Threading.CancellationToken ct)
        {
            return _client.PingAsync(ct);
        }

        public Task<bool> DatabaseExistsAsync(System.Threading.CancellationToken ct)
        {
            return _client.DatabaseExistsAsync(ct);
        }

        public void SetBearerToken(string token)
        {
            _client.SetBearerToken(token);
        }

        public async Task VerifyPrivateTableAccessAsync(System.Threading.CancellationToken ct)
        {
            using var doc = await _client.SqlAsync("SELECT login FROM account LIMIT 1", ct);
        }

        private static string Q(string value)
        {
            return "'" + value.Replace("'", "''") + "'";
        }

        public async Task<bool> AccountExistsAsync(string login)
        {
            using (var doc = await _client.SqlAsync($"SELECT login FROM account WHERE login = {Q(login)} LIMIT 1"))
            {
                return HasRows(doc);
            }
        }

        public async Task<AccountRecord> GetAccountAsync(string login)
        {
            using (var doc = await _client.SqlAsync($"SELECT login, password_hash, password_salt, enc_key FROM account WHERE login = {Q(login)} LIMIT 1"))
            {
                var row = FirstRow(doc);
                if (row is null)
                    return null;
                return new AccountRecord()
                {
                    Login = row.Value[0].GetString(),
                    PasswordHash = row.Value[1].GetString(),
                    PasswordSalt = row.Value[2].GetString(),
                    EncKey = row.Value[3].GetString()
                };
            }
        }

        public async Task CreateAccountAsync(string login, string password, string encKey)
        {
            var p = PasswordHasher.Create(password);
            await _client.CallReducerAsync("upsert_account", new[] { login, p.Hash, p.Salt, encKey });
        }

        public async Task SaveCharacterAsync(string login, int slot, PlayerCharacter character)
        {
            string key = $"{login.ToLowerInvariant()}:{slot}";
            string json = JsonSerializer.Serialize(character);
            await _client.CallReducerAsync("upsert_character", new object[] { key, login, slot, character.Name, json });
        }

        public async Task<List<CharacterRow>> GetCharactersAsync(string login)
        {
            var result = new List<CharacterRow>();
            using (var doc = await _client.SqlAsync($"SELECT slot, name, json FROM character WHERE account_login = {Q(login)}"))
            {
                foreach (var row in Rows(doc))
                    result.Add(new CharacterRow()
                    {
                        Slot = row[0].GetInt32(),
                        Name = row[1].GetString(),
                        Character = JsonSerializer.Deserialize<PlayerCharacter>(row[2].GetString())
                    });
            }
            return result.OrderBy(character => character.Slot).ToList();
        }

        public async Task DeleteCharacterAsync(string login, int slot)
        {
            string key = $"{login.ToLowerInvariant()}:{slot}";
            await _client.CallReducerAsync("delete_character", new[] { key });
        }

        public async Task UpsertContentAsync(string kind, int id, string name, object value, int revision = 0)
        {
            string key = $"{kind.ToLowerInvariant()}:{id}";
            string json = JsonSerializer.Serialize(value);
            await _client.CallReducerAsync("upsert_content", new object[] { key, kind.ToLowerInvariant(), id, name, json, revision });
        }

        public async Task<Dictionary<int, T>> LoadContentAsync<T>(string kind)
        {
            var output = new Dictionary<int, T>();
            using (var doc = await _client.SqlAsync($"SELECT numeric_id, json FROM content WHERE kind = {Q(kind.ToLowerInvariant())}"))
            {
                foreach (var row in Rows(doc))
                {
                    var value = JsonSerializer.Deserialize<T>(row[1].GetString());
                    if (value is not null)
                        output[row[0].GetInt32()] = value;
                }
            }
            return output;
        }

        public async Task<bool> IsBannedAsync(string ip, string hardwareId)
        {
            using (var doc = await _client.SqlAsync($"SELECT ban_key FROM ban WHERE ip = {Q(ip)} OR hardware_id = {Q(hardwareId)} LIMIT 1"))
            {
                return HasRows(doc);
            }
        }

        public async Task AddBanAsync(BanDefinition ban)
        {
            string key = Guid.NewGuid().ToString("N");
            await _client.CallReducerAsync("upsert_ban", new[] { key, ban.BannedIP, ban.BannedCharacter, ban.BannedBy, ban.BannedHardwareId });
        }

        private static bool HasRows(JsonDocument doc)
        {
            return Rows(doc).Any();
        }

        private static JsonElement? FirstRow(JsonDocument doc)
        {
            return Rows(doc).Cast<JsonElement?>().FirstOrDefault();
        }

        private static IEnumerable<JsonElement> Rows(JsonDocument doc)
        {
            if (doc.RootElement.ValueKind != JsonValueKind.Array)
                yield break;
            foreach (var statement in doc.RootElement.EnumerateArray())
            {
                JsonElement rowsElement;
                if (statement.TryGetProperty("rows", out rowsElement) && rowsElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var row in rowsElement.EnumerateArray())
                        yield return row;
                }
            }
        }

        public void Dispose()
        {
            _client.Dispose();
        }
    }

    public class AccountRecord
    {
        public string Login { get; set; } = "";
        public string PasswordHash { get; set; } = "";
        public string PasswordSalt { get; set; } = "";
        public string EncKey { get; set; } = "";
    }

    public class CharacterRow
    {
        public int Slot { get; set; }
        public string Name { get; set; } = "";
        public PlayerCharacter Character { get; set; }
    }
}
