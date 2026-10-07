using System;
using System.Collections.Generic;
using Eto.Drawing;
using Eto.Forms;

namespace XtremeWorlds.Client.Tools
{
    public partial class frmAdminPanel
    {
        public event Action<string, object[]> ActionRequested;
        public void ApplyAccess(int access)
        {
            fralvl1.Visible = access >= 1;
            fralvl2.Visible = access >= 2;
            fralvl3.Visible = access >= 3;
            fralvl4.Visible = access >= 4;
        }
        protected override void InitializeTool()
        {
            var editors = new Dictionary<string, string>() { { "cmdItemEditor", "ItemEditor" }, { "cmdNpcEditor", "NpcEditor" }, { "cmdShopEditor", "ShopEditor" }, { "cmdSpellEditor", "SpellEditor" }, { "cmdSignEdit", "SignEditor" }, { "cmbClassEditor", "ClassEditor" }, { "cmbArrowEditor", "ArrowEditor" }, { "cmdBookEditor", "BookEditor" }, { "cmdQuestEditor", "QuestEditor" }, { "cmdEmoticonEditor", "EmoteEditor" }, { "cmdMapeditor", "MapEditor" } };
            foreach (var pair in editors)
            {
                string action = pair.Value;
                WireButton(pair.Key, () => ActionRequested?.Invoke(action, Array.Empty<object>()));
            }
            foreach (var action in new[] { "Kick", "Ban", "Mute", "Unmute", "Jail", "Unjail" })
            {
                string current = action;
                WireButton("cmd" + action, () => PlayerAction(current));
            }
            WireButton("cmdLOC", () => ActionRequested?.Invoke("Location", Array.Empty<object>()));
            WireButton("cmdRespawn", () => ActionRequested?.Invoke("RespawnMap", Array.Empty<object>()));
            WireButton("cmdDelbanlist", () => { if (MessageBox.Show(this, "Clear the entire ban list?", "Ban list", MessageBoxButtons.YesNo, MessageBoxType.Question) == DialogResult.Yes) ActionRequested?.Invoke("ClearBanList", Array.Empty<object>()); });
            WireButton("cmdMapreport", () => ActionRequested?.Invoke("MapReport", Array.Empty<object>()));
            WireButton("cmdSetJail", () => ActionRequested?.Invoke("SetJail", Array.Empty<object>()));
            WireButton("cmdSetSprite", () => NumericAction("SetSprite", "txtSpriteNum"));
            WireButton("cmdWarpto", () => NumericAction("WarpTo", "txtMapNum"));
            WireButton("cmdSetAccess", () => PlayerNumericAction("SetAccess", "txtAccessLevel"));
            WireButton("cmdPlayerSprite", () => PlayerNumericAction("PlayerSprite", "txtSpriteNum"));
            // The master designer retains a Kill button without a handler; disable it explicitly.
            cmdKill.Enabled = false;
            cmdDelbanlist.Text = "Clear ban list";
            BuildAdminLayout();
        }
        private void BuildAdminLayout()
        {
            ClientSize = new Size(670, 580);
            var root = new DynamicLayout() { Padding = 12, Spacing = new Size(8, 8) };
            foreach (var group in new[] { fraPlayer, fraMapNum, fraSpriteNum })
                group.Size = new Size(-1, -1);
            root.AddRow(new Label() { Text = "Player name" }, txtPlayerName, new Label() { Text = "Map" }, txtMapNum);
            root.AddRow(new Label() { Text = "Sprite" }, txtSpriteNum, new Label() { Text = "Access" }, txtAccessLevel);
            GroupBox[] groups = new[] { fralvl1, fralvl2, fralvl3, fralvl4 };
            string[][] controlNames = new[] { new string[] { "cmdKick", "cmdJail", "cmdUnjail", "cmdMute", "cmdUnmute" }, new string[] { "cmdMapeditor", "cmdWarpto", "cmdSignEdit", "cmdPlayerSprite", "cmdRespawn", "cmdMapreport", "cmdBan", "cmdLOC", "cmdSetSprite", "cmdSetJail" }, new string[] { "cmdNpcEditor", "cmdItemEditor", "cmdShopEditor", "cmdSpellEditor", "cmbArrowEditor", "cmdQuestEditor", "cmdBookEditor", "cmdEmoticonEditor", "cmbClassEditor" }, new string[] { "cmdSetAccess", "cmdDelbanlist" } };
            var columns = new TableLayout() { Spacing = new Size(8, 8) };
            var row = new TableRow();
            for (int i = 0, loopTo = groups.Length - 1; i <= loopTo; i++)
            {
                var body = new DynamicLayout() { Padding = 8, Spacing = new Size(4, 6) };
                foreach (var name in controlNames[i])
                {
                    Button button = (Button)Widget(name);
                    button.Size = new Size(140, 28);
                    body.AddRow(button);
                }
                groups[i].Size = new Size(-1, -1);
                groups[i].Content = body;
                row.Cells.Add(new TableCell(groups[i]));
            }
            columns.Rows.Add(row);
            root.AddRow(columns);
            Content = root;
        }
        private void PlayerAction(string action)
        {
            string player = txtPlayerName.Text.Trim();
            if (player.Length == 0)
            {
                ShowError("Enter a player name first.");
                return;
            }
            ActionRequested?.Invoke(action, new object[] { player });
        }
        private void NumericAction(string action, string name)
        {
            try
            {
                int number = Value(name);
                if (number < 0)
                    throw new ArgumentException("Enter a nonnegative number.");
                ActionRequested?.Invoke(action, new object[] { number });
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
        }
        private void PlayerNumericAction(string action, string name)
        {
            try
            {
                string player = txtPlayerName.Text.Trim();
                if (player.Length == 0)
                    throw new ArgumentException("Enter a player name first.");
                int number = Value(name);
                if (number < 0)
                    throw new ArgumentException("Enter a nonnegative number.");
                ActionRequested?.Invoke(action, new object[] { player, number });
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
        }
    }
}