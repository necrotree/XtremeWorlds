param(
    [string]$Template = '.dx11-backup/Playerworlds.twinproj',
    [string]$Tree = 'DX11Project',
    [string]$Output = 'Playerworlds-DX11.twinproj',
    [switch]$SmokeTest,
    [switch]$NativeControlsTest
)
$ErrorActionPreference = 'Stop'
# Preserve container metadata and every untouched resource/package byte. The
# official BETA 983 importer crashes on this project's nested package folders.
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
public sealed class TwinNode {
    public short Kind;
    public string Name;
    public ulong Revision;
    public uint Flags;
    public byte Category;
    public byte[] Data;
    public uint[] Revisions;
    public List<TwinNode> Children;
    static byte[] Blob(BinaryReader r) {
        int count = r.ReadInt32();
        if (count < 0 || count > r.BaseStream.Length - r.BaseStream.Position) throw new InvalidDataException();
        return r.ReadBytes(count);
    }
    static void Blob(BinaryWriter w, byte[] b) { w.Write(b.Length); w.Write(b); }
    public static TwinNode Read(BinaryReader r, bool root) {
        var n = new TwinNode();
        n.Kind = r.ReadInt16(); n.Name = Encoding.UTF8.GetString(Blob(r));
        n.Revision = r.ReadUInt64(); n.Flags = r.ReadUInt32(); n.Category = r.ReadByte();
        if (root || n.Kind == 2) {
            int count = r.ReadInt32();
            if (count < 0 || count > 100000) throw new InvalidDataException();
            n.Children = new List<TwinNode>();
            for (int i = 0; i < count; i++) n.Children.Add(Read(r, false));
        } else if (n.Kind == 1) {
            n.Data = Blob(r);
            int count = r.ReadInt32();
            if (count < 0 || count > 100000) throw new InvalidDataException();
            n.Revisions = new uint[count];
            for (int i = 0; i < count; i++) n.Revisions[i] = r.ReadUInt32();
        } else throw new InvalidDataException("Unknown entry kind.");
        return n;
    }
    public void Write(BinaryWriter w) {
        w.Write(Kind); Blob(w, Encoding.UTF8.GetBytes(Name)); w.Write(Revision); w.Write(Flags); w.Write(Category);
        if (Children != null) {
            w.Write(Children.Count); foreach (var c in Children) c.Write(w);
        } else {
            Blob(w, Data); w.Write(Revisions.Length); foreach (var v in Revisions) w.Write(v);
        }
    }
    public TwinNode Find(string path) {
        var current = this;
        foreach (var part in path.Split('/')) {
            current = current.Children.Find(n => n.Name.Equals(part, StringComparison.OrdinalIgnoreCase));
            if (current == null) throw new InvalidDataException("Missing project entry: " + path);
        }
        return current;
    }
    public void Replace(string path, byte[] bytes) { var n = Find(path); n.Data = bytes; n.Revision++; }
    public void AddSource(string name, byte[] bytes) {
        var folder = Find("Sources/Src");
        var old = folder.Children.Find(n => n.Name == name);
        if (old != null) { old.Data = bytes; old.Revision++; return; }
        folder.Children.Add(new TwinNode { Kind = 1, Name = name, Revision = 2, Data = bytes, Revisions = new uint[0] });
    }
    public static TwinNode Load(string path) {
        using (var r = new BinaryReader(File.OpenRead(path))) {
            if (r.ReadUInt32() != 0xEA0BA51C) throw new InvalidDataException("Not a twinBASIC container.");
            var root = Read(r, true);
            if (r.BaseStream.Position != r.BaseStream.Length) throw new InvalidDataException("Trailing data.");
            return root;
        }
    }
    public void Save(string path) {
        using (var w = new BinaryWriter(File.Create(path))) { w.Write(0xEA0BA51Cu); Write(w); }
    }
}
'@
$root = Split-Path $PSScriptRoot -Parent
$templatePath = Join-Path $root $Template
$treePath = Join-Path $root $Tree
$outputPath = Join-Path $root $Output
foreach ($name in @('modDX11.bas','clsDX11Surface.cls','SurfUtil.bas')) {
    # The legacy BAS/CLS importer requires CRLF to parse member declarations.
    $source = [IO.File]::ReadAllText((Join-Path $root "Src/$name")) -replace '\r?\n', "`r`n"
    [IO.File]::WriteAllText((Join-Path $root "Src/$name"), $source, (New-Object Text.UTF8Encoding($false)))
    [IO.File]::WriteAllText((Join-Path $treePath "Sources/Src/$name"), $source, (New-Object Text.UTF8Encoding($false)))
}
$project = [TwinNode]::Load($templatePath)
# Prove that the parser/writer preserves the original before changing anything.
$memory = New-Object IO.MemoryStream
$writer = New-Object IO.BinaryWriter($memory)
$writer.Write([uint32]::Parse('EA0BA51C', [Globalization.NumberStyles]::HexNumber))
$project.Write($writer)
$writer.Flush()
$original = [IO.File]::ReadAllBytes($templatePath)
$roundtrip = $memory.ToArray()
$sha = [Security.Cryptography.SHA256]::Create()
if ([Convert]::ToBase64String($sha.ComputeHash($original)) -ne [Convert]::ToBase64String($sha.ComputeHash($roundtrip))) { throw 'Container round-trip check failed.' }
$writer.Dispose()
$project.Replace('Settings', [IO.File]::ReadAllBytes((Join-Path $treePath 'Settings')))
foreach ($name in @('modGlobals.bas','modDirectX.bas','modGameLogic.bas','modGameEditors.bas','modDeclares.bas','modDX11.bas','clsDX11Surface.cls','SurfUtil.bas','modParseURLs.bas')) {
    $path = Join-Path $treePath "Sources/Src/$name"
    if (Test-Path -LiteralPath $path) { $project.AddSource($name, [IO.File]::ReadAllBytes($path)) }
}
# Embed the native replacements and repaired form definitions.
foreach ($file in Get-ChildItem (Join-Path $treePath 'Sources/Src') -File | Where-Object { $_.Name -match '^(clsNative|modNative)' -or $_.Name -match '^frm(Mirage|MainMenu|BugReport|Debug|Options|Nudge)\.frm\.(twin|tbform)$' }) {
    $project.AddSource($file.Name, [IO.File]::ReadAllBytes($file.FullName))
}
# Retain existing packages and IDE layout.
if ($SmokeTest) {
    $settings = [Text.Encoding]::UTF8.GetString($project.Find('Settings').Data) | ConvertFrom-Json
    $settings.'project.name' = 'DX11Smoke'
    $settings.'project.id' = '{2C9726F5-9B12-47C6-B9D0-97B54A5975D1}'
    $settings.'project.buildPath' = '${SourcePath}\DX11Smoke.exe'
    $settings.'project.startupObject' = 'Sub Main'
    $settings.'project.iconForm' = ''
    $settings.'project.references' = @($settings.'project.references' | Where-Object { $_.symbolId -in @('VB','stdole','WinDevLib') })
    $project.Replace('Settings', [Text.Encoding]::UTF8.GetBytes(($settings | ConvertTo-Json -Depth 30)))
    $src = $project.Find('Sources/Src')
    $keep = @($src.Children | Where-Object { $_.Name -in @('modDX11.bas','clsDX11Surface.cls') })
    $src.Children.Clear()
    foreach ($entry in $keep) { $src.Children.Add($entry) }
    $sourceFolder = $project.Find('Sources')
    $sourceFolder.Children.Clear()
    $sourceFolder.Children.Add($src)
    $testSource = [IO.File]::ReadAllText((Join-Path $root 'tools/DX11Smoke.bas')) -replace '\r?\n', "`r`n"
    $project.AddSource('DX11Smoke.bas', [Text.Encoding]::UTF8.GetBytes($testSource))
}
if ($NativeControlsTest) {
    $settings = [Text.Encoding]::UTF8.GetString($project.Find('Settings').Data) | ConvertFrom-Json
    $settings.'project.name' = 'NativeControlsSmoke'
    $settings.'project.id' = '{D331DC64-2952-48A6-88BA-BE01A2CE42C9}'
    $settings.'project.buildPath' = '${SourcePath}\NativeControlsSmoke.exe'
    $project.Replace('Settings', [Text.Encoding]::UTF8.GetBytes(($settings | ConvertTo-Json -Depth 30)))
    $game = [Text.Encoding]::UTF8.GetString($project.Find('Sources/Src/modGameLogic.bas').Data).Replace('Public Sub Main()', 'Public Sub GameMain()')
    $project.Replace('Sources/Src/modGameLogic.bas', [Text.Encoding]::UTF8.GetBytes($game))
    $test = [IO.File]::ReadAllText((Join-Path $root 'tools/NativeControlsSmoke.twin'))
    $project.AddSource('NativeControlsSmoke.twin', [Text.Encoding]::UTF8.GetBytes($test))
}
$project.Save($outputPath)
$verified = [TwinNode]::Load($outputPath)
if ($verified.Find('Sources/Src/modDX11.bas').Data.Length -lt 1000) { throw 'Renderer was not packed.' }
Write-Output "Updated and verified $Output"
