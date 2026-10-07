using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json.Nodes;
using Eto.Drawing;
using Eto.Forms;
using Microsoft.VisualBasic;
using XtremeWorlds.Tools;

namespace XtremeWorlds.Client.Tools
{
    public partial class frmBookEditor
    {
        protected override void InitializeTool()
        {
            base.InitializeTool();
            WireButton("cmdPreview", PreviewBook);
        }
        private void PreviewBook()
        {
            string header = string.IsNullOrEmpty(txtBookHeader.Text) ? txtBookTitle.Text : txtBookHeader.Text;
            using (var preview = new Dialog())
            {
                preview.Title = header;
                preview.ClientSize = new Size(650, 440);
                var pages = new TableLayout() { Padding = 12, Spacing = new Size(12, 8) };
                pages.Rows.Add(new TableRow(new TableCell(new TextArea() { Text = txtPage1.Text, ReadOnly = true }, true), new TableCell(new TextArea() { Text = txtPage2.Text, ReadOnly = true }, true)) { ScaleHeight = true });
                var back = new Button() { Text = "Return to editor" };
                back.Click += (sender, args) => preview.Close();
                pages.Rows.Add(new TableRow(back));
                preview.Content = pages;
                preview.ShowModal(this);
            }
        }
        protected override void StoreAdditional(JsonObject data)
        {
            data["Pages"] = new JsonArray(JsonValue.Create(txtPage1.Text), JsonValue.Create(txtPage2.Text));
            data["PageCount"] = JsonValue.Create(2);
        }
    }

    public partial class frmArrowEditor
    {
        protected override void RefreshTool()
        {
            base.RefreshTool();
            picIcon.SetFrame("arrows.png", 0, scrlSprite.Value * 32, 32, 32);
            picPreview.SetFrame("arrows.png", 0, scrlSprite.Value * 32, 128, 32);
        }
    }

    public partial class frmEmoticonEditor
    {
        protected override void RefreshTool()
        {
            base.RefreshTool();
            int index = scrlSprite.Value - 1;
            if (index < 0)
            {
                picIcon.SetFrame("emote.png", 0, 0, 0, 0);
            }
            else
            {
                picIcon.SetFrame("emote.png", index % 6 * 32, index / 6 * 32, 32, 32);
            }
        }
    }

    public partial class frmNpcEditor
    {
        protected override void InitializeTool()
        {
            base.InitializeTool();
            cmbBehavior.Items.Add("Quest giver");
        }
        protected override void PopulateCatalogs()
        {
            base.PopulateCatalogs();
            PopulateCombo("cmbQuestId", "quest");
            PopulateCombo("cmbShop", "shop");
            List<ContentSlot> items = null;
            if (Definition.Catalogs.TryGetValue("item", out items) && items.Count > 0)
                scrlNum.MaxValue = items.Max(slot => slot.Id);
            scrlValue.MaxValue = int.MaxValue;
        }
        protected override void LoadAdditional(JsonObject data)
        {
            SetValue(cmbBehavior.SelectedIndex == 5 ? "cmbQuestId" : "cmbShop", ToolSchema.Number(data, "ShopCall").ToString(CultureInfo.InvariantCulture));
        }
        protected override void StoreAdditional(JsonObject data)
        {
            data["ShopCall"] = JsonValue.Create(Value(cmbBehavior.SelectedIndex == 5 ? "cmbQuestId" : "cmbShop"));
        }
        protected override void RefreshTool()
        {
            base.RefreshTool();
            cmbQuestId.Visible = cmbBehavior.SelectedIndex == 5;
            cmbShop.Visible = cmbBehavior.SelectedIndex == 3;
            lbl17.Visible = cmbShop.Visible || cmbQuestId.Visible;
            lbl17.Text = cmbQuestId.Visible ? "Quest ID" : "Shopkeeper's Shop";
            lblItemName.Text = CatalogName("item", scrlNum.Value);
            imgSprite.SetFrame("sprites.png", 144, scrlSprite.Value * 64, 48, 64);
        }
    }

