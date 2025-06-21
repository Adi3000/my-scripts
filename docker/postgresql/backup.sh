#!/bin/bash
source /etc/default/postgresql
for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
    docker exec -it postgres pg_dump  -U $db $db > /home/postgres/backup/${db}.dmp
done
