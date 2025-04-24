# How to

## Dependencies

```bash
sudo apt-get install jq yq git ufw sudo openssl
```
## Add to sudo

```bash
echo -n "What is the new user to add : "
read user_to_add
echo -n "What is the password ? : "
read -s password_to_set
sudo useradd --user-group --create-home -s /bin/bash -p $password_to_set $user_to_add
sudo usermod -a -G sudo $user_to_add
```

## Install docker

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
## Resources

* [UFW docker rules](https://github.com/chaifeng/ufw-docker?tab=readme-ov-file#tldr=)
