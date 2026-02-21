#!/bin/bash


export DISPLAY=:0.0

echo "[$(date '+%F %T.%N')] setting up sleep mode" >> /home/adi/.cache/screen-sleep.log
touch /tmp/.screen-sleep.lck
xrandr --output DP-1 --auto --primary
xrandr --output HDMI-0 --off
xrandr --output DP-5 --off
echo "[$(date '+%F %T.%N')] xrandr done, switching audio soon ..." >> /home/adi/.cache/screen-sleep.log
sleep 2
output_sink=$(pactl -f json list sinks | jq '.[] | select( .properties."device.bus_path" == "pci-0000:06:00.1") | .index')
sink_input=$(pactl -f json list sink-inputs | jq '.[] | select( .properties."application.name" == "Waterfox") | .index')

echo $output_sink $sink_input 
#outputlink=$(pw-dump | jq -r '.[].info.props["node.name"]' | grep alsa_output.pci-0000_06_00.1.hdmi-stereo)
#echo "[$(date '+%F %T.%N')] switching audio to $outputlink" >> /home/adi/.cache/screen-sleep.log
#pw-link "Waterfox:output_FL" "${outputlink}:playback_FL"
#pw-link "Waterfox:output_FR" "${outputlink}:playback_FR"
#pw-link -d "Waterfox:output_FR" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FR" || echo "No old Arctis playback_FR audio link found, continue ..."
#pw-link -d "Waterfox:output_FL" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FL" || echo "No old Arctis playback_FR audio link found, continue ..."
#echo "[$(date '+%F %T.%N')] audio for Waterfox linked to $outputlink" >> /home/adi/.cache/screen-sleep.log
#sleep 5
echo "[$(date '+%F %T.%N')] releasing lock " >> /home/adi/.cache/screen-sleep.log
rm -v /tmp/.screen-sleep.lck >> /home/adi/.cache/screen-sleep.log
