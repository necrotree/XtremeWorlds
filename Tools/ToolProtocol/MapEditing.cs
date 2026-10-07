using System;
using System.Text.Json.Nodes;
using Microsoft.VisualBasic.CompilerServices;

namespace XtremeWorlds.Tools
{
    public sealed class MapEditing
    {
        public static readonly string[] Layers = new[] { "Ground", "Mask", "Anim", "Mask2", "M2Anim", "Fringe", "FAnim", "Fringe2", "F2Anim" };
        public const int Width = 16;
        public const int Height = 12;
        public static JsonArray EnsureTiles(JsonObject map)
        {
            JsonArray tiles = map["Tiles"] as JsonArray;
            if (tiles is null)
            {
                tiles = new JsonArray();
                map["Tiles"] = tiles;
            }
            while (tiles.Count < Width * Height)
                tiles.Add(new JsonObject());
            return tiles;
        }
        public static void PreserveTilesets(JsonObject map)
        {
            JsonArray mapLayers = map["LayerTileset"] as JsonArray;
            int[] oldIndices = new[] { 0, 1, 1, 2, 2, 3, 3, 4, 4 };
            foreach (var node in EnsureTiles(map))
            {
                JsonObject tile = (JsonObject)node;
                JsonArray sources = tile["LayerTileset"] as JsonArray;
                if (sources is null)
                {
                    sources = new JsonArray();
                    tile["LayerTileset"] = sources;
                }
                while (sources.Count < Layers.Length)
                    sources.Add(JsonValue.Create(0));
                for (int layer = 0, loopTo = Layers.Length - 1; layer <= loopTo; layer++)
                {
                    if (Conversions.ToInteger(sources[layer].ToString()) != 0)
                        continue;
                    int inherited = ToolSchema.Number(map, "Tileset", 1);
                    if (mapLayers is not null && oldIndices[layer] < mapLayers.Count && Conversions.ToInteger(mapLayers[oldIndices[layer]].ToString()) > 0)
                        inherited = Conversions.ToInteger(mapLayers[oldIndices[layer]].ToString());
                    sources[layer] = JsonValue.Create(inherited);
                }
            }
        }
        public static void Paint(JsonObject map, int x, int y, int layer, int paletteX, int paletteY, int selectionWidth, int selectionHeight, int tileset, bool isErase)
        {
            if (layer < 0 || layer >= Layers.Length || selectionWidth < 1 || selectionHeight < 1 || tileset < 1 || tileset > 9)
                throw new ArgumentException("Invalid tile brush.");
            PreserveTilesets(map);
            var tiles = EnsureTiles(map);
            for (int dy = 0, loopTo = selectionHeight - 1; dy <= loopTo; dy++)
            {
                for (int dx = 0, loopTo1 = selectionWidth - 1; dx <= loopTo1; dx++)
                {
                    if (x + dx < 0 || x + dx >= Width || y + dy < 0 || y + dy >= Height)
                        continue;
                    JsonObject tile = (JsonObject)tiles[(y + dy) * Width + x + dx];
                    tile[Layers[layer]] = JsonValue.Create(isErase ? 0 : (paletteY + dy) * 12 + paletteX + dx);
                    ((JsonArray)tile["LayerTileset"])[layer] = JsonValue.Create(isErase ? 0 : tileset);
                }
            }
        }
        public static void Attribute(JsonObject map, int x, int y, int layer, int attributeType, int data1, int data2, int data3)
        {
            if (x < 0 || x >= Width || y < 0 || y >= Height)
                return;
            if (layer < 1 || layer > 2 || attributeType < 0 || attributeType > 14)
                throw new ArgumentException("Invalid attribute brush.");
            JsonObject tile = (JsonObject)EnsureTiles(map)[y * Width + x];
            tile[layer == 2 ? "Type2" : "Type"] = JsonValue.Create(attributeType);
            tile[layer == 2 ? "Data21" : "Data1"] = JsonValue.Create(data1);
            tile[layer == 2 ? "Data22" : "Data2"] = JsonValue.Create(data2);
            tile[layer == 2 ? "Data23" : "Data3"] = JsonValue.Create(data3);
        }
    }
}