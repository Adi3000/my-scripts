#!/bin/bash
if [ -z "$1" ]; then echo "Usage $0 <firmware_version>"; exit 1; fi
flash_version=$1
working_dir="/tmp/pizigate_$(date +%s)"
firmware_file="$working_dir/ZiGate_$flash_version.bin"
domoticz_home=/home/pi/domoticz
jennic_module_programmer_bin_dir=/home/pi/git/JennicModuleProgrammer/Build


mkdir -p $working_dir
cd $working_dir
wget "https://github.com/fairecasoimeme/ZiGate/releases/download/$flash_version/ZiGate_$flash_version.bin" -O "$firmware_file"
echo "Go to flash mode with $domoticz_home/plugins/Domoticz-Zigate/Tools/pi-zigate.sh flash :"
$domoticz_home/plugins/Domoticz-Zigate/Tools/pi-zigate.sh flash || exit 2
echo "... Mode flash done"

echo "Flashing pizigate with binaries in jennic_module_programmer_bin_dir"
cd $jennic_module_programmer_bin_dir
sudo ./JennicModuleProgrammer  -V 6 -P 115200 -f "$firmware_file" -s /dev/serial0 || exit 3

echo "Go to run mode with $domoticz_home/plugins/Domoticz-Zigate/Tools/pi-zigate.sh run : "
$domoticz_home/plugins/Domoticz-Zigate/Tools/pi-zigate.sh run || exit 4
echo "... Mode run done !"

echo "Clearing files..."
rm -rfv $working_dir || exit 5
echo " done"

