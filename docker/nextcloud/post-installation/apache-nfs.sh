#!/bin/bash

echo -en 'EnableSendfile Off\nEnableMMAP Off'  > /etc/apache2/conf-available/nfs-tweak.conf
a2enconf apache-limits