    public partial class frmItemEditor
    {
        protected override void LoadAdditional(JsonObject data)
        {
            foreach (var name in new[] { "scrlDurability", "scrlVitalMod", "scrlSpell", "scrlBook", "txtMap" })
                SetValue(name, ToolSchema.Number(data, "Data1").ToString(CultureInfo.InvariantCulture));
            foreach (var name in new[] { "scrlStrength", "scrlMapX" })
                SetValue(name, ToolSchema.Number(data, "Data2").ToString(CultureInfo.InvariantCulture));
            SetValue("scrlMapY", ToolSchema.Number(data, "Data3").ToString(CultureInfo.InvariantCulture));
        }
        protected override void StoreAdditional(JsonObject data)
        {
            int first = 0;
            int second = 0;
            int third = 0;
            switch (cmbType.SelectedIndex)
            {
                case var @case when 1 <= @case && @case <= 4:
                    {
                        first = scrlDurability.Value;
                        second = scrlStrength.Value;
                        break;
                    }
                case var case1 when 5 <= case1 && case1 <= 10:
                    {
                        first = scrlVitalMod.Value;
                        break;
                    }
                case 13:
                    {
                        first = scrlSpell.Value;
                        break;
                    }
                case 14:
                    {
                        first = Value("txtMap");
                        second = scrlMapX.Value;
                        third = scrlMapY.Value;
                        break;
                    }
                case 15:
                    {
                        first = scrlBook.Value;
                        break;
                    }

                default:
                    {
                        return;
                    }
            }
            data["Data1"] = JsonValue.Create(first);
            data["Data2"] = JsonValue.Create(second);
            data["Data3"] = JsonValue.Create(third);
        }
        protected override void RefreshTool()
        {
            base.RefreshTool();
            int itemType = cmbType.SelectedIndex;
            fraEquipment.Visible = itemType >= 1 && itemType <= 4;
            fraVitals.Visible = itemType >= 5 && itemType <= 10;
            fraSpell.Visible = itemType == 13;
            fraWarp.Visible = itemType == 14;
            fraBook.Visible = itemType == 15;
            lblSpellName.Text = CatalogName("spell", scrlSpell.Value);
            picPic.SetFrame("items.png", scrlPic.Value % 6 * 32, scrlPic.Value / 6 * 32, 32, 32);
        }
    }

    public partial class frmSpellEditor
    {
        private int animationFrame;
        protected override void InitializeTool()
        {
            base.InitializeTool();
            cmbDelivery.Items.Add("Range cast (selected target)");
            cmbDelivery.Items.Add("Projectile hit");
            cmbDelivery.SelectedIndex = 0;
            picSpells.Visible = false;
            tmrSpellAnim.Elapsed += (sender, args) =>
            {
                animationFrame = (animationFrame + 1) % 16;
                RefreshTool();
            };
        }
        protected override void PopulateCatalogs()
        {
            base.PopulateCatalogs();
            PopulateCombo("cmbArrow", "arrow");
        }
        protected override void LoadAdditional(JsonObject data)
        {
            foreach (var name in new[] { "scrlVitalMod", "scrlItemNum", "txtMap" })
                SetValue(name, ToolSchema.Number(data, "Data1").ToString(CultureInfo.InvariantCulture));
            foreach (var name in new[] { "scrlItemValue", "scrlMapX" })
                SetValue(name, ToolSchema.Number(data, "Data2").ToString(CultureInfo.InvariantCulture));
            SetValue("scrlMapY", ToolSchema.Number(data, "Data3").ToString(CultureInfo.InvariantCulture));
            SetValue("cmbDelivery", ToolSchema.Number(data, "DeliveryMode").ToString(CultureInfo.InvariantCulture));
            SetValue("cmbArrow", ToolSchema.Number(data, "Arrow").ToString(CultureInfo.InvariantCulture));
            SetValue("txtCastRange", ToolSchema.Number(data, "CastRange", 32).ToString(CultureInfo.InvariantCulture));
        }
        protected override void StoreAdditional(JsonObject data)
        {
            int distance = Value("txtCastRange");
            if (distance < 1 || distance > 32)
                throw new ArgumentException("Spell range must be a whole number from 1 to 32 tiles.");
            data["DeliveryMode"] = JsonValue.Create(cmbDelivery.SelectedIndex);
            data["Arrow"] = JsonValue.Create(Value("cmbArrow"));
            data["CastRange"] = JsonValue.Create(distance);
            int first = 0;
            int second = 0;
            int third = 0;
            switch (cmbType.SelectedIndex)
            {
                case 6:
                    {
                        first = scrlItemNum.Value;
                        second = scrlItemValue.Value;
                        break;
                    }
                case 7:
                    {
                        first = Value("txtMap");
                        second = scrlMapX.Value;
                        third = scrlMapY.Value;
                        break;
                    }

                default:
                    {
                        first = scrlVitalMod.Value;
                        break;
                    }
            }
            data["Data1"] = JsonValue.Create(first);
            data["Data2"] = JsonValue.Create(second);
            data["Data3"] = JsonValue.Create(third);
        }
        protected override void RefreshTool()
        {
            base.RefreshTool();
            fraVitals.Visible = cmbType.SelectedIndex < 6;
            fraGiveItem.Visible = cmbType.SelectedIndex == 6;
            fraWarp.Visible = cmbType.SelectedIndex == 7;
            cmbArrow.Enabled = cmbDelivery.SelectedIndex == 1;
            picAnim.SetFrame("spells.png", animationFrame * 32, scrlAnim.Value * 32, 32, 32);
        }
    }

