#!/bin/sh

dev_list=4-1.4.4 4-1.1.3
usb_vendor="0bda:9210:u" #RTL9210

# Apply quirk (disable UAS for $usb_vendor)
echo $usb_vendor > /sys/module/usb_storage/parameters/quirks

# Wait for USB devices to appear
sleep 2

# Reset both NVMe USB devices
for dev in $dev_list; do
    if [ -e /sys/bus/usb/devices/$dev/authorized ]; then
        echo 0 > /sys/bus/usb/devices/$dev/authorized
        sleep 1
        echo 1 > /sys/bus/usb/devices/$dev/authorized
    fi
done

# Give time for re-enumeration
sleep 2
