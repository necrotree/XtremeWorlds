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
