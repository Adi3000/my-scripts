Use this procedure : 

https://gist.github.com/avoidik/d8fc39a372db680090edd5322d60848f#file-readme-md

```
sed -i 's/buster/oldoldstable/g' /etc/apt/sources.list.d/raspi.list
sed -i 's/buster/oldoldstable/g' /etc/apt/sources.list
```

```
sudo lsblk -o name,mountpoint,size,partuuid /dev/sda[0-9]
```


boot sequence
```
echo program_usb_boot_mode=1 | sudo tee -a /boot/config.txt
```

check
```
pip3 install --user vcgencmd
python3
```

```
from vcgencmd import Vcgencmd

vcgm = Vcgencmd()
output = vcgm.version()
print(output)
```
check that `17` is `3020000a`



