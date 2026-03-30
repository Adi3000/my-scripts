https://akashrajpurohit.com/blog/setup-shareable-drive-with-nfs-in-linux/

```
sudo apt-get install nfs-kernel-server -y
```

/etc/exports
```
/mnt/nanopi/data       xx.yyy.zzz.aaa(rw,sync,no_subtree_check,no_root_squash)
```

```
chown -R www-data:www-data /mnt/nanopi/data/nextcloud/owncloud/data
```


Autofs

`/etc/auto.master`
```
/mnt/nanopi /etc/auto.nanopi --ghost --timeout=60
```

`/etc/auto.nanopi`
```
data  -fstype=nfs4,rw  my-nfs-server.example.com:/mnt/nanopi/data
```

```
sudo systemctl restart autofs
```

To handle high throughput :

```
# Add service to force `usb-storage` instead of `uas` driver
sudo ln -s /home/pi/git/my-scripts/nanopi/nfs/force-usb-bot.service /etc/systemd/system/force-usb-bot.service
sudo systemctl enable force-usb-bot.service
sudo systemctl daemon-reload
```
