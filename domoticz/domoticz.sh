#/bin/bash
. /home/domoticz/.config/domoticz.conf
$DOMOTICZ_HOME/domoticz -www $DOMOTICZ_PORT -sslwww 0 -nowwwpwd -daemon -pidfile $DOMOTICZ_PIDFILE
export DOMOTICZ_PIDFILE
trap 'test -f $DOMOTICZ_PIDFILE && kill $(cat $DOMOTICZ_PIDFILE)' 0
lsof -p $(cat $DOMOTICZ_PIDFILE) +r 1 &>/dev/null
exit 0
