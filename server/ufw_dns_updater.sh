#!/bin/bash

file_list=/etc/noip/domain.lst
docker_ports=(53 9000 1883 10050 10051)

for domain in $(cat $file_list); do
	resolvedip=$(nslookup $domain | awk '/^Address: / { print $2 ; exit }')
	subdomain=$(echo $domain | cut -d. -f 1)
	for port in ${docker_ports[@]}; do
            /usr/sbin/ufw route allow proto tcp from $resolvedip to any port $port
	    /usr/sbin/ufw route allow proto udp from $resolvedip to any port $port
        done
	yq -y -i '.clientLookup.clients."'$subdomain'" = ["'$resolvedip'"]' /etc/blocky/config.yml
done
