#!/bin/sh

gpio mode 0 out
gpio mode 2 out
gpio write 2 1 
gpio write 0 0
gpio write 0 1
/usr/bin/socat /dev/serial0,b115200,raw,echo=0 tcp4-listen:9999
