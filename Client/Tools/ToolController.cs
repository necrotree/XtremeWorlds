using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Eto.Forms;
using XtremeWorlds.Tools;

namespace XtremeWorlds.Client.Tools
{
    public sealed class ToolController : IDisposable
    {
        private readonly Action<string, object[]> send;
        private readonly Action<string, object[]> action;
        private readonly Dictionary<string, Pending> requests = new Dictionary<string, Pending>();
        private readonly Dictionary<string, ToolForm> editors = new Dictionary<string, ToolForm>();
        private frmIndex index;
        private frmAdminPanel admin;
        private readonly UITimer timeoutTimer = new UITimer() { Interval = 1d };
        private bool disposed;
        public event Action<int, string?>? MapPreviewChanged;
        public event Action<bool>? MapEditorActiveChanged;
        public event Action? MapBrushSelected;

        // Eto owns editor state. Return a snapshot to the runtime so it can
        // explicitly post the painted result to FNA, without sharing controls.
        public (int MapId, string Json)? PaintMapTile(int x, int y, bool erase)
        {
            if (disposed) return null;
            var mapEditor = editors.Values.OfType<frmMapEditor>().FirstOrDefault(editor => editor.Visible);
            if (mapEditor is null || mapEditor.Saving || mapEditor.MapId < 1)
                return null;
            mapEditor.PaintAt(x, y, erase, publish: false);
            var snapshot = mapEditor.CaptureMapSnapshot();
            return snapshot is null ? null : (mapEditor.MapId, snapshot);
        }

