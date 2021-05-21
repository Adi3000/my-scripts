#!/bin/bash

if [ -z "$1" ]; then
	echo -e "Error : Usage $0 <config-file> : You must provide a config file" 1>&2
        exit 1
fi
. $1
url="https://www.espace-citoyens.net/pouceetpuce/espace-citoyens/DemandeEnfance/NouvelleDemandeReservationSeancesGetActivites"
jq_query='.listeSeances[] |  select ( .IdLieu == '$PP_CENTRE') | select( .NbPlacesRestantes > 0) | select(.ListeDates[0].DatDebutSeance  | test("^'$PP_YYYYMM'[0-2][0-9]10000")) | [.IdSeance, .LibPublication, .NbPlacesRestantes, .NbPlacesRestantesListeAttente,.ListeDates[0].DatDebutSeance] | @tsv'
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
if [ -z "$PP_SESSION_ID" ]; then
        echo "PP_SESSION_ID variable was not found, pleas define it onto the config file provided" 1>&2
        exit 7
fi
if [ -z "$PP_INSCRIPTION_ID" ]; then
        echo "PP_INSCRIPTION_ID variable was not found, pleas define it onto the config file provided" 1>&2
        exit 8
fi
if [ -z "$PP_CENTRE" ]; then
        echo "PP_CENTRE variable was not found, pleas define it onto the config file provided" 1>&2
        exit 8
fi
if [ -z "$PP_YYYYMM" ]; then
        echo "PP_YYYYMM variable was not found, pleas define it onto the config file provided" 1>&2
        exit 8
fi

sendNewAppointment() {
        nbRdv=$(echo "$line" | cut -d\| -f3)
        centerName=$(echo "$line" | cut -d\| -f2)
        nbWaiting=$(echo "$line" | cut -d\| -f4)
        aptDate=$(echo "$line" | cut -d\| -f5)
        curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" -d parse_mode="html" -d chat_id="$CHAT" \
-d text="Il y a <b>$nbRdv</b> places disponible ici :

<b>${centerName}</b>
<i>date</i> : $aptDate

Go to : https://www.espace-citoyens.net/pouceetpuce/espace-citoyens/CompteCitoyen" > /dev/null
}

sendNoMoreAppointment() {
        centerName=$(echo "$line" | cut -d\| -f2);
        nbWaiting=$(echo "$line" | cut -d\| -f4)
        lastApt=$(echo "$line" | cut -d\| -f5);
        curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" -d parse_mode="html" -d chat_id="$CHAT" \
-d text="Les places ont disparues pour :
<b>${centerName}</b>
<i>date</i> : $aptDate
Ils y a <b>$nbWaiting</b> places en attente" > /dev/null
}

sendError() {
	echo "Error $1"
        curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" -d parse_mode="html" -d chat_id="$CHAT" -d text="<b>Pouce et Puces ne repond pas correctement ! ça risque de spammer </b> :
<pre>
$1
</pre>" > /dev/null
}


response=$(curl -s "$url" -H "Cookie: ASP.NET_SessionIdEC=$PP_SESSION_ID;" --data-raw "inscriptions=%22${PP_INSCRIPTION_ID}%22"| jq -e -r "$jq_query" 2> "$FILE.err" )

if [ -n "$(cat $FILE.err)" ]; then
	sendError "$(cat $FILE.err)"
	rm "$FILE.err"
	exit 5
fi

echo "$response" | sed 's:\t:|:g' | sort >  "$FILE.tmp"


cat "$FILE.tmp" | \
while read line; do
        seanceId=$(echo "$line" | cut -d\| -f1)
        if [ $(grep -c  "^$seanceId"  "$FILE" ) -eq 0 ]; then
               sendNewAppointment
        fi
done

cat "$FILE" | \
while read line; do
	seanceId=$(echo "$line" | cut -d\| -f1)
	if [ $(grep -c "^$seanceId"  "$FILE.tmp") -eq 0 ]; then
               sendNoMoreAppointment
	fi
done


mv "$FILE.tmp" "$FILE"
