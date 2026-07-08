Use this procedure : 

https://gist.github.com/avoidik/d8fc39a372db680090edd5322d60848f#file-readme-md

```
sudo lsblk -o name,mountpoint,size,partuuid /dev/sda[0-9]
```

boot sequence
```
echo program_usb_boot_mode=1 | sudo tee -a /boot/firmware/config.txt
```

check
```
 vcgencmd otp_dump | grep 17: 17:3020000a
```
check that `17` is `3020000a`

or check through doing :
```
pip3 install --user vcgencmd
python3
```
and execute
```
from vcgencmd import Vcgencmd

vcgm = Vcgencmd()
output = vcgm.version()
print(output)
```

