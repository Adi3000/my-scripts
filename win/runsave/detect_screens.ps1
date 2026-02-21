Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class RefreshDisplays {
    [DllImport("user32.dll")]
    public static extern int SendMessageTimeout(
        IntPtr hWnd,
        uint Msg,
        IntPtr wParam,
        IntPtr lParam,
        uint fuFlags,
        uint uTimeout,
        out IntPtr lpdwResult
    );
}
"@
[RefreshDisplays]::SendMessageTimeout([IntPtr]::Zero, 0x1D, [IntPtr]::Zero, [IntPtr]::Zero, 2, 1000, [ref][IntPtr]::Zero)