    public partial class frmShopEditor
    {
        private JsonArray trades;
        protected override void InitializeTool()
        {
            base.InitializeTool();
            lstTradeItem.SelectedIndexChanged += (sender, args) => LoadTrade();
            WireButton("cmdUpdate", UpdateTrade);
        }
        protected override void PopulateCatalogs()
        {
            base.PopulateCatalogs();
            foreach (var name in new[] { "cmbItemGive", "cmbitem2Give", "cmbItemGet" })
                PopulateCombo(name, "item");
        }
        protected override void LoadAdditional(JsonObject data)
        {
            trades = data["Trades"]?.DeepClone() as JsonArray;
            if (trades is null)
                trades = new JsonArray();
            while (trades.Count < 8)
                trades.Add(new JsonObject());
            RefreshTrades();
        }
        private void RefreshTrades()
        {
            int selected = Math.Max(0, lstTradeItem.SelectedIndex);
            lstTradeItem.Items.Clear();
            for (int i = 0, loopTo = trades.Count - 1; i <= loopTo; i++)
            {
                JsonObject trade = (JsonObject)trades[i];
                lstTradeItem.Items.Add((i + 1).ToString(CultureInfo.InvariantCulture) + ": " + CatalogName("item", ToolSchema.Number(trade, "GiveItem")) + " for " + CatalogName("item", ToolSchema.Number(trade, "GetItem")));
            }
            lstTradeItem.SelectedIndex = selected;
            LoadTrade();
        }
        private void LoadTrade()
        {
            if (trades is null || lstTradeItem.SelectedIndex < 0 || lstTradeItem.SelectedIndex >= trades.Count)
                return;
            JsonObject trade = (JsonObject)trades[lstTradeItem.SelectedIndex];
            string[] names = new[] { "cmbItemGive", "txtItemGiveValue", "cmbitem2Give", "txtItem2GiveValue", "cmbItemGet", "txtItemGetValue" };
            string[] keys = new[] { "GiveItem", "GiveValue", "GiveItem2", "GiveValue2", "GetItem", "GetValue" };
            for (int i = 0, loopTo = keys.Length - 1; i <= loopTo; i++)
                SetValue(names[i], ToolSchema.Number(trade, keys[i]).ToString(CultureInfo.InvariantCulture));
        }
        private void UpdateTrade()
        {
            if (trades is null || lstTradeItem.SelectedIndex < 0)
                return;
            try
            {
                JsonObject trade = (JsonObject)trades[lstTradeItem.SelectedIndex];
                string[] names = new[] { "cmbItemGive", "txtItemGiveValue", "cmbitem2Give", "txtItem2GiveValue", "cmbItemGet", "txtItemGetValue" };
                string[] keys = new[] { "GiveItem", "GiveValue", "GiveItem2", "GiveValue2", "GetItem", "GetValue" };
                for (int i = 0, loopTo = keys.Length - 1; i <= loopTo; i++)
                {
                    int number = Value(names[i]);
                    if (number < 0)
                        throw new ArgumentException("Trade quantities must be nonnegative.");
                    trade[keys[i]] = JsonValue.Create(number);
                }
                RefreshTrades();
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
        }
        protected override void StoreAdditional(JsonObject data)
        {
            data["Trades"] = trades.DeepClone();
        }
    }

    public partial class frmSignEditor
    {
        protected override void InitializeTool()
        {
            base.InitializeTool();
            WireButton("cmdPrev", PreviewSign);
        }
        protected override void LoadAdditional(JsonObject data)
        {
            optWooden.Checked = ToolSchema.Number(data, "Background") == 0;
            optScroll.Checked = !optWooden.Checked;
        }
        protected override void StoreAdditional(JsonObject data)
        {
            data["Background"] = JsonValue.Create(optWooden.Checked ? 0 : 1);
        }
        private void PreviewSign()
        {
            MessageBox.Show(this, txtSignLine1.Text + Constants.vbLf + txtSignLine2.Text + Constants.vbLf + txtSignLine3.Text, txtSignName.Text);
        }
    }
}