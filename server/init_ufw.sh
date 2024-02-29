#!/bin/bash

#define the
#- PUBLIC_PORT_LIST
#- PUBIF
#- VPS_FRONT
#- TAP_IF
#- BR_IF

. /etc/default/ufw-ipconfig

# Stop certain attacks
echo "Setting sysctl IPv4 settings…"
$SYSCTL net.ipv4.ip_forward=1
$SYSCTL net.ipv4.conf.all.send_redirects=0
$SYSCTL net.ipv4.conf.default.send_redirects=0
$SYSCTL net.ipv4.conf.all.accept_source_route=0
$SYSCTL net.ipv4.conf.all.accept_redirects=0
$SYSCTL net.ipv4.conf.all.secure_redirects=0
$SYSCTL net.ipv4.conf.all.log_martians=1
$SYSCTL net.ipv4.conf.default.accept_source_route=0
$SYSCTL net.ipv4.conf.default.accept_redirects=0
$SYSCTL net.ipv4.conf.default.secure_redirects=0
$SYSCTL net.ipv4.icmp_echo_ignore_broadcasts=1
#$SYSCTL net.ipv4.icmp_ignore_bogus_error_messages=1
$SYSCTL net.ipv4.tcp_syncookies=1
$SYSCTL net.ipv4.conf.all.rp_filter=0
$SYSCTL net.ipv4.conf.default.rp_filter=0
#$SYSCTL kernel.exec-shield=1
$SYSCTL kernel.randomize_va_space=1

modprobe ip_conntrack

#Unlimited traffic for loopback
ufw allow in on lo
ufw allow out on lo
ufw route allow in on lo out on lo

if [ -f "${BLOCKEDIPS}" ]; then
  bad_ips=$(egrep -v -E "^#|^$" "${BLOCKEDIPS}")
  for ipblock in $bad_ips
  do
    ufw deny from $ipblock
  done
fi

ufw default deny incoming
ufw default deny routed
ufw default allow outgoing

#VPS Front traffic
ufw allow in on ${VPS_FRONT}
ufw allow out on ${VPS_FRONT}
ufw route allow in on ${VPS_FRONT}

#VPN interfaces freedom
ufw allow in on ${TAP_IF}
ufw allow out on ${TAP_IF}
ufw allow in on ${BR_IF}
ufw allow out on ${BR_IF}
ufw route allow in on ${TAP_IF}
ufw route allow out on ${TAP_IF}
ufw route allow in on ${BR_IF}
ufw route allow out on ${BR_IF}
ufw allow in from 192.168.26.0/24 to 192.168.26.0/24
ufw allow out from 192.168.26.0/24 to 192.168.26.0/24
ufw allow in to 172.16.0.0/12

for public_port in $PUBLIC_PORT_LIST; do
	echo "Allowing rules on ${PUB_IF} for ${public_port}"
        ufw allow in on ${PUB_IF} to any port ${public_port} proto tcp
	ufw allow in on ${PUB_IF} to any port ${public_port} proto udp
done


ufw deny in on ${PUB_IF} to any port 137:139 proto tcp
ufw deny in on ${PUB_IF} to any port 137:139 proto udp
