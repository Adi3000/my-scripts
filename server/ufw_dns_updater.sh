#!/bin/bash

file_list=/etc/noip/domain.lst

for domain in $(cat $file_list); do
	resolvedip=$(getent hosts $domain | awk '{ print $1 }')
	subdomain=$(echo $domain | cut -d. -f 1)
	/usr/sbin/ufw route allow proto tcp from $resolvedip to any port 53
	/usr/sbin/ufw route allow proto udp from $resolvedip to any port 53
	yq -y -i '.clientLookup.clients."'$subdomain'" = ["'$resolvedip'"]' /etc/blocky/config.yml
done
