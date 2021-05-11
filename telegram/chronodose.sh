#!/bin/bash

url="https://vitemadose.gitlab.io/vitemadose"
jq_query='(.centres_disponibles[] | del( .appointment_schedules[] | select ( .name != "chronodose" )) | select( .appointment_schedules[].total > 0) )| [.internal_id,.last_scan_with_availabilities,.nom,.url,.metadata.address,.appointment_schedules[0].total] | @tsv '
if [ -z "$1" ]; then
	echo -e "Error : Usage $0 <config-file> : You must provide a config file" 1>&2
        exit 1
fi
. $1
if [ -z "$TOKEN" ]; then
	echo "TOKEN variable was not found, pleas define it onto the config file provided" 1>&2
	exit 2
fi
if [ -z "$CHAT" ]; then
        echo "CHAT variable was not found, pleas define it onto the config file provided" 1>&2
	exit 3
fi
if [ -z "$FILE" ]; then
	echo "FILE variable was not found, pleas define it onto the config file provided" 1>&2
        exit 4
fi


sendNewAppointment() {
        nbRdv=$(echo "$line" | cut -d\| -f6);
        centerName=$(echo "$line" | cut -d\| -f3);
        centerAddress=$(echo "$line" | cut -d\| -f5);
        aptUrl=$(echo "$line" | cut -d\| -f4);
        curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" -d parse_mode="html" -d chat_id="$CHAT" \
-d text="Il y a <b>$nbRdv</b> disponible ici :
<b>${centerName}</b>
<i>$centerAddress</i>.
Pour prendre rendez vous c'est ici :
$aptUrl" > /dev/null
}

sendNoMoreAppointment() {
        centerName=$(echo "$line" | cut -d\| -f3);
        centerAddress=$(echo "$line" | cut -d\| -f5);
        lastApt=$(echo "$line" | cut -d\| -f2);
        curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" -d parse_mode="html" -d chat_id="$CHAT" \
-d text="Les rendez vous ont disparus pour :
<b>${centerName}</b>
<i>$centerAddress</i>.
Ils étaient encore disponible le
<b>$lastApt</b>" > /dev/null
}

sendError() {
	echo "Error $1"
        curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" -d parse_mode="html" -d chat_id="$CHAT" -d text="<b>Vitemadose ne repond pas correctement ! ça risque de spammer </b> :
<pre>
$1
</pre>" > /dev/null
}


response=$(curl -s "$url/59.json" | jq -e -r "$jq_query" 2> "$FILE.err" )


if [ -n "$(cat $FILE.err)" ]; then
	sendError "$(cat $FILE.err)"
	rm "$FILE.err"
	exit 5
fi

echo "$response" | sed 's:\t:|:g' | sort >  "$FILE.tmp"


cat "$FILE.tmp" | \
while read line; do
        vmdId=$(echo "$line" | cut -d\| -f1)
        if [ $(grep -c  "^$vmdId"  "$FILE" ) -eq 0 ]; then
               sendNewAppointment
        fi;
done

cat "$FILE" | \
while read line; do
	vmdId=$(echo "$line" | cut -d\| -f1)
	if [ $(grep -c "^$vmdId"  "$FILE.tmp") -eq 0 ]; then
               sendNoMoreAppointment
	fi
done


mv "$FILE.tmp" "$FILE"
