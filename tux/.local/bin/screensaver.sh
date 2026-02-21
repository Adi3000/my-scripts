#!/bin/bash
export DISPLAY=:0

on_wake() {
	echo "[$(date '+%F %T.%N')] Starting waking screen" >> /home/adi/.cache/screen-sleep.log
	xrandr --output DP-5 --mode 1920x1080 --primary
	#xrandr --output DP-1 --auto --same-as DP-1
	xrandr --output HDMI-0 --auto --left-of DP-5
	echo "[$(date '+%F %T.%N')] Waiting for audio to be available" >> /home/adi/.cache/screen-sleep.log
	sleep 2
	outputlink=$(pw-dump | jq -r '.[].info.props["node.name"]' | grep alsa_output.pci-0000_06_00.1.hdmi-stereo)
	echo "[$(date '+%F %T.%N')] Force linking Watefox to $outputlink" >> /home/adi/.cache/screen-sleep.log
	pw-link "Waterfox:output_FL" "${outputlink}:playback_FL"
	pw-link "Waterfox:output_FR" "${outputlink}:playback_FR"
	pw-link -d "Waterfox:output_FR" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FR" 2> /dev/null || echo "No old Arctis playback_FR audio link found, continue ..."
	pw-link -d "Waterfox:output_FL" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FL" 2> /dev/null || echo "No old Arctis playback_FR audio link found, continue ..."
	echo "[$(date '+%F %T.%N')] Waterfox linked to $outputlink" >> /home/adi/.cache/screen-sleep.log
}

trap 'on_wake' TERM INT HUP EXIT

echo "[$(date '+%F %T.%N')] setting up sleep mode" >> /home/adi/.cache/screen-sleep.log
xrandr --output HDMI-0 --off
xrandr --output DP-5 --off
echo "[$(date '+%F %T.%N')] xrandr done, switching audio soon ..." >> /home/adi/.cache/screen-sleep.log
sleep 2
outputlink=$(pw-dump | jq -r '.[].info.props["node.name"]' | grep alsa_output.pci-0000_06_00.1.hdmi-stereo)
echo "[$(date '+%F %T.%N')] switching audio to $outputlink" >> /home/adi/.cache/screen-sleep.log
pw-link "Waterfox:output_FL" "${outputlink}:playback_FL"
pw-link "Waterfox:output_FR" "${outputlink}:playback_FR"
pw-link -d "Waterfox:output_FR" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FR" || echo "No old Arctis playback_FR audio link found, continue ..."
pw-link -d "Waterfox:output_FL" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FL" || echo "No old Arctis playback_FR audio link found, continue ..."
echo "[$(date '+%F %T.%N')] audio for Waterfox linked to $outputlink" >> /home/adi/.cache/screen-sleep.log
sleep infinity &
wait $!
