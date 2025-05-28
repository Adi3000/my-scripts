# How to

## Dependencies

```bash
sudo apt-get install jq yq git ufw sudo openssl
```
## Add to sudo

```bash
sudo useradd --user-group --create-home -s /bin/bash -G sudo -p `openssl passwd` $user_to_add
sudo passwd -l debian
sudo usermod -p '!' debian
```

## Install docker

```
sudo mkdir -p /home/docker/data
sudo chmod 750 /home/docker/data
sudo ln -s /var/lib/docker /home/docker/data 
```

### Install procedure

* [Documentation](https://docs.docker.com/engine/install/debian/#install-using-the-repository)

### Reduce logs

```bash
echo '{                    
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}' | sudo tee /etc/docker/daemon.json
```

### Add UFW rules

execute `init_ufw.sh`
create a `/etc/default/ufw-ipconfig` with the following content 
```
export SPAMLIST="blockedip"
export SPAMDROPMSG="BLOCKED IP DROP"
export SYSCTL="/sbin/sysctl"
export BLOCKEDIPS="/root/scripts/blocked.ips.txt"
# interface connected to the Internet
export PUB_IF="eno1" # public/main WAN interface
export VPN_IF="eno1.0"  OpenVpn (optional)
export BR_IF="br0"  # OpenVpn (optional)
export TAP_IF="tap0" # OpenVpn (optional)
export PUB_IP="XX.XX.XX.XX" # public IP
export PUB_FO="XX.XX.XX.XX" # failover ip / secondary ip
export VPS_FRONT="XX.XX.XX.XX" # other front/bastion vps
export PUBLIC_PORT_LIST="80 443 25 110 143" # add other if needed
```
## DNS Blocky

* [UFW docker rules](https://github.com/chaifeng/ufw-docker?tab=readme-ov-file#tldr=)
```
sudo apt-get install bind9-dnsutils
sudo wget -O /usr/local/bin/ufw-docker \
  https://github.com/chaifeng/ufw-docker/raw/master/ufw-docker
sudo chmod +x /usr/local/bin/ufw-docker
sudo ufw enable
sudo ufw-docker install
sudo systemctl restart ufw
sudo bash ufw_dns_updater.sh
sudo reboot
```



## Main service config file

* /etc/traefik
* /etc/default/traefik
* /etc/default/ufw-ipconfig
* /etc/blocky

## Certificat transfert

### On source 

```
mkdir -p /etc/ssl/private/certbot-deploy
ssh-keygen -t ed25519 -f /etc/ssl/private/certbot-deploy/certbot.key
```

### On target
```
sudo mkdir -p /etc/letsencrypt/live
sudo useradd --shell /bin/sh --no-user-group --home-dir /home/certbot --create-home --system
sudo -u certbot mkdir /home/certbot/certs
sudo -u certbot nano ~certbot/.ssh/authorized_keys # then past public key /etc/ssl/private/certbot-deploy/certbot.pub
```
`/etc/sudoers.d/certbot`
```
certbot ALL=(ALL) NOPASSWD: /usr/bin/mv, /bin/chown
```

