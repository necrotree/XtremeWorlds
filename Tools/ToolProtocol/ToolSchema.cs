using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text.Json.Nodes;
using Microsoft.VisualBasic;

namespace XtremeWorlds.Tools
{
    public sealed class ToolField
    {
        public ToolField(string control, string key, string kind, int minimum, int maximum, string catalog)
        {
            Control = control;
            Key = key;
            Kind = kind;
            Minimum = minimum;
            Maximum = maximum;
            Catalog = catalog;
        }
        public string Control { get; private set; }
        public string Key { get; private set; }
        public string Kind { get; private set; }
        public int Minimum { get; private set; }
        public int Maximum { get; private set; }
        public string Catalog { get; private set; }
    }

    public class ContentSlot
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public override string ToString()
        {
            return Id.ToString(CultureInfo.InvariantCulture) + ": " + Name;
        }
    }

    public class ToolRecord
    {
        public string Kind { get; set; } = "";
        public int Id { get; set; }
        public JsonObject Data { get; set; } = new JsonObject();
        public Dictionary<string, List<ContentSlot>> Catalogs { get; set; } = new Dictionary<string, List<ContentSlot>>();
    }

    public sealed class ToolSchema
    {
        public static ToolField[] Fields(string kind)
        {
            switch (kind ?? "")
            {
                case "arrow":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 240, ""), new ToolField("scrlSprite", "Sprite", "number", 0, 32767, ""), new ToolField("scrlRange", "Range", "number", 0, 32, "") };
                    }
                case "book":
                    {
                        return new ToolField[] { new ToolField("txtBookTitle", "Name", "text", 0, 25, ""), new ToolField("txtBookHeader", "Header", "text", 0, 25, ""), new ToolField("txtPage1", "Page1", "text", 0, 32767, ""), new ToolField("txtPage2", "Page2", "text", 0, 32767, ""), new ToolField("cmbBook", "NextBook", "number", 0, 32767, "book"), new ToolField("cmbQuest", "Quest", "number", 0, 4096, "quest") };
                    }
                case "quest":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 240, ""), new ToolField("cmbNpc", "Npc", "number", 0, 32767, "npc"), new ToolField("txtNpcSay", "NpcSay", "text", 0, 240, ""), new ToolField("txtCompleted", "Completed", "text", 0, 240, ""), new ToolField("txtHadItem", "HadItem", "text", 0, 240, ""), new ToolField("txtNotReady", "NotReady", "text", 0, 240, ""), new ToolField("txtNotHadItem", "NotHadItem", "text", 0, 240, ""), new ToolField("cmbClassReq", "ClassReq", "number", 0, 256, "class"), new ToolField("scrlLevel", "LevelReq", "number", 0, 32767, ""), new ToolField("cmbQuest", "NextQuest", "number", 0, 4096, "quest"), new ToolField("chkHealth", "Health", "flag", 0, 1, ""), new ToolField("chkMana", "Mana", "flag", 0, 1, ""), new ToolField("chkStamina", "Stamina", "flag", 0, 1, ""), new ToolField("chkOnce", "Once", "flag", 0, 1, ""), new ToolField("cmbItemHas_0", "ItemHas", "number", 0, 32767, "item"), new ToolField("txtItemHasValue_0", "ItemHasValue", "number", 0, 2147483647, ""), new ToolField("cmbItemGet", "ItemGet", "number", 0, 32767, "item"), new ToolField("txtItemGetValue", "ItemGetValue", "number", 0, 2147483647, ""), new ToolField("txtExpGet", "ExpGet", "number", 0, 2147483647, "") };
                    }
                case "emote":
                    {
                        return new ToolField[] { new ToolField("txtCommand", "Command", "text", 0, 32, ""), new ToolField("scrlSprite", "Sprite", "number", 1, 32767, "") };
                    }
                case "item":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 240, ""), new ToolField("scrlPic", "Pic", "number", 0, 32767, ""), new ToolField("cmbType", "Type", "number", 0, 15, "") };
                    }
                case "npc":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 240, ""), new ToolField("txtAttackSay", "AttackSay", "text", 0, 240, ""), new ToolField("scrlSprite", "Sprite", "number", 0, 32767, ""), new ToolField("txtSpawnSecs", "SpawnSecs", "number", 0, 2147483647, ""), new ToolField("cmbBehavior", "Behavior", "number", 0, 5, ""), new ToolField("scrlRange", "Range", "number", 0, 255, ""), new ToolField("txtChance", "DropChance", "number", 0, 32767, ""), new ToolField("scrlNum", "DropItem", "number", 0, 32767, ""), new ToolField("scrlValue", "DropItemValue", "number", 0, 2147483647, ""), new ToolField("scrlSTR", "Strength", "number", 0, 255, ""), new ToolField("scrlDEF", "Defense", "number", 0, 255, ""), new ToolField("scrlSPEED", "Speed", "number", 0, 255, ""), new ToolField("scrlMAGI", "Magic", "number", 0, 255, ""), new ToolField("txtMaxHP", "MaxHP", "number", 1, 2147483647, ""), new ToolField("txtGiveEXP", "GiveEXP", "number", 0, 2147483647, "") };
                    }
                case "spell":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 240, ""), new ToolField("cmbClassReq", "ClassReq", "number", 0, 256, "class"), new ToolField("scrlLevelReq", "LevelReq", "number", 0, 32767, ""), new ToolField("scrlMP", "MPReq", "number", 0, 2147483647, ""), new ToolField("cmbType", "Type", "number", 0, 7, ""), new ToolField("scrlAnim", "Graphic", "number", 0, 32767, "") };
                    }
                case "class":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 240, ""), new ToolField("scrlMSprite", "MaleSprite", "number", 0, 32767, ""), new ToolField("scrlFSprite", "FemaleSprite", "number", 0, 32767, ""), new ToolField("scrlSTR", "Strength", "number", 0, 255, ""), new ToolField("scrlDEF", "Defense", "number", 0, 255, ""), new ToolField("scrlSPD", "Speed", "number", 0, 255, ""), new ToolField("scrlMAGI", "Magic", "number", 0, 255, ""), new ToolField("scrlMap", "Map", "number", 0, 32767, ""), new ToolField("scrlX", "X", "number", 0, 15, ""), new ToolField("scrlY", "Y", "number", 0, 11, "") };
                    }
                case "shop":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 240, ""), new ToolField("txtJoinSay", "JoinSay", "text", 0, 240, ""), new ToolField("txtLeaveSay", "LeaveSay", "text", 0, 240, ""), new ToolField("chkFixesItems", "FixesItems", "flag", 0, 1, "") };
                    }
                case "sign":
                    {
                        return new ToolField[] { new ToolField("txtSignName", "Name", "text", 0, 240, ""), new ToolField("txtSignLine1", "Line1", "text", 0, 240, ""), new ToolField("txtSignLine2", "Line2", "text", 0, 240, ""), new ToolField("txtSignLine3", "Line3", "text", 0, 240, "") };
                    }
                case "map":
                    {
                        return new ToolField[] { new ToolField("txtName", "Name", "text", 0, 50, ""), new ToolField("scrlTileset", "Tileset", "number", 1, 9, "") };
                    }

                default:
                    {
                        throw new ArgumentException("Unknown editor kind.", nameof(kind));
                    }
            }
        }

        public static string Validate(string kind, int id, JsonObject data)
        {
            if (data is null)
                return "No definition was supplied.";
            foreach (var @field in Fields(kind))
            {
                var node = data[@field.Key];
                if (node is null)
                    return "Missing field: " + @field.Key;
                if (@field.Kind == "text")
                {
                    string value;
                    try
                    {
                        value = node.GetValue<string>();
                    }
                    catch (InvalidOperationException ex)
                    {
                        return @field.Key + " must be text.";
                    }
                    if (value.Length > @field.Maximum || value.Contains('\0') || value.Contains('\u0001') || value.Contains(Strings.ChrW(237)))
                        return @field.Key + " contains unsupported characters or is too long.";
                    if (kind == "quest" && (value.Contains(Constants.vbCr) || value.Contains(Constants.vbLf)))
                        return "Quest fields must be single lines.";
                }
                else
                {
                    int value;
                    if (!int.TryParse(node.ToString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out value) || value < @field.Minimum || value > @field.Maximum)
                        return @field.Key + " is outside its allowed range.";
                }
            }
            if (kind == "book" && Number(data, "NextBook") == id)
                return "Choose a different connecting book.";
            if (kind == "emote")
            {
                string command = Text(data, "Command").Trim();
                if (command.Length < 2 || !command.StartsWith("/", StringComparison.Ordinal))
                    return "Enter a command starting with /, such as /smile.";
            }
            return null;
        }

        public static int Number(JsonObject data, string key, int fallback = 0)
        {
            int value;
            if (data[key] is null || !int.TryParse(data[key].ToString(), NumberStyles.Integer, CultureInfo.InvariantCulture, out value))
                return fallback;
            return value;
        }
        public static string Text(JsonObject data, string key)
        {
            return (data[key]?.ToString()) ?? "";
        }
    }
}