$ErrorActionPreference = 'Stop'
Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
[ComImport, Guid("B196B28F-BAB4-101A-B69C-00AA00341D07"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IClassFactory2 {
    [PreserveSig] int CreateInstance(IntPtr outer, ref Guid iid, out IntPtr instance);
    [PreserveSig] int LockServer(bool value);
    [PreserveSig] int GetLicInfo(ref LICINFO info);
    [PreserveSig] int RequestLicKey(uint reserved, [MarshalAs(UnmanagedType.BStr)] out string key);
    [PreserveSig] int CreateInstanceLic(IntPtr outer, IntPtr reserved, ref Guid iid, [MarshalAs(UnmanagedType.BStr)] string key, out IntPtr instance);
}
[StructLayout(LayoutKind.Sequential)] struct LICINFO {
    public int size;
    public int runtimeKeyAvailable;
    public int licenceVerified;
}
public static class ControlProbe {
    [DllImport("ole32.dll")] static extern int CoGetClassObject(ref Guid clsid, uint context, IntPtr server, ref Guid iid, [MarshalAs(UnmanagedType.Interface)] out IClassFactory2 factory);
    public static string Probe(string id) {
        var clsid = new Guid(id);
        var iid = new Guid("B196B28F-BAB4-101A-B69C-00AA00341D07");
        IClassFactory2 factory;
        int hr = CoGetClassObject(ref clsid, 1, IntPtr.Zero, ref iid, out factory);
        if (hr < 0) return "Class factory failed: 0x" + hr.ToString("X8");
        try {
            var info = new LICINFO { size = 12 };
            hr = factory.GetLicInfo(ref info);
            var unknown = new Guid("00000000-0000-0000-C000-000000000046");
            IntPtr instance;
            int create = factory.CreateInstance(IntPtr.Zero, ref unknown, out instance);
            if (instance != IntPtr.Zero) Marshal.Release(instance);
            return "GetLicInfo=0x" + hr.ToString("X8") + "; runtimeKeyAvailable=" + info.runtimeKeyAvailable + "; licenceVerified=" + info.licenceVerified + "; CreateInstance=0x" + create.ToString("X8");
        } finally { Marshal.ReleaseComObject(factory); }
    }
}
'@
foreach ($control in @(
    @{name='RichTextBox'; id='{3B7C8860-D78F-101B-B9B5-04021C009402}'},
    @{name='Winsock'; id='{248DD896-BB45-11CF-9ABC-0080C7E7B78D}'},
    @{name='SSTab'; id='{BDC217C5-ED16-11CD-956C-0000C04E4C0A}'}
)) {
    Write-Output ($control.name + ': ' + [ControlProbe]::Probe($control.id))
}
