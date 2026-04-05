#!/bin/bash

gamepad_mac="$1"
test -n "$gamepad_mac" || (zenity --error --text="Aucune manette sélectionnée" && exit 1) 

( sleep 2 &&\
    echo "agent on" &&\
    echo "default-agent" &&\
    echo "scan on" &&\
    sleep 2 &&\
    echo "pair $gamepad_mac" &&\
    sleep 5 &&\
    echo "yes" ) | bluetoothctl 

if bluetoothctl info $gamepad_mac; then
    zenity --info --text="Manette $gamepad_mac connectée"
    exit 0
else
    bluetoothctl remove "$gamepad_mac" || echo "No $gamepad_mac device found, continue..."
    zenity --error --text="Manette $gamepad_mac non trouvé, vérifier qu'elle est en mode recherche\n\n(Presser 5 secondes les boutons [Share] et [PS])"
    exit 2
fi
