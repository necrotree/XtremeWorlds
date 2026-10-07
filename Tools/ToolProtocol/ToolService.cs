using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json.Nodes;
using System.Threading.Tasks;

namespace XtremeWorlds.Tools
{
    // VB.NET port of the master editor list/load/save lifecycle, backed by the host's content repository.
    public sealed class ToolService
    {
        private readonly Func<int, int> access;
        private readonly Func<string, Task<Dictionary<int, JsonObject>>> load;
        private readonly Func<string, int, JsonObject, Task> persist;
        private readonly Action<int, string, object[]> send;
        private readonly IReadOnlyDictionary<string, int> limits;
        public ToolService(Func<int, int> access, Func<string, Task<Dictionary<int, JsonObject>>> load, Func<string, int, JsonObject, Task> persist, Action<int, string, object[]> send, IReadOnlyDictionary<string, int> limits)
        {
            this.access = access;
            this.load = load;
            this.persist = persist;
            this.send = send;
            this.limits = limits;
        }
        public static bool Recognizes(string command)
        {
            return command == "requesttool" || command == "edittool" || command == "savetool" || command == "toolaccess";
        }
        public async Task HandleAsync(int connection, string[] parts)
        {
            if (parts.Length == 0 || !Recognizes(parts[0]))
                return;
            if (parts[0] == "toolaccess")
            {
                send(connection, "toolaccess", new object[] { access(connection) });
                return;
            }
            if (parts.Length < 3)
                return;
            string command = parts[0];
            string kind = parts[1];
            string request = parts[parts.Length - 1];
            if (request.Length > 64)
                return;
            int entry = 0;
            string failure = null;
            try
            {
                if (!limits.ContainsKey(kind))
                    throw new ArgumentException("Unknown editor kind.");
                int minimumAccess = kind == "sign" || kind == "map" ? 2 : 3;
                if (access(connection) < minimumAccess)
                    throw new UnauthorizedAccessException("Your access level does not permit this editor.");
                var records = await load(kind);
                if (access(connection) < minimumAccess)
                    throw new UnauthorizedAccessException("Your editor access has changed.");
                if (command == "requesttool")
                {
                    if (parts.Length != 3)
                        throw new ArgumentException("Malformed editor request.");
                    send(connection, "toolindex", new object[] { kind, ToolWire.Encode(Slots(kind, records)), request });
                    return;
                }
                if (parts.Length < 4 || !int.TryParse(parts[2], NumberStyles.None, CultureInfo.InvariantCulture, out entry) || !ValidId(kind, entry))
                    throw new ArgumentException("Invalid content slot.");
                if (command == "edittool")
                {
                    if (parts.Length != 4)
                        throw new ArgumentException("Malformed editor request.");
                    JsonObject data = null;
                    records.TryGetValue(entry, out data);
                    data = Defaults(kind, data ?? new JsonObject());
                    var @record = new ToolRecord() { Kind = kind, Id = entry, Data = data };
                    var catalogKinds = ToolSchema.Fields(kind).Select(@field => @field.Catalog).Where(value => value.Length > 0).ToHashSet();
                    if (kind == "item" || kind == "shop" || kind == "npc")
                    {
                        catalogKinds.Add("item");
                        catalogKinds.Add("spell");
                        catalogKinds.Add("book");
                    }
                    if (kind == "npc")
                    {
                        catalogKinds.Add("quest");
                        catalogKinds.Add("shop");
                    }
                    if (kind == "spell")
                        catalogKinds.Add("arrow");
                    foreach (var catalog in catalogKinds)
                        @record.Catalogs[catalog] = Slots(catalog, (catalog ?? "") == (kind ?? "") ? records : await load(catalog));
                    send(connection, "toolrecord", new object[] { kind, entry, ToolWire.Encode(@record), request });
                    return;
                }
                if (parts.Length != 5)
                    throw new ArgumentException("Malformed save request.");
                var updated = ToolWire.Decode<ToolRecord>(parts[3]);
                if (updated is null || (updated.Kind ?? "") != (kind ?? "") || updated.Id != entry)
                    throw new ArgumentException("The save belongs to a different definition.");
                string errorMessage = ToolSchema.Validate(kind, entry, updated.Data);
                if (errorMessage is not null)
                    throw new ArgumentException(errorMessage);
                ValidateAdditional(kind, updated.Data);
                // Preserve properties not edited by this tool, such as quest progress and shop inventory.
                JsonObject existing = null;
                records.TryGetValue(entry, out existing);
                var merged = existing is null ? new JsonObject() : (JsonObject)existing.DeepClone();
                foreach (var @field in ToolSchema.Fields(kind))
                    merged[@field.Key] = updated.Data[@field.Key].DeepClone();
                foreach (var key in AdditionalKeys(kind))
                {
                    if (updated.Data[key] is not null)
                        merged[key] = updated.Data[key].DeepClone();
                }
                if (kind == "book")
                {
                    merged["Pages"] = new JsonArray(merged["Page1"].DeepClone(), merged["Page2"].DeepClone());
                    merged["PageCount"] = JsonValue.Create(2);
                }
                await persist(kind, entry, merged);
                send(connection, "toolsaved", new object[] { kind, entry, request });
                return;
            }
            catch (Exception ex)
            {
                failure = ex is ArgumentException || ex is UnauthorizedAccessException ? ex.Message : "The definition could not be loaded or saved. Please try again.";
            }
            send(connection, "toolerror", new object[] { kind, entry, failure, request });
        }
        private bool ValidId(string kind, int id)
        {
            return id >= (kind == "class" ? 0 : 1) && id <= limits[kind];
        }
        private List<ContentSlot> Slots(string kind, Dictionary<int, JsonObject> records)
        {
            var result = new List<ContentSlot>();
            for (int id = kind == "class" ? 0 : 1, loopTo = limits[kind]; id <= loopTo; id++)
            {
                JsonObject data = null;
                records.TryGetValue(id, out data);
                result.Add(new ContentSlot() { Id = id, Name = data is null ? "" : ToolSchema.Text(data, kind == "emote" ? "Command" : "Name") });
            }
            return result;
        }
        public static JsonObject Defaults(string kind, JsonObject original)
        {
            JsonObject data = (JsonObject)original.DeepClone();
            foreach (var @field in ToolSchema.Fields(kind))
            {
                if (data[@field.Key] is not null)
                    continue;
                if (@field.Kind == "text")
                {
                    data[@field.Key] = JsonValue.Create("");
                }
                else
                {
                    data[@field.Key] = JsonValue.Create(@field.Minimum);
                }
            }
            foreach (var key in AdditionalKeys(kind))
            {
                if (new[] { "Trades", "Tiles", "LayerTileset" }.Contains(key))
                    continue;
                if (data[key] is null)
                    data[key] = JsonValue.Create(key == "CastRange" ? 32 : 0);
            }
            if (kind == "map")
            {
                if (ToolSchema.Number(data, "Tileset") < 1)
                    data["Tileset"] = JsonValue.Create(1);
                MapEditing.PreserveTilesets(data);
            }
            if (kind == "shop")
            {
                JsonArray trades = data["Trades"] as JsonArray;
                if (trades is null)
                {
                    trades = new JsonArray();
                    data["Trades"] = trades;
                }
                while (trades.Count < 8)
                    trades.Add(new JsonObject());
                foreach (var node in trades)
                {
                    JsonObject trade = (JsonObject)node;
                    foreach (var key in new[] { "GiveItem", "GiveItem2", "GetItem", "GiveValue", "GiveValue2", "GetValue" })
                    {
                        if (trade[key] is null)
                            trade[key] = JsonValue.Create(0);
                    }
                }
            }
            if (kind == "book")
            {
                JsonArray pages = data["Pages"] as JsonArray;
                if (pages is not null && pages.Count > 0)
                    data["Page1"] = pages[0]?.DeepClone();
                if (pages is not null && pages.Count > 1)
                    data["Page2"] = pages[1]?.DeepClone();
            }
            return data;
        }
        public static string[] AdditionalKeys(string kind)
        {
            switch (kind ?? "")
            {
                case "map":
                    {
                        return new[] { "Tiles", "LayerTileset" };
                    }
                case "item":
                    {
                        return new[] { "Data1", "Data2", "Data3" };
                    }
                case "npc":
                    {
                        return new[] { "ShopCall" };
                    }
                case "spell":
                    {
                        return new[] { "Data1", "Data2", "Data3", "DeliveryMode", "Arrow", "CastRange" };
                    }
                case "shop":
                    {
                        return new[] { "Trades" };
                    }
                case "sign":
                    {
                        return new[] { "Background" };
                    }

                default:
                    {
                        return Array.Empty<string>();
                    }
            }
        }
        private void ValidateAdditional(string kind, JsonObject data)
        {
            foreach (var key in AdditionalKeys(kind))
            {
                if (kind == "map")
                {
                    JsonArray layerSources = data["LayerTileset"] as JsonArray;
                    if (data["LayerTileset"] is not null)
                    {
                        if (layerSources is null || layerSources.Count > 9)
                            throw new ArgumentException("Invalid map layers.");
                        foreach (var source in layerSources)
                        {
                            int number;
                            if (source is null || !int.TryParse(source.ToString(), out number) || number < 0 || number > 9)
                                throw new ArgumentException("Invalid map layer source.");
                        }
                    }
                    JsonArray tiles = data["Tiles"] as JsonArray;
                    if (tiles is null || tiles.Count != MapEditing.Width * MapEditing.Height)
                        throw new ArgumentException("A map must have 192 tiles.");
                    foreach (var node in tiles)
                    {
                        JsonObject tile = node as JsonObject;
                        if (tile is null)
                            throw new ArgumentException("Invalid map tile.");
                        foreach (var pair in tile)
                        {
                            if (pair.Key == "LayerTileset")
                            {
                                JsonArray sources = pair.Value as JsonArray;
                                if (sources is null || sources.Count != 9)
                                    throw new ArgumentException("Invalid tile sources.");
                                foreach (var source in sources)
                                {
                                    int value;
                                    if (source is null || !int.TryParse(source.ToString(), out value) || value < 0 || value > 9)
                                        throw new ArgumentException("Invalid tileset.");
                                }
                            }
                            else
                            {
                                int maximum = pair.Key.StartsWith("Type", StringComparison.Ordinal) ? 14 : MapEditing.Layers.Contains(pair.Key) ? 32767 : int.MaxValue;
                                RequireNumber(tile, pair.Key, 0, maximum);
                            }
                        }
                    }
                    return;
                }
                else if (key == "Trades")
                {
                    JsonArray trades = data[key] as JsonArray;
                    if (trades is null || trades.Count != 8)
                        throw new ArgumentException("A shop must have eight trade slots.");
                    foreach (var node in trades)
                    {
                        JsonObject trade = node as JsonObject;
                        if (trade is null)
                            throw new ArgumentException("Invalid trade slot.");
                        foreach (var item in new[] { "GiveItem", "GiveItem2", "GetItem", "GiveValue", "GiveValue2", "GetValue" })
                            RequireNumber(trade, item, 0, item.Contains("Item") ? limits["item"] : int.MaxValue);
                    }
                }
                else
                {
                    int maximum = key == "Background" || key == "DeliveryMode" ? 1 : int.MaxValue;
                    if (key == "CastRange")
                        maximum = 32;
                    RequireNumber(data, key, key == "CastRange" ? 1 : 0, maximum);
                }
            }
            if (kind == "spell" && ToolSchema.Number(data, "DeliveryMode") == 1 && ToolSchema.Number(data, "Arrow") < 1)
                throw new ArgumentException("Choose an arrow for projectile delivery.");
            foreach (var @field in ToolSchema.Fields(kind))
            {
                if (@field.Catalog.Length > 0)
                {
                    int value = ToolSchema.Number(data, @field.Key);
                    if (value > limits[@field.Catalog] + (@field.Key == "ClassReq" ? 1 : 0))
                        throw new ArgumentException(@field.Key + " refers to an invalid content slot.");
                }
            }
            if (kind == "npc")
                RequireNumber(data, "ShopCall", 0, ToolSchema.Number(data, "Behavior") == 5 ? limits["quest"] : limits["shop"]);
            if (kind == "item" && ToolSchema.Number(data, "Type") == 15)
                RequireNumber(data, "Data1", 1, limits["book"]);
        }
        private static void RequireNumber(JsonObject data, string key, int minimum, int maximum)
        {
            int value;
            if (data[key] is null || !int.TryParse(data[key].ToString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out value) || value < minimum || value > maximum)
                throw new ArgumentException(key + " is outside its allowed range.");
        }
    }
}