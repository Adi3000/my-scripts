#!/bin/bash
export DISPLAY=:0.0
export WAYLAND_DISPLAY=wayland-0

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
      and .info.props["device.name"] == "alsa_card.pci-0000_07_00.1"
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
pactl set-card-profile alsa_card.pci-0000_07_00.1 $output_profile_name

output_sink=$(pactl -f json list sinks | jq '.[] | select( .properties."device.bus_path" == "pci-0000:07:00.1") | .index')
outputlink=$(pw-dump | jq -r '.[].info.props["node.name"]' | grep alsa_output.pci-0000_07_00.1.hdmi-stereo)

echo "Profile found : $output_profile_name, sink name : output_sink (link : $outputlink)"
grep -c '"'$outputlink'"'  $HOME/.local/share/wireplumber/scripts/90-waterfox-hdmi.lua > /dev/null || \
	sed -i 's/local HDMI_SINK = ".*/local HDMI_SINK = "'$outputlink'"/g' $HOME/.local/share/wireplumber/scripts/90-waterfox-hdmi.lua

