#!/bin/bash
# Paused for now but still working
#plex_pass=/etc/letsencrypt/keys/plex.pass
#plex_certs=/etc/letsencrypt/live/plex.adi3000.com
#plex_cert_out=/var/lib/plexmediaserver/certificate.pfx
#ldap_certs=/etc/letsencrypt/live/adi3000.com
#ldap_cert_out=/etc/ldap/ssl
ovh_conf=/etc/letsencrypt/keys/ovh.ini

/usr/bin/certbot renew  --dns-ovh --dns-ovh-credentials $ovh_conf
# Paused for now but still working
#openssl pkcs12 -export -out $plex_cert_out -passout pass:$(cat $plex_pass) -inkey $plex_certs/privkey.pem -in $plex_certs/cert.pem -certfile $plex_certs/chain.pem
#cp $ldap_certs/privkey.pem $ldap_certs/cert.pem $ldap_certs/chain.pem $ldap_certs/fullchain.pem $ldap_cert_out
#chown plex:plex $plex_cert_out
#chown -R openldap:openldap $ldap_cert_out
docker compose -f /home/adi/git/my-scripts/docker/traefik/docker-compose.yml --env-file /etc/default/traefik restart
