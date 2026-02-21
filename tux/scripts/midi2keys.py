import rtmidi
import uinput


device = uinput.Device([
    uinput.KEY_LEFTSHIFT,
    uinput.KEY_RIGHTSHIFT,
    uinput.KEY_A
])

def keypress(key):
    subprocess.call(["xdotool", "key", key])

midi = rtmidi.MidiIn()

target = "Alesis Nitro"
ports = midi.get_ports()
idx = next(i for i,n in enumerate(ports) if target in n)
midi.open_port(idx)


while True:
    msg = midi.get_message()
    if msg:
        data, timestamp = msg
        status, note, velocity = data
        if status == 153 and (note == 38 or note == 40) and velocity > 0:
            device.emit_click(uinput.KEY_LEFTSHIFT)
            print(f'{note} {status}')
#        elif status == 153 and note == 36 and velocity > 0:
#            device.emit_click(uinput.KEY_RIGHTSHIFT)
