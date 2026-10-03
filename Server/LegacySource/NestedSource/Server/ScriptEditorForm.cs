using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using Microsoft.Win32;

namespace Server;

public sealed class ScriptEditorForm : Window
{
    private readonly string _scriptsPath;
    private readonly ListBox _files;
    private readonly TextBox _editor;
    private readonly ComboBox _procedures;
    private string? _currentPath;
    private string _savedText = string.Empty;
    private bool _loading;

    public ScriptEditorForm()
    {
        Title = "Script Editor - Untitled";
        Width = 930;
        Height = 610;
        MinWidth = 700;
        MinHeight = 430;
        WindowStartupLocation = WindowStartupLocation.CenterOwner;
        WpfServerSkin.Apply(this);

        _scriptsPath = Path.Combine(AppContext.BaseDirectory, "scripts");
        Directory.CreateDirectory(_scriptsPath);

        _files = WpfServerSkin.MakeListBox();
        _editor = WpfServerSkin.MakeTextBox();
        _editor.AcceptsReturn = true;
        _editor.AcceptsTab = true;
        _editor.TextWrapping = TextWrapping.NoWrap;
        _editor.VerticalScrollBarVisibility = ScrollBarVisibility.Auto;
        _editor.HorizontalScrollBarVisibility = ScrollBarVisibility.Auto;
        _editor.FontFamily = new FontFamily("Consolas");
        _editor.FontSize = 13;

        _procedures = new ComboBox
        {
            Background = WpfServerSkin.Input,
            Foreground = WpfServerSkin.Gold,
            BorderBrush = WpfServerSkin.Bronze,
            MinWidth = 240,
            Margin = new Thickness(0, 0, 8, 0)
        };

        var save = WpfServerSkin.MakeButton("Save");
        save.Click += (_, _) => Save(false);
        var saveAs = WpfServerSkin.MakeButton("Save As");
        saveAs.Click += (_, _) => Save(true);
        var create = WpfServerSkin.MakeButton("New");
        create.Click += (_, _) => NewDocument();
        var delete = WpfServerSkin.MakeButton("Delete", 100);
        delete.Click += (_, _) => DeleteCurrent();

        _files.SelectionChanged += (_, _) => LoadSelected();
        _editor.TextChanged += (_, _) =>
        {
            if (_loading) return;
            UpdateTitle();
            RefreshProcedures();
        };
        _procedures.SelectionChanged += (_, _) => JumpToProcedure();
        _editor.KeyDown += EditorKeyDown;

        var root = new DockPanel { Background = WpfServerSkin.Window };
        var menu = BuildMenu();
        DockPanel.SetDock(menu, Dock.Top);
        root.Children.Add(menu);

        var grid = new Grid { Margin = new Thickness(8) };
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(220) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(8) });
        grid.ColumnDefinitions.Add(new ColumnDefinition { Width = new GridLength(1, GridUnitType.Star) });

        var left = new Grid();
        left.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        left.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
        left.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        var label = new TextBlock { Text = "Scripts", Foreground = WpfServerSkin.Gold, Margin = new Thickness(2, 0, 0, 5) };
        left.Children.Add(label);
        Grid.SetRow(_files, 1);
        left.Children.Add(_files);
        Grid.SetRow(delete, 2);
        delete.Margin = new Thickness(0, 6, 0, 0);
        left.Children.Add(delete);
        Grid.SetColumn(left, 0);
        grid.Children.Add(left);

        var right = new Grid();
        right.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        right.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });
        var toolbar = new DockPanel { Margin = new Thickness(0, 0, 0, 6) };
        DockPanel.SetDock(_procedures, Dock.Left);
        toolbar.Children.Add(_procedures);
        var buttons = new StackPanel { Orientation = Orientation.Horizontal, HorizontalAlignment = HorizontalAlignment.Right };
        buttons.Children.Add(save);
        buttons.Children.Add(saveAs);
        buttons.Children.Add(create);
        toolbar.Children.Add(buttons);
        right.Children.Add(toolbar);

        var editorBorder = new Border
        {
            Background = WpfServerSkin.Panel,
            BorderBrush = WpfServerSkin.Bronze,
            BorderThickness = new Thickness(1),
            Padding = new Thickness(2),
            Child = _editor
        };
        Grid.SetRow(editorBorder, 1);
        right.Children.Add(editorBorder);
        Grid.SetColumn(right, 2);
        grid.Children.Add(right);

        root.Children.Add(grid);
        Content = root;

        RefreshFiles();
        var main = Path.Combine(_scriptsPath, "Main.as");
        if (File.Exists(main))
            LoadFile(main);

        Closing += (_, e) =>
        {
            if (!CanDiscardChanges())
                e.Cancel = true;
        };
    }

    private Menu BuildMenu()
    {
        var menu = new Menu();
        WpfServerSkin.StyleMenu(menu);
        var file = new MenuItem { Header = "File" };
        var save = new MenuItem { Header = "Save" };
        save.Click += (_, _) => Save(false);
        var saveAs = new MenuItem { Header = "Save As..." };
        saveAs.Click += (_, _) => Save(true);
        var close = new MenuItem { Header = "Close" };
        close.Click += (_, _) => Close();
        file.Items.Add(save);
        file.Items.Add(saveAs);
        file.Items.Add(new Separator());
        file.Items.Add(close);
        menu.Items.Add(file);
        return menu;
    }

    private void RefreshFiles()
    {
        var files = Directory.EnumerateFiles(_scriptsPath)
            .Where(IsScript)
            .Select(Path.GetFileName)
            .Where(name => !string.IsNullOrWhiteSpace(name))
            .OrderBy(name => name, StringComparer.OrdinalIgnoreCase)
            .ToList();
        _files.ItemsSource = files;
    }

    private static bool IsScript(string path)
    {
        string ext = Path.GetExtension(path).ToLowerInvariant();
        return ext is ".as" or ".vbs" or ".txt";
    }

    private void LoadSelected()
    {
        if (_loading || _files.SelectedItem is not string name)
            return;
        LoadFile(Path.Combine(_scriptsPath, name));
    }

    private void LoadFile(string path)
    {
        if (!CanDiscardChanges())
            return;
        _loading = true;
        try
        {
            _currentPath = path;
            _savedText = File.ReadAllText(path);
            _editor.Text = _savedText;
            UpdateTitle();
            RefreshProcedures();
        }
        finally
        {
            _loading = false;
        }
    }

    private void NewDocument()
    {
        if (!CanDiscardChanges())
            return;
        _loading = true;
        _currentPath = null;
        _savedText = string.Empty;
        _editor.Text = "' SadScript include file" + Environment.NewLine;
        _loading = false;
        UpdateTitle();
        RefreshProcedures();
    }

    private void Save(bool saveAs)
    {
        string? path = _currentPath;
        if (saveAs || string.IsNullOrWhiteSpace(path))
        {
            var dialog = new SaveFileDialog
            {
                Title = "Save Script",
                FileName = path is null ? "NewScript.as" : Path.GetFileName(path),
                InitialDirectory = _scriptsPath,
                Filter = "Script files (*.as;*.vbs;*.txt)|*.as;*.vbs;*.txt|All files (*.*)|*.*"
            };
            if (dialog.ShowDialog(this) != true)
                return;
            path = dialog.FileName;
        }

        if (path is null || !IsScript(path))
        {
            MessageBox.Show(this, "Use a .as, .vbs or .txt file.", "Script Editor", MessageBoxButton.OK, MessageBoxImage.Warning);
            return;
        }

        File.WriteAllText(path, _editor.Text);
        _currentPath = path;
        _savedText = _editor.Text;
        RefreshFiles();
        UpdateTitle();
    }

    private void DeleteCurrent()
    {
        if (_currentPath is null || !File.Exists(_currentPath))
            return;
        if (MessageBox.Show(this, $"Delete {Path.GetFileName(_currentPath)}?", "Delete Script", MessageBoxButton.YesNo, MessageBoxImage.Warning) != MessageBoxResult.Yes)
            return;
        File.Delete(_currentPath);
        _currentPath = null;
        _savedText = string.Empty;
        _editor.Clear();
        RefreshFiles();
        UpdateTitle();
    }

    private bool CanDiscardChanges()
    {
        if (_editor.Text == _savedText)
            return true;
        return MessageBox.Show(this, "Discard unsaved script changes?", "Script Editor", MessageBoxButton.YesNo, MessageBoxImage.Question) == MessageBoxResult.Yes;
    }

    private void UpdateTitle()
    {
        string file = _currentPath is null ? "Untitled" : Path.GetFileName(_currentPath);
        Title = $"Script Editor - {file}" + (_editor.Text == _savedText ? string.Empty : " *");
    }

    private void RefreshProcedures()
    {
        var names = new List<string>();
        foreach (string raw in _editor.Text.Split('\n'))
        {
            string line = raw.Trim();
            if (!line.StartsWith("Sub ", StringComparison.OrdinalIgnoreCase) &&
                !line.StartsWith("Function ", StringComparison.OrdinalIgnoreCase))
                continue;
            int paren = line.IndexOf('(');
            names.Add(paren > 0 ? line[..paren] : line);
        }
        _procedures.ItemsSource = names;
    }

    private void JumpToProcedure()
    {
        if (_procedures.SelectedItem is not string proc)
            return;
        int pos = _editor.Text.IndexOf(proc, StringComparison.OrdinalIgnoreCase);
        if (pos < 0)
            return;
        _editor.Select(pos, proc.Length);
        _editor.Focus();
        _editor.ScrollToLine(_editor.GetLineIndexFromCharacterIndex(pos));
    }

    private void EditorKeyDown(object sender, KeyEventArgs e)
    {
        if ((Keyboard.Modifiers & ModifierKeys.Control) == 0)
            return;
        if (e.Key == Key.S)
        {
            Save(false);
            e.Handled = true;
        }
    }
}
