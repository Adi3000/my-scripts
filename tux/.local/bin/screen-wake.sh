#!/bin/bash
export DISPLAY=:0.0

echo "[$(date '+%F %T.%N')] Checking lock file" >> /home/adi/.cache/screen-sleep.log
if [ -f /tmp/.screen-sleep.lck ]; then
    echo "[$(date '+%F %T.%N')] Lockfile found, will not wake screen" >> /home/adi/.cache/screen-sleep.log
    exit 0
fi

echo "[$(date '+%F %T.%N')] Starting waking screen" >> /home/adi/.cache/screen-sleep.log
xrandr --output DP-5 --auto --primary
xrandr --output DP-1 --mode 1920x1080 --same-as DP-5
xrandr --output HDMI-0 --auto --left-of DP-5
echo "[$(date '+%F %T.%N')] Waiting for audio to be available" >> /home/adi/.cache/screen-sleep.log
sleep 2
output_sink=$(pactl -f json list sinks | jq '.[] | select( .properties."device.bus_path" == "pci-0000:06:00.1") | .index')
sink_input=$(pactl -f json list sink-inputs | jq '.[] | select( .properties."application.name" == "Waterfox") | .index')
echo "Want to execute : pactl move-sink-input $sink_input $output_sink"
#outputlink=$(pw-dump | jq -r '.[].info.props["node.name"]' | grep alsa_output.pci-0000_06_00.1.hdmi-stereo)
#echo "[$(date '+%F %T.%N')] Force linking Watefox to $outputlink" >> /home/adi/.cache/screen-sleep.log
#pw-link "Waterfox:output_FL" "${outputlink}:playback_FL"
#pw-link "Waterfox:output_FR" "${outputlink}:playback_FR"
#pw-link -d "Waterfox:output_FR" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FR" 2> /dev/null || echo "No old Arctis playback_FR audio link found, continue ..."
#pw-link -d "Waterfox:output_FL" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FL" 2> /dev/null || echo "No old Arctis playback_FR audio link found, continue ..."
#echo "[$(date '+%F %T.%N')] Waterfox linked to $outputlink" >> /home/adi/.cache/screen-sleep.log

