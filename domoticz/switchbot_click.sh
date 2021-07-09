#!/bin/bash

script=/home/pi/git/python-host/switchbot_py3.py
device=D6:20:E5:47:9E:94
loop=$1
wait=$(test -n "$2" && echo "$2" || echo "0")
sleep $wait
for i in $(seq $1); do
	sleep 2
	until /usr/bin/python3 $script -d $device -c press ; do sleep 5; done
done

