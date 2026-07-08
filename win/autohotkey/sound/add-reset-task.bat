@ECHO OFF

ECHO Add the scheduled task...

schtasks /Create /RL HIGHEST /TR E:\workspace\my-scripts\autohotkey\sound\reset-audio-channel.bat /TN "Reset Audio output" /SC ONLOGON