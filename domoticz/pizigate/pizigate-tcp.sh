#!/bin/sh

/home/pi/git/Domoticz-Zigate/Tools/pi-zigate.sh run
/usr/bin/socat /dev/serial0,b115200,raw,echo=0 tcp4-listen:9999
