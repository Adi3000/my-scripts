#/bin/bash

. /home/domoticz/.config/domoticz.conf
echo -n "Stopping domoticz..."
docker stop $DOMOTICZ_SERVICE
echo "  done"
