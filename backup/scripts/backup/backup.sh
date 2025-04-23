#!/bin/bash

##################################################
# Ce script effectue une sauvegarde des bases de
# données et du dossier des sites et transfert
# cette sauvegarde sur un serveur FTP
##################################################

##############################################
# Variables à modifier
##############################################
ROOTDIR=""
#hote FTP
FTP_SERVER="****"
#login FTP
FTP_LOGIN="****"
#pass FTP
FTP_PASS="*****"
#Utilisateur PostGreSQL
PSQL_USER=postgres
#hote MySQ
PSQL_HOST="localhost"
#Dossier à sauvergarder (dossier dans lequel les sites sont placés)
DIRSITES="$ROOTDIR/home/www/"
EXCLUDE_LIST="$BACKUP_HOME/backup-exclude.txt"
BACKUP_ROOT="$ROOTDIR/home/backup"
PAUSED_SERVICE_LIST="$BACKUP_HOME/backup-paused-services.txt"
LDAP_BACKUP=/usr/sbin/slapcat
##############################################
# dossiers temporaires crees (laissez comme ca, ou pas)
##############################################
DATE_FORMAT=`date +%Y-%m-%d`
DIRSAVE="$BACKUP_ROOT/$DATE_FORMAT"
#Dossier de sauvegarde temporaire des dumps sql
DIRSAVESQL="$DIRSAVE"
DB_NAMES="redmine latroquette owncloud wedding charivari-perm charivari-perm-test mattermost"
PGSQL_PORT=7733
PGCLUSTER=13/main
##############################################
#
##############################################
POSTGRES="$(which pg_dump)"
MYSQL="$(which mysqldump)"
GZIP="$(which gzip)"
TAR="$(which tar)"
###########################
# AWS Glacier
###########################
. $BACKUP_HOME/.aws-glacier

#Stopping service
#for i in $(cat $PAUSED_SERVICE_LIST); do
#       /etc/init.d/$i stop
#done

if [ ! -d $DIRSAVESQL ]; then
  mkdir -p $DIRSAVESQL
else
 :
fi

for i in $DB_NAMES; do
        echo "$(date) - $0 - Saving Postgresql database $i"
        sudo -i -u $PSQL_USER psql -d $i -p $PGSQL_PORT -c "SELECT 1" > /dev/null && echo "Ping databae $i OK" || exit 2
        sudo -i -u $PSQL_USER PGCLUSTER=$PGCLUSTER $POSTGRES -p $PGSQL_PORT $i | $GZIP -c > $DIRSAVESQL/pgsql-$i.sql.gz || exit 3
done

sh $BACKUP_HOME/backup_upload.sh $DIRSAVESQL/pgsql-*.sql.gz || exit 11

echo "$(date) - $0 - Saving all Mariadb database"
sudo $MYSQL -A  | $GZIP -c > $DIRSAVESQL/mysql-all.sql.gz || exit 34
sh $BACKUP_HOME/backup_upload.sh $DIRSAVESQL/mysql-all.sql.gz || exit 12



echo "$(date) - $0 - Saving LDAP"
$LDAP_BACKUP -v  | $GZIP -c > $DIRSAVESQL/ldap.diff.gz || exit 8

sh $BACKUP_HOME/backup_upload.sh $DIRSAVESQL/ldap.diff.gz || exit 12

cd $DIRSAVE
nb_pids=0
for filepath in `ls $BACKUP_HOME/*.list`; do
        file=$(basename $filepath)
        filename=${file%.*}
        echo "$(date) - $0 - Creating TAR for $filename"
        time_waiting=0
        while [ $( df /home/backup | tail -n1 |  tr -s ' ' | cut -d ' ' -f4) -lt 15000000 ]; do
                echo "$(date) - $0 - Waiting, not enougth space  $( df /home | tail -n1 |  tr -s ' ' | cut -d ' ' -f4) "; 
                sleep 60
                time_waiting=$((time_waiting+1))
                if [ $time_waiting -gt 60 ]; then
                        echo "$(date) - $0 - Waited to long, abort backup";
                        exit 13
                fi
        done
        (cat $filepath | xargs $TAR --create --verbose --gzip --exclude-from $EXCLUDE_LIST | split --bytes=1024MB --numeric-suffixes --suffix-length=4 --verbose - ${filename}.gz.) &
        upload_pids_list[${nb_pids}]=$!
        nb_pids=$((nb_pids+1))
        echo "$(date) - $0 - TAR GZ Split $filepath on PID (${upload_pids_list[*]})"
        while ps -p ${upload_pids_list[*]} > /dev/null; do
                find $DIRSAVE -name "*.gz.*" |\
                        grep -v $(lsof -d w +d $DIRSAVE | grep REG | tr -s '[:space:]' ';' | cut -d\; -f 9) |\
                        xargs -P10 -I{} /bin/bash $BACKUP_HOME/backup_upload.sh "{}" >> $BACKUP_LOG 2>> $BACKUP_ERR_LOG
                sleep 3
        done
        echo "$(date) - $0 - Finished upload for $filename"
done


echo "$(date) - $0 - Adding gzipped backup logs"
cat $BACKUP_LOG | $GZIP -c > $DIRSAVE/backup.log.gz
cat $BACKUP_ERR_LOG | $GZIP -c > $DIRSAVE/backup.err.log.gz

echo "$(date) - $0 - Restarting services"

#Restarting service
#for i in $(cat $PAUSED_SERVICE_LIST); do
#        /etc/init.d/$i start
#done
#echo "$(date) - $0 - Wait for all upload to finish"

while [ $(ls $DIRSAVE/*gz*  2> /dev/null | wc -l ) -gt 0 ]; do
        find $DIRSAVE -name "*.gz*" -not -name $BACKUP_ERR_LOG -not -name $BACKUP_LOG |\
                xargs -I{} /bin/bash $BACKUP_HOME/backup_upload.sh "{}" >> $BACKUP_LOG 2>> $BACKUP_ERR_LOG
done

cd $DIRSAVE
echo "$(date) - $0 - Connection to AWS server to send logs and data not already sent"
find ./ -regex ".*\.gz.?[0-9a-z]*" -exec sh $BACKUP_HOME/backup_upload.sh {} \;

exit 0
