using System;
using System.ComponentModel;
using Eto.Forms;

namespace XtremeWorlds.Client.Forms;

/// <summary>Eto editor lifecycle with previews delegated to the FNA engine.</summary>
public class EditForm : Form
{
    public event EventHandler<CancelEventArgs> ApplyRequested;
    public event EventHandler CancelRequested;
    public event EventHandler<EditorPreviewEventArgs> PreviewRequested;
    public bool HasChanges { get; private set; }
    public void MarkChanged() => HasChanges = true;
    public bool ApplyChanges()
    {
        if (ApplyRequested == null) return false;
        var args = new CancelEventArgs();
        ApplyRequested.Invoke(this, args);
        if (args.Cancel) return false;
        HasChanges = false;
        return true;
    }
    public void CancelChanges()
    {
        CancelRequested?.Invoke(this, EventArgs.Empty);
        HasChanges = false;
        Close();
    }
    public void RequestPreview(string texturePath, int x, int y, int width, int height)
    {
        if (string.IsNullOrWhiteSpace(texturePath)) throw new ArgumentException("A texture is required.", nameof(texturePath));
        if (width <= 0 || height <= 0) throw new ArgumentOutOfRangeException(nameof(width));
        PreviewRequested?.Invoke(this, new EditorPreviewEventArgs(texturePath, x, y, width, height));
    }
}

public sealed class EditorPreviewEventArgs : EventArgs
{
    public EditorPreviewEventArgs(string texturePath, int x, int y, int width, int height)
    {
        TexturePath = texturePath; X = x; Y = y; Width = width; Height = height;
    }
    public string TexturePath { get; }
    public int X { get; }
    public int Y { get; }
    public int Width { get; }
    public int Height { get; }
}