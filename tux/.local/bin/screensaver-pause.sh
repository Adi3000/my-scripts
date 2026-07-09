/home/adi/.cargo/bin/xidlehook \
    --detect-sleep --socket /tmp/.screen-sleep.socket \
    --not-when-fullscreen --timer 180 \
    '/bin/bash /home/adi/workspace/my-scripts/tux/.local/bin/screen-sleep.sh'\
    '/bin/bash /home/adi/workspace/my-scripts/tux/.local/bin/screen-wake.sh'

/home/adi/.cargo/bin/xidlehook-client --socket /tmp/.screen-sleep.socket control --action Disable