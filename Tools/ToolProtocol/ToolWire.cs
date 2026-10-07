using System;
using System.Text;
using System.Text.Json;

namespace XtremeWorlds.Tools
{
    public sealed class ToolWire
    {
        public static string Encode<T>(T value)
        {
            return Convert.ToBase64String(Encoding.UTF8.GetBytes(JsonSerializer.Serialize(value)));
        }
        public static T Decode<T>(string value)
        {
            if (value.Length > 900000)
                throw new ArgumentException("Editor definition is too large.");
            return JsonSerializer.Deserialize<T>(Encoding.UTF8.GetString(Convert.FromBase64String(value)));
        }
    }
}