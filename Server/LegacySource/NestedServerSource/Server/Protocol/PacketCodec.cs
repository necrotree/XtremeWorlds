using System;
using System.Collections.Generic;
using System.Text;

namespace Server
{

    public static class PacketCodec
    {
        public const char Separator = '\0';
        public const char Terminator = '\u0001';

        public static string Decode(ReadOnlySpan<byte> bytes)
        {
            return Encoding.UTF8.GetString(bytes).TrimEnd(Terminator);
        }

        public static string[] SplitPacket(string data)
        {
            return data.TrimEnd(Terminator).Split(Separator);
        }

        public static string Compose(string command, params object[] args)
        {
            var parts = new List<string>() { command };
            foreach (var value in args)
                parts.Add(value is null ? string.Empty : Convert.ToString(value, System.Globalization.CultureInfo.InvariantCulture));
            return string.Join(Separator, parts) + Terminator;
        }
    }
}