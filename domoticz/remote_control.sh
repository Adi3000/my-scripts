#!/bin/bash

codes_list=/home/pi/git/my-scripts/domoticz/codes.txt
script=/home/pi/git/python-broadlink/cli/broadlink_cli
source $codes_list

echo "Will send $1 command with  ${!1}"
python $script --type $remote_type --host $remote_host --mac $remote_mac --send ${!1}
