#!/bin/bash
export BACKUP_HOME=/root/scripts/backup
export BACKUP_SCRIPT=$BACKUP_HOME/backup.sh
export BACKUP_LOG_DIR=/var/log
export BACKUP_LOG=$BACKUP_LOG_DIR/backup.log
export BACKUP_ERR_LOG=$BACKUP_LOG_DIR/backup.err.log
export BACKUP_MAIL_REPORT="adi300000+backup@gmail.com"


#Backup old log
test -e $BACKUP_LOG && mv $BACKUP_LOG $BACKUP_LOG.1
test -e $BACKUP_ERR_LOG && mv $BACKUP_ERR_LOG $BACKUP_ERR_LOG.1

$BACKUP_SCRIPT > $BACKUP_LOG 2> $BACKUP_ERR_LOG
error_code=$?
gzip --force $BACKUP_ERR_LOG
gzip --force $BACKUP_LOG
if [ $error_code -ne 0 ]; then
        echo -e "Error on backup \nerrors : see attachments " | s-nail -s "ERREUR[$error_code] BACKUP FTP OVH" --attach="$BACKUP_ERR_LOG.gz" $BACKUP_MAIL_REPORT 2>> $BACKUP_ERR_LOG
else
        echo -e "Backup processed succesfully " | s-nail -s 'BACKUP SUCCESS BACKUP FTP OVH' -attach="$BACKUP_LOG.gz" $BACKUP_MAIL_REPORT 2>> $BACKUP_ERR_LOG
fi

root@adi-server:~/scripts/backup# cat backup_upload.sh 
#!/bin/bash
. /root/scripts/backup/.aws-glacier


if [ ! -f $AWS_INVENTORY_JOB_FILE ]; then
        $AWS_GLACIER_BIN inventory init-retrieval $AWS_GLACIER_VAULT | grep Job | cut -d: -f2 | tr -d [:blank:] > $AWS_INVENTORY_JOB_FILE
fi

for backup in "$@"; do
        echo "$(date) - $0 - Uploading $backup"
        $AWS_GLACIER_BIN upload $AWS_GLACIER_VAULT --arc-desc "$(date +%F)-$(basename $backup)" --part-size 128 $backup
        if [ $? -ne 0 ]; then
                echo "$(date) - $0 - Error while uploading to $AWS_GLACIER_VAULT $backup"
                exit 6
        fi
        echo "$(date) - $0 - Removing $backup"
        rm -f $backup
done
