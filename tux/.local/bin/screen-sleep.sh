#!/bin/bash


export DISPLAY=:0.0
export WAYLAND_DISPLAY=wayland-0
#echo "[$(date '+%F %T.%N')] setting up sleep mode" >> /home/adi/.cache/screen-sleep.log
#touch /tmp/.screen-sleep.lck

wlopm --off HDMI-A-1
wlopm --off DP-3
wlopm --on DP-1

output_profile_id=$(pw-dump | jq -r '
  .[]
  | select(.type == "PipeWire:Interface:Device")
  | .info.params.EnumRoute[]
  | select(
      (.info | tostring | contains("EP-HDMI-RX"))
      or
      (.info | tostring | contains("TOSHIBA-TV"))
    )
  | .devices[]
')
output_profile_name=$(pw-dump | jq -r '
  .[]
  | select(
      .type == "PipeWire:Interface:Device"
      and .info.props["device.name"] == "alsa_card.pci-0000_06_00.1"
    )
  | .info.params.EnumProfile[]
  | select(
      any(
        .classes[];
        type == "array"
        and .[0] == "Audio/Sink"
        and .[1] == 1
        and .[2] == "card.profile.devices"
        and .[3] == ['$output_profile_id']
      )
    )
  | .name
')
pactl set-card-profile alsa_card.pci-0000_06_00.1 $output_profile_name
output_sink=$(pactl -f json list sinks | jq '.[] | select( .properties."device.bus_path" == "pci-0000:06:00.1") | .index')
outputlink=$(pw-dump | jq -r '.[].info.props["node.name"]' | grep alsa_output.pci-0000_06_00.1.hdmi-stereo)
pw-link "Waterfox:output_FL" "${outputlink}:playback_FL"
pw-link "Waterfox:output_FR" "${outputlink}:playback_FR"
pw-link -d "Waterfox:output_FR" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FR" 2> /dev/null || echo "No old Arctis playback_FR audio link found, continue ..."
pw-link -d "Waterfox:output_FL" "alsa_output.usb-SteelSeries_Arctis_Pro_Wireless-00.stereo-game:playback_FL" 2> /dev/null || echo "No old Arctis playback_FR audio link found, continue ..."
