using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;

namespace XtremeWorlds.Client.Engine.Networking;

/// <summary>
/// Preserves the original XtremeWorlds payload grammar inside Mirror/Telepathy
/// messages.  Telepathy supplies message framing; the legacy NUL separators are
/// kept so the server-side packet handlers can be ported with minimal changes.
/// </summary>
public static class XtremeWorldsPacketCodec
{
    public const char Separator = '\0';
    public const char LegacyEnd = (char)237;

    public static string Build(string command, params object?[] values)
    {
        var sb = new StringBuilder(command ?? string.Empty);
        foreach (var value in values)
        {
            sb.Append(Separator);
            sb.Append(ToInvariantString(value));
        }
        // Keep END_CHAR in the payload during the server migration.  Telepathy
        // already frames messages, so a Mirror-converted server may ignore it.
        sb.Append(LegacyEnd);
        return sb.ToString();
    }

    public static IReadOnlyList<string> Parse(string packet)
    {
        packet ??= string.Empty;
        if (packet.Length > 0 && packet[^1] == LegacyEnd)
            packet = packet[..^1];
        return packet.Split(Separator, StringSplitOptions.None);
    }

    private static string ToInvariantString(object? value)
    {
        if (value is null) return string.Empty;
        return value switch
        {
            IFormattable formattable => formattable.ToString(null, CultureInfo.InvariantCulture) ?? string.Empty,
            _ => value.ToString() ?? string.Empty
        };
    }
}
