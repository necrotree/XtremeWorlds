using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.Json.Nodes;
using Eto.Forms;
using XtremeWorlds.Tools;

namespace XtremeWorlds.Client.Tools
{
    // A native Eto editor: no Win32 handles, COM controls, or twinBASIC runtime.
    public class ToolForm : Form
    {
        protected readonly Dictionary<string, Control> Widgets = new Dictionary<string, Control>(StringComparer.OrdinalIgnoreCase);
        private readonly List<UITimer> Timers = new List<UITimer>();
        private bool loading;
        protected ToolRecord Definition;
        public string Kind { get; private set; }
        public bool Saving
        {
            get
            {
                return savingValue;
            }
            private set
            {
                savingValue = value;
                Content.Enabled = !value;
            }
        }
        private bool savingValue;
        public event Action<ToolRecord> SaveRequested;
        public event Action<string, int> ReturnRequested;

        public ToolForm(string kind)
        {
            Kind = kind;
            Closing += (sender, args) => { if (Saving) args.Cancel = true; };
            Closed += (sender, args) =>
            {
                foreach (UITimer editorTimer in Timers)
                {
                    editorTimer.Stop();
                    editorTimer.Dispose();
                }
                if (Definition is not null)
                    ReturnRequested?.Invoke(Kind, Definition.Id);
            };
            KeyDown += (sender, args) => { if (args.Key == Keys.Escape && !Saving) { args.Handled = true; Close(); } };
        }

        protected void RegisterControl(string name, Control control)
        {
            Widgets.Add(name, control);
            Slider slider = control as Slider;
            if (slider is not null)
            {
                slider.ValueChanged += (sender, args) => RefreshTool();
            }
            DropDown combo = control as DropDown;
            if (combo is not null)
                combo.SelectedIndexChanged += (sender, args) => RefreshTool();
        }
        protected void RegisterTimer(UITimer timer)
        {
            Timers.Add(timer);
            Shown += (sender, args) => timer.Start();
        }
        protected virtual void InitializeTool()
        {
            if (Kind == "admin" || Kind == "index")
                return;
            WireButton("cmdOk", Save);
            WireButton("cmdSubmit", Save);
            WireButton("cmdCancel", () => Close());
        }
        protected void WireButton(string name, Action action)
        {
            Button button = Widget(name) as Button;
            if (button is not null)
                button.Click += (sender, args) => action();
        }
        protected Control Widget(string name)
        {
            Control value = null;
            Widgets.TryGetValue(name, out value);
            return value;
        }
        protected void SetVisible(string name, bool visible)
        {
            if (Widget(name) is not null)
                Widget(name).Visible = visible;
        }
        protected void SetLabel(string name, string text)
        {
            Label label = Widget(name) as Label;
            if (label is not null)
                label.Text = text;
        }
        protected int Value(string name)
        {
            var control = Widget(name);
            if (control is Slider)
                return ((Slider)control).Value;
            if (control is DropDown)
            {
                DropDown combo = (DropDown)control;
                int id;
                if (combo.SelectedIndex < 0)
                    return 0;
                return int.TryParse(combo.SelectedKey, out id) ? id : combo.SelectedIndex;
            }
            if (control is CheckBox)
                return ((CheckBox)control).Checked.GetValueOrDefault() ? 1 : 0;
            if (control is RadioButton)
                return ((RadioButton)control).Checked ? 1 : 0;
            int number;
            if (!int.TryParse(TextValue(name), NumberStyles.Integer, CultureInfo.InvariantCulture, out number))
                throw new ArgumentException(name + " must be a whole number.");
            return number;
        }
        protected string TextValue(string name)
        {
            var control = Widget(name);
            if (control is TextBox)
                return ((TextBox)control).Text ?? "";
            if (control is TextArea)
                return ((TextArea)control).Text ?? "";
            return "";
        }
        protected void SetValue(string name, string value)
        {
            var control = Widget(name);
            if (control is null)
                return;
            int number;
            int.TryParse(value, NumberStyles.Integer, CultureInfo.InvariantCulture, out number);
            if (control is Slider)
            {
                Slider slider = (Slider)control;
                slider.MinValue = Math.Min(slider.MinValue, number);
                slider.MaxValue = Math.Max(slider.MaxValue, number);
                slider.Value = number;
            }
            else if (control is DropDown)
            {
                DropDown combo = (DropDown)control;
                if (combo.Items.Any(item => (item.Key ?? "") == (value ?? "")))
                {
                    combo.SelectedKey = value;
                }
                else if (combo.Items.All(item => string.IsNullOrEmpty(item.Key)) && number >= 0 && number < combo.Items.Count)
                {
                    combo.SelectedIndex = number;
                }
                else
                {
                    combo.Items.Add(new ListItem() { Key = value, Text = value + ": (unavailable)" });
                    combo.SelectedKey = value;
                }
            }
            else if (control is CheckBox)
            {
                ((CheckBox)control).Checked = number != 0;
            }
            else if (control is RadioButton)
            {
                ((RadioButton)control).Checked = number != 0;
            }
            else if (control is TextBox)
            {
                ((TextBox)control).Text = value;
            }
            else if (control is TextArea)
            {
                ((TextArea)control).Text = value;
            }
        }

