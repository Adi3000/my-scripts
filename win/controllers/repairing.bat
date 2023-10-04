@echo off
rem set controller1="00:1F:E2:C3:17:9D"
set controller1="84:30:95:79:28:E3"
rem set controller2="00:1F:E2:C3:17:9D"
rem set controller2="00:22:68:B4:EB:E1"

echo Initialisation...
btcom -b%controller1% -r -s1124
btcom -b%controller1% -r -s1200
rem btcom -b%controller2% -r -s1124
rem btcom -b%controller2% -r -s1200
btpair -b%controller1% -u
rem btpair -b%controller2% -u
rem powershell -command .\bluetooth-switch.ps1 -BluetoothStatus Off
echo Maintient la touche SHARE puis la touch PS central en même temps pendant 3 seconde...
echo Si la manette clignotte appuie sur une touche pour continuer
pause >nul
rem powershell -command .\bluetooth-switch.ps1 -BluetoothStatus On
echo Pairing
btpair -n"Wireless Controller" -p0000
rem btpair -b%controller2% -p0000
echo Add service
btcom -b%controller1% -c -s1124
rem btcom -b%controller2% -c -s1124
powershell -command .\repairing.ps1
pause
