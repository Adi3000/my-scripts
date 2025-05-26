#!/bin/bash
# Paused for now but still working
#plex_pass=/etc/letsencrypt/keys/plex.pass
#plex_certs=/etc/letsencrypt/live/plex.adi3000.com
#plex_cert_out=/var/lib/plexmediaserver/certificate.pfx
#ldap_certs=/etc/letsencrypt/live/adi3000.com
#ldap_cert_out=/etc/ldap/ssl
ovh_conf=/etc/letsencrypt/keys/ovh.ini
certbot_deploy_key=/etc/ssl/private/certbot-deploy/certbot.key
certbot_deploy_user=certbot
certbot_deploy_target=vpsfront.adi3000.com


/usr/bin/certbot renew  --dns-ovh --dns-ovh-credentials $ovh_conf
# Paused for now but still working
#openssl pkcs12 -export -out $plex_cert_out -passout pass:$(cat $plex_pass) -inkey $plex_certs/privkey.pem -in $plex_certs/cert.pem -certfile $plex_certs/chain.pem
#cp $ldap_certs/privkey.pem $ldap_certs/cert.pem $ldap_certs/chain.pem $ldap_certs/fullchain.pem $ldap_cert_out
#chown plex:plex $plex_cert_out
#chown -R openldap:openldap $ldap_cert_out

scp -i $certbot_deploy_key -r $ldap_certs ${certbot_deploy_user}@${certbot_deploy_target}:./certs
ssh -r $certbot_deploy_key ${certbot_deploy_user}@${certbot_deploy_target}  "sudo mv ~/certs/* /etc/letsencrypt/live/ && sudo chown -R root:root /etc/letsencrypt/live"
docker compose -f /home/adi/git/my-scripts/docker/traefik/docker-compose.yml --env-file /etc/default/traefik restart