        public void LoadRecord(ToolRecord @record)
        {
            if ((@record.Kind ?? "") != (Kind ?? "") || @record.Id < 0)
                throw new ArgumentException("This definition belongs to a different editor.");
            loading = true;
            Definition = @record;
            PopulateCatalogs();
            foreach (var @field in ToolSchema.Fields(Kind))
                SetValue(@field.Control, (@record.Data[@field.Key]?.ToString()) ?? (@field.Kind == "text" ? "" : @field.Minimum.ToString(CultureInfo.InvariantCulture)));
            LoadAdditional(@record.Data);
            loading = false;
            RefreshTool();
            Title = Title + " - " + @record.Id.ToString(CultureInfo.InvariantCulture);
        }
        protected void PopulateCombo(string name, string catalog, bool classRequirement = false)
        {
            DropDown combo = Widget(name) as DropDown;
            if (combo is null)
                return;
            combo.Items.Clear();
            combo.Items.Add(new ListItem() { Key = "0", Text = classRequirement ? "All classes" : "None" });
            List<ContentSlot> slots = null;
            if (Definition.Catalogs.TryGetValue(catalog, out slots))
            {
                foreach (var slot in slots)
                    combo.Items.Add(new ListItem() { Key = (slot.Id + (classRequirement ? 1 : 0)).ToString(CultureInfo.InvariantCulture), Text = slot.ToString() });
            }
            combo.SelectedIndex = 0;
        }
        protected virtual void PopulateCatalogs()
        {
            foreach (var @field in ToolSchema.Fields(Kind))
            {
                if (@field.Catalog.Length > 0)
                    PopulateCombo(@field.Control, @field.Catalog, @field.Key == "ClassReq");
            }
        }
        protected virtual void LoadAdditional(JsonObject data)
        {
        }
        protected virtual void StoreAdditional(JsonObject data)
        {
        }
        protected virtual void RefreshTool()
        {
            if (loading)
                return;
            foreach (var pair in Widgets)
            {
                Slider slider = pair.Value as Slider;
                if (slider is not null && pair.Key.StartsWith("scrl", StringComparison.OrdinalIgnoreCase))
                    SetLabel("lbl" + pair.Key.Substring(4), slider.Value.ToString(CultureInfo.InvariantCulture));
            }
        }
        public ToolRecord CollectRecord()
        {
            if (Definition is null)
                throw new InvalidOperationException("Wait for the server to load a definition.");
            JsonObject data = (JsonObject)Definition.Data.DeepClone();
            foreach (var @field in ToolSchema.Fields(Kind))
            {
                if (@field.Kind == "text")
                {
                    data[@field.Key] = JsonValue.Create(TextValue(@field.Control).TrimEnd());
                }
                else
                {
                    data[@field.Key] = JsonValue.Create(Value(@field.Control));
                }
            }
            StoreAdditional(data);
            string errorMessage = ToolSchema.Validate(Kind, Definition.Id, data);
            if (errorMessage is not null)
                throw new ArgumentException(errorMessage);
            return new ToolRecord() { Kind = Kind, Id = Definition.Id, Data = data };
        }
        public void Save()
        {
            if (Saving)
                return;
            try
            {
                var @record = CollectRecord();
                Saving = true;
                SaveRequested?.Invoke(@record);
            }
            catch (ArgumentException ex)
            {
                ShowError(ex.Message);
            }
            catch (InvalidOperationException ex)
            {
                ShowError(ex.Message);
            }
        }
        public void SaveComplete(int id)
        {
            if (Definition is null || id != Definition.Id || !Saving)
                return;
            Saving = false;
            Close();
        }
        public void SaveFailed(string message)
        {
            Saving = false;
            ShowError(message);
        }
        public void Disconnect()
        {
            Definition = null;
            Saving = false;
            Close();
        }
        protected void ShowError(string message)
        {
            if (Widget("lblStatus") is Label)
            {
                SetLabel("lblStatus", message);
            }
            else
            {
                MessageBox.Show(this, message, Title, MessageBoxButtons.OK, MessageBoxType.Warning);
            }
        }
        protected string CatalogName(string kind, int id)
        {
            if (Definition is null || id == 0)
                return "None";
            List<ContentSlot> slots = null;
            if (!Definition.Catalogs.TryGetValue(kind, out slots))
                return "None";
            return (slots.FirstOrDefault(slot => slot.Id == id)?.Name) ?? "None";
        }
    }
}