        private string latestList;
        private int lastSelected = -1;
        private class Pending
        {
            public string Kind { get; set; }
            public int Id { get; set; } = -1;
            public ToolForm Editor { get; set; }
            public DateTime Started { get; set; } = DateTime.UtcNow;
        }
        public ToolController(Action<string, object[]> send, Action<string, object[]> action)
        {
            this.send = send;
            this.action = action;
            timeoutTimer.Elapsed += CheckTimeouts;
        }
        public void OpenAdmin()
        {
            if (!disposed)
                send("toolaccess", Array.Empty<object>());
        }
        public void Open(string kind, int selection = -1)
        {
            if (disposed)
                return;
            foreach (var pair in requests.Where(item => item.Value.Editor is null).ToArray())
                requests.Remove(pair.Key);
            string request = Guid.NewGuid().ToString("N");
            latestList = request;
            lastSelected = selection;
            requests[request] = new Pending() { Kind = kind };
            timeoutTimer.Start();
            send("requesttool", new object[] { kind, request });
        }
        public bool HandlePacket(IReadOnlyList<string> parts)
        {
            if (parts.Count == 0 || !new[] { "toolindex", "toolrecord", "toolsaved", "toolerror", "toolaccess" }.Contains(parts[0]))
                return false;
            if (disposed)
                return true;
            if (parts[0] == "toolaccess")
            {
                int access;
                if (parts.Count != 2 || !int.TryParse(parts[1], out access))
                    return true;
                if (access < 1)
                {
                    MessageBox.Show("Only admins may open the admin panel.");
                    return true;
                }
                if (admin is null)
                {
                    admin = new frmAdminPanel();
                    admin.ActionRequested += (name, arguments) => action(name, arguments);
                    admin.Closed += (sender, args) => admin = null;
                }
                admin.ApplyAccess(access);
                if (!admin.Visible)
                    admin.Show();
                admin.BringToFront();
                return true;
            }
            if (parts.Count < 4)
                return true;
            string request = parts[parts.Count - 1];
            Pending pending = null;
            if (!requests.TryGetValue(request, out pending) || (pending.Kind ?? "") != (parts[1] ?? ""))
                return true;
            try
            {
                switch (parts[0] ?? "")
                {
                    case "toolindex":
                        {
                            if (parts.Count != 4 || (request ?? "") != (latestList ?? ""))
                            {
                                requests.Remove(request);
                                return true;
                            }
                            var slots = ToolWire.Decode<List<ContentSlot>>(parts[2]);
                            if (slots is null)
                                throw new ArgumentException("Empty content list.");
                            requests.Remove(request);
                            ShowIndex(pending.Kind, slots);
                            break;
                        }
                    case "toolrecord":
                        {
                            if (parts.Count != 5 || pending.Id < 0)
                                return true;
                            var @record = ToolWire.Decode<ToolRecord>(parts[3]);
                            if (@record is null || (@record.Kind ?? "") != (pending.Kind ?? "") || @record.Id != pending.Id || (parts[2] ?? "") != (@record.Id.ToString(CultureInfo.InvariantCulture) ?? ""))
                                return true;
                            requests.Remove(request);
                            ShowRecord(@record);
                            break;
                        }
                    case "toolsaved":
                        {
                            if (parts.Count != 4 || pending.Editor is null || (parts[2] ?? "") != (pending.Id.ToString(CultureInfo.InvariantCulture) ?? ""))
                                return true;
                            requests.Remove(request);
                            pending.Editor.SaveComplete(pending.Id);
                            break;
                        }
                    case "toolerror":
                        {
                            if (parts.Count != 5)
                                return true;
                            requests.Remove(request);
                            if (pending.Editor is not null)
                            {
                                pending.Editor.SaveFailed(parts[3]);
                            }
                            else
                            {
                                MessageBox.Show(parts[3], "Editor");
                            }

                            break;
                        }
                }
            }
            catch (Exception ex) when (ex is FormatException || ex is System.Text.Json.JsonException || ex is ArgumentException)
            {
                requests.Remove(request);
                if (pending.Editor is not null)
                {
                    pending.Editor.SaveFailed("The server returned an invalid editor response.");
                }
                else
                {
                    MessageBox.Show("The server returned an invalid editor response.", "Editor");
                }
            }
            return true;
        }
        private void ShowIndex(string kind, List<ContentSlot> slots)
        {
            index?.Close();
            var current = new frmIndex();
            index = current;
            current.Title = kind + " editor - choose a slot";
            current.lstIndex.Items.Clear();
            foreach (var slot in slots)
                current.lstIndex.Items.Add(new ListItem() { Key = slot.Id.ToString(CultureInfo.InvariantCulture), Text = slot.ToString() });
            if (slots.Count > 0)
            {
                current.lstIndex.SelectedIndex = Math.Max(0, slots.FindIndex(slot => slot.Id == lastSelected));
            }
            Action selectSlot = () =>
            {
                int id;
                if (current.lstIndex.SelectedIndex < 0 || !int.TryParse(current.lstIndex.SelectedKey, out id))
                    return;
                string request = Guid.NewGuid().ToString("N");
                requests[request] = new Pending() { Kind = kind, Id = id };
                timeoutTimer.Start();
                current.Close();
                send("edittool", new object[] { kind, id, request });
            };
            current.cmdOk.Click += (sender, args) => selectSlot();
            current.lstIndex.MouseDoubleClick += (sender, args) => selectSlot();
            current.cmdCancel.Click += (sender, args) => current.Close();
            current.Closed += (sender, args) => { if (ReferenceEquals(index, current)) index = null; };
            current.Show();
        }
        private void ShowRecord(ToolRecord @record)
        {
            string key = @record.Kind + ":" + @record.Id.ToString(CultureInfo.InvariantCulture);
            ToolForm existing = null;
            if (editors.TryGetValue(key, out existing))
            {
                existing.BringToFront();
                return;
            }
            ToolForm editor;
            switch (@record.Kind ?? "")
            {
                case "map":
                    {
                        editor = new frmMapEditor();
                        break;
                    }
                case "book":
                    {
                        editor = new frmBookEditor();
                        break;
                    }
                case "quest":
                    {
                        editor = new frmQuestEditor();
                        break;
                    }
                case "emote":
                    {
                        editor = new frmEmoticonEditor();
                        break;
                    }
                case "arrow":
                    {
                        editor = new frmArrowEditor();
                        break;
                    }
                case "item":
                    {
                        editor = new frmItemEditor();
                        break;
                    }
                case "npc":
                    {
                        editor = new frmNpcEditor();
                        break;
                    }
                case "spell":
                    {
                        editor = new frmSpellEditor();
                        break;
                    }
                case "class":
                    {
                        editor = new frmClassEditor();
                        break;
                    }
                case "shop":
                    {
                        editor = new frmShopEditor();
                        break;
                    }
                case "sign":
                    {
                        editor = new frmSignEditor();
                        break;
                    }

                default:
                    {
                        throw new ArgumentException("Unknown editor.");
                    }
            }
            editor.LoadRecord(@record);
            editors[key] = editor;
            if (editor is frmMapEditor mapEditor)
            {
                mapEditor.PreviewChanged += (id, json) => MapPreviewChanged?.Invoke(id, json);
                mapEditor.BrushSelected += () => MapBrushSelected?.Invoke();
                MapEditorActiveChanged?.Invoke(true);
                mapEditor.PublishPreview();
            }
            editor.SaveRequested += updated =>
            {
                string request = Guid.NewGuid().ToString("N");
                requests[request] = new Pending() { Kind = updated.Kind, Id = updated.Id, Editor = editor };
                timeoutTimer.Start();
                send("savetool", new object[] { updated.Kind, updated.Id, ToolWire.Encode(updated), request });
            };
            // Saving a map should close the editor, not reopen the slot picker.
            editor.ReturnRequested += (kind, id) => { if (!disposed && kind != "map") Open(kind, id); };
            editor.Closed += (sender, args) =>
            {
                editors.Remove(key);
                if (editor is frmMapEditor mapEditor)
                {
                    MapEditorActiveChanged?.Invoke(false);
                    MapPreviewChanged?.Invoke(mapEditor.MapId, null);
                }
            };
            editor.Show();
        }
        private void CheckTimeouts(object sender, EventArgs args)
        {
            foreach (var pair in requests.ToArray())
            {
                if (DateTime.UtcNow - pair.Value.Started < TimeSpan.FromSeconds(20L))
                    continue;
                requests.Remove(pair.Key);
                if (pair.Value.Editor is not null)
                {
                    pair.Value.Editor.SaveFailed("The server did not confirm the save. You can retry.");
                }
                else if ((pair.Key ?? "") == (latestList ?? "") || pair.Value.Id >= 0)
                {
                    MessageBox.Show("The server did not respond to the editor request.", "Editor");
                }
            }
            if (requests.Count == 0)
                timeoutTimer.Stop();
        }
        public void Reset()
        {
            MapEditorActiveChanged?.Invoke(false);
            MapPreviewChanged?.Invoke(-1, null);
            requests.Clear();
            timeoutTimer.Stop();
            index?.Close();
            admin?.Close();
            foreach (var editor in editors.Values.ToArray())
                editor.Disconnect();
            editors.Clear();
        }
        public void Dispose()
        {
            if (disposed)
                return;
            disposed = true;
            Reset();
            timeoutTimer.Dispose();
        }
    }
}