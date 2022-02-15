#!/bin/bash

codes_list=/home/adi/git/my-scripts/domoticz/codes.txt
script=/home/adi/git/python-broadlink/cli/broadlink_cli
source $codes_list

echo "Will send $1 command with  ${!1}"
python3 $script --type $remote_type --host $remote_host --mac $remote_mac --send ${!1}
