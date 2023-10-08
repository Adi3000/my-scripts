#/bin/bash
. /home/domoticz/.config/domoticz.conf
#$DOMOTICZ_HOME/domoticz -www $DOMOTICZ_PORT -noupdates -sslwww 0 -nowwwpwd -daemon -pidfile $DOMOTICZ_PIDFILE

test "$(docker container inspect --format '{{.State.Status}}' $DOMOTICZ_SERVICE 2>&1)" == "running" && docker stop $DOMOTICZ_SERVICE && exit 0

docker run \
	--rm --name $DOMOTICZ_SERVICE \
	-v /home/adi/git/my-scripts:/home/adi/git/my-scripts \
	-v /home/adi/git/python-broadlink:/home/adi/git/python-broadlink/ \
	-v /home/domoticz/domoticz/userdata:/opt/domoticz/userdata:rw \
	-v /home/domoticz/domoticz/data/www:/opt/domoticz/www/templates:rw \
	-v /home/domoticz/domoticz/data:/opt/domoticz/data:rw  \
	-e "HOME=/opt/domoticz/data" \
	-p $DOMOTICZ_PORT:8080 -p 9440:9440 domoticz/domoticz:2023-beta.15563 \
	/opt/domoticz/domoticz -noupdates -sslwww 0 -dbase /opt/domoticz/data/domoticz.db
exit 0
