using System;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace Server
{

    public sealed class SpacetimeHttpClient : IDisposable
    {

        private readonly HttpClient _http;
        private readonly string _baseUri;
        private readonly string _database;

        public SpacetimeHttpClient(ServerSettings settings)
        {
            _http = new HttpClient
            {
                Timeout = TimeSpan.FromSeconds(Math.Max(1, settings.SpacetimeConnectTimeoutSeconds))
            };
            _baseUri = settings.SpacetimeUri.TrimEnd('/');
            _database = Uri.EscapeDataString(settings.SpacetimeDatabase);
            if (!string.IsNullOrWhiteSpace(settings.SpacetimeToken))
            {
                _http.DefaultRequestHeaders.Authorization =
                    new AuthenticationHeaderValue("Bearer", settings.SpacetimeToken);
            }
            else if (!string.IsNullOrWhiteSpace(settings.SpacetimeUsername))
            {
                string credentials = Convert.ToBase64String(
                    Encoding.UTF8.GetBytes($"{settings.SpacetimeUsername}:{settings.SpacetimePassword}"));
                _http.DefaultRequestHeaders.Authorization =
                    new AuthenticationHeaderValue("Basic", credentials);
            }
        }

        public void SetBearerToken(string token)
        {
            if (string.IsNullOrWhiteSpace(token))
                return;

            _http.DefaultRequestHeaders.Authorization =
                new AuthenticationHeaderValue("Bearer", token.Trim());
        }

        public async Task PingAsync(System.Threading.CancellationToken ct)
        {
            using (var response = await _http.GetAsync(_baseUri + "/v1/ping", ct))
            {
                response.EnsureSuccessStatusCode();
            }
        }

        public async Task<bool> DatabaseExistsAsync(System.Threading.CancellationToken ct = default)
        {
            string url = $"{_baseUri}/v1/database/{_database}";
            using var response = await _http.GetAsync(url, ct);
            if (response.StatusCode == System.Net.HttpStatusCode.NotFound)
                return false;

            response.EnsureSuccessStatusCode();
            return true;
        }

        public async Task CallReducerAsync(string name, object[] args, System.Threading.CancellationToken ct = default)
        {
            string url = $"{_baseUri}/v1/database/{_database}/call/{Uri.EscapeDataString(name)}";
            byte[] body = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(args));

            using var request = new HttpRequestMessage(HttpMethod.Post, url);
            request.Content = new ByteArrayContent(body);
            request.Content.Headers.ContentType = new MediaTypeHeaderValue("application/json");

            using (var response = await _http.SendAsync(request, ct))
            {
                string result = await response.Content.ReadAsStringAsync(ct);
                if (!response.IsSuccessStatusCode)
                    throw new InvalidOperationException($"SpacetimeDB reducer {name} failed ({(int)response.StatusCode}): {result}");
            }
        }

        public async Task<JsonDocument> SqlAsync(string sql, System.Threading.CancellationToken ct = default)
        {
            string url = $"{_baseUri}/v1/database/{_database}/sql";
            using (var content = new StringContent(sql, Encoding.UTF8, "text/plain"))
            {
                using (var response = await _http.PostAsync(url, content, ct))
                {
                    string result = await response.Content.ReadAsStringAsync(ct);
                    if (!response.IsSuccessStatusCode)
                        throw new InvalidOperationException($"SpacetimeDB SQL failed ({(int)response.StatusCode}): {result}");
                    return JsonDocument.Parse(result);
                }
            }
        }

        public void Dispose()
        {
            _http.Dispose();
        }
    }
}