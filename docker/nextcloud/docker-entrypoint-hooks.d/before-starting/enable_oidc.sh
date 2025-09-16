#!/bin/sh

php /var/www/html/occ app:remove user_oidc
php /var/www/html/occ app:install user_oidc
php /var/www/html/occ config:app:set --value=0 user_oidc allow_multiple_user_backends
exit 0
