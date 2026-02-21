MonitorCount := MonitorGetCount()
MonitorPrimary := MonitorGetPrimary()
MsgBox "Monitor Count:`t" MonitorCount "`nPrimary Monitor:`t" MonitorPrimary

if MonitorCount = 2
{
    Run("c:\Windows\System32\desk.cpl")
    Sleep(2000)
    Send("{Shift}+{Tab}")
    Send("{Shift}+{Tab}")
    Send("!{F4}")

    ; twice opened because first time focus is misplaced
    Run("c:\Windows\System32\desk.cpl")
    Sleep(2000)
    Send("{Shift}+{Tab}")
    Send("{Shift}+{Tab}")
    Send("{Space}")
    Sleep(1000)
    Send("!{F4}")
}
