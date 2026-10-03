using System;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Sockets;
using System.Threading;
using System.Threading.Tasks;

namespace Server;

public static class PublicIpResolver
{
    private static readonly string[] Services =
    {
        "https://api.ipify.org",
        "https://ipv4.icanhazip.com"
    };

    public static async Task<string> ResolveAsync(CancellationToken cancellationToken = default)
    {
        using var client = new HttpClient
        {
            Timeout = TimeSpan.FromSeconds(4)
        };

        foreach (string service in Services)
        {
            try
            {
                string value = (await client.GetStringAsync(service, cancellationToken).ConfigureAwait(false)).Trim();
                if (IPAddress.TryParse(value, out var address) && address.AddressFamily == AddressFamily.InterNetwork)
                    return address.ToString();
            }
            catch
            {
                // Try the next public-IP service, then fall back to a LAN IPv4 address.
            }
        }

        try
        {
            return Dns.GetHostEntry(Dns.GetHostName())
                .AddressList
                .FirstOrDefault(a => a.AddressFamily == AddressFamily.InterNetwork && !IPAddress.IsLoopback(a))
                ?.ToString() ?? "Unavailable";
        }
        catch
        {
            return "Unavailable";
        }
    }
}
