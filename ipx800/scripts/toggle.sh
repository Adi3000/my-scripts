#!/bin/bash
if [ -z "$1" ]; then
        echo "Error : $1 is not a number" >&2
        exit 3
fi
plugId=$1
ipx800="http://ipx800:2623"
shift
endpoint="$ipx800/leds.cgi?led=${plugId}"
if [ -n "$1" ]; then
        onOff=$1
	endpoint="$ipx800/preset.htm?set${plugId}=$1"
fi

result=$(curl -s -I -XGET "$endpoint")
if [ $(echo "$result" | grep "HTTP" | grep -c 200 ) -eq 1 ]; then
	echo "Target $1 is set to $onOff"
else
	echo "$result" | grep -c "HTTP" | grep -c 200
	echo "Error for <$plugId> : $result"
	exit 1
fi
exit 0
