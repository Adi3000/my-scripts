#!/bin/bash
source /etc/default/postgresql
for db in $(echo $POSTGRES_MULTIPLE_DATABASES | tr ',' ' '); do
    docker exec -i postgres pg_dump  -U $db $db > /home/postgres/backup/${db}.dmp 2>> /home/postgres/backup/backup.log
done
