;ScreenSaver.ahk
; Screensaver that runs a command.
;Skrommel @2006

#NoTrayIcon 

applicationname=ScreenSaver

StringLeft,param,1,2
If (param="" Or param="/c") 
  Goto,SETTINGS
If (param="/p")
  ExitApp

Run,E:\workspace\my-scripts\win\displaychanger2\screensaver.bat
ExitApp


SETTINGS:
Gui,Destroy
Gui,Add,Tab,W330 H380 xm,About

Gui,Tab
Gui,Add,Button,xm+10 y+10 GSETTINGSCANCEL Default w75,&OK
Gui,Add,Button,x+5 yp GSETTINGSCANCEL w75,&Cancel

Gui,Tab,1
Gui,Add,Picture,xm+20 ym+40 Icon1,%applicationname%.scr
Gui,Font,Bold
Gui,Add,Text,x+10 yp+10,%applicationname% v1.0
Gui,Font
Gui,Add,Text,xm+20 y+15,Screensaver that runs a command. Once compiled rename it as ScreenSaver.scr.
Gui,Add,Text,y+0,`t

Gui,Show,,%applicationname% Settings

hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE") 
Return


SETTINGSCANCEL:
Gui,Destroy
ExitApp


WM_MOUSEMOVE(wParam,lParam)
{
  Global hCurs
  MouseGetPos,,,winid,ctrl
  If ctrl in Static8,Static13,Static18
    DllCall("SetCursor","UInt",hCurs)
}