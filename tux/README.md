/etc/modprobe.d/nvidia-drm.conf
```
options nvidia-drm modeset=1
options nvidia-drm fbdev=1
```


/etc/davfs2/secrets
```
/home/adi/nextcloud <user> <password>
```



```bash
apt install linux-headers-$(uname -r) build-essential dkms nvidia-detect nvidia-kernel-dkms nvidia-driver keepassxc davfs2 
```

~/.xsessionrc
```bash
. /etc/profile
. ~/.profile
```

.config/xfce4/xinitrc
```bash
#!/bin/sh
if [ -f "$HOME/.i18n" ]; then
    . "$HOME/.i18n"
fi
. /etc/xdg/xfce4/xinitrc
```

~/.i18n
```
export LANGUAGE=fr_FR.utf8
export LANG=fr_FR.utf8
export LC_ALL=fr_FR.utf8
```
