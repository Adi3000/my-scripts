#!/bin/bash


export DISPLAY=:0.0
export WAYLAND_DISPLAY=wayland-0

wlopm --off HDMI-A-1
wlopm --off DP-3
wlopm --on DP-2

