#!/bin/bash

file_list=/etc/noip/domain.lst
docker_ports=(53 12183)

for domain in $(cat $file_list); do
	resolvedip=$(getent hosts $domain | awk '{ print $1 }')
	subdomain=$(echo $domain | cut -d. -f 1)
	for port in ${docker_ports[@]}; do
            /usr/sbin/ufw route allow proto tcp from $resolvedip to any port $port
	    /usr/sbin/ufw route allow proto udp from $resolvedip to any port $port
        done
	yq -y -i '.clientLookup.clients."'$subdomain'" = ["'$resolvedip'"]' /etc/blocky/config.yml
done
