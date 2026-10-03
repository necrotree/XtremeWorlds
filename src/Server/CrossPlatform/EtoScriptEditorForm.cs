using System;
using System.IO;
using System.Linq;
using Eto.Drawing;
using Eto.Forms;

namespace Server;

public sealed class EtoScriptEditorForm : Form
{
    private readonly ListBox _files = EtoServerSkin.ListBox();
    private readonly TextArea _editor = EtoServerSkin.TextArea(false);
    private readonly string _dir = Path.Combine(AppContext.BaseDirectory, "scripts");
    private string[] _fileNames = Array.Empty<string>();

    public EtoScriptEditorForm()
    {
        Title = "Script Editor";
        ClientSize = new Size(900, 620);
        Directory.CreateDirectory(_dir);
        _files.SelectedIndexChanged += (_, _) => LoadSelected();
        var save = new Button { Text = "Save" }; save.Click += (_, _) => Save();
        var refresh = new Button { Text = "Refresh" }; refresh.Click += (_, _) => Reload();
        Content = new TableLayout
        {
            Padding = 8,
            Spacing = new Size(6, 6),
            Rows =
            {
                new TableRow(new TableCell(_files, false), new TableCell(_editor, true)) { ScaleHeight = true },
                new TableRow(null, new StackLayout { Orientation = Orientation.Horizontal, Spacing = 6, Items = { save, refresh } })
            }
        };
        Shown += (_, _) =>
        {
            Reload();
            SelectAndLoad("main.lua");
        };
    }

    private void Reload()
    {
        _fileNames = Directory.EnumerateFiles(_dir, "*.*")
            .Where(p => p.EndsWith(".lua", StringComparison.OrdinalIgnoreCase) ||
                        p.EndsWith(".as", StringComparison.OrdinalIgnoreCase) ||
                        p.EndsWith(".vbs", StringComparison.OrdinalIgnoreCase) ||
                        p.EndsWith(".txt", StringComparison.OrdinalIgnoreCase))
            .Select(p => Path.GetFileName(p) ?? string.Empty)
            .Where(n => n.Length > 0)
            .OrderBy(n => n, StringComparer.OrdinalIgnoreCase)
            .ToArray();
        _files.DataStore = _fileNames;
    }

    private void SelectAndLoad(string fileName)
    {
        int index = Array.FindIndex(_fileNames, n => string.Equals(n, fileName, StringComparison.OrdinalIgnoreCase));
        if (index < 0) return;
        _files.SelectedIndex = index;
        LoadSelected();
    }

    private string? SelectedPath() => _files.SelectedIndex >= 0 && _files.SelectedIndex < _fileNames.Length ? Path.Combine(_dir, _fileNames[_files.SelectedIndex]) : null;
    private void LoadSelected() { var p = SelectedPath(); if (p is not null && File.Exists(p)) _editor.Text = File.ReadAllText(p); }
    private void Save() { var p = SelectedPath(); if (p is not null) File.WriteAllText(p, _editor.Text); }
}
