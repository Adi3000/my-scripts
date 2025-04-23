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
