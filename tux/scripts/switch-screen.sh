#!/bin/bash

echo "$(date): setting up X11.." >> /home/adi/.cache/switch-screen.log
sudo -v || exit 1

sudo cp /home/adi/.config/X11/xorg.conf.split /etc/X11/xorg.conf

sudo systemctl restart display-manager

echo "$(date): setting up xinputs"  >> /home/adi/.cache/switch-screen.log

original_pointer=$(xinput list --id-only "Virtual core pointer")
original_keyboard=$(xinput list --id-only "Virtual core keyboard")

k400_keyboard=$(xinput list --id-only "keyboard:Logitech K400")
second_pointer=$(xinput list --id-only "pointer:Logitech USB Optical Mouse")
echo "$(date): detatch second inputs..."  >> /home/adi/.cache/switch-screen.log

xinput float $k400_keyboard
xinput float $second_pointer

echo "$(date): attach second inputs..."  >> /home/adi/.cache/switch-screen.log
xinput create-master "Screen1"
xinput reattach $second_pointer "Screen1 pointer"
xinput reattach $k400_keyboard "Screen1 keyboard"

echo "$(date): Done"  >> /home/adi/.cache/switch-screen.log
