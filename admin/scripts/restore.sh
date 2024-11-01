#!/bin/bash
#
# https://marc.guyer.me/posts/example-recovery-procedure-for-mysql-backup-made-with-xtrabackup/
# 

# Set server details (replace with your actual values)
SERVER_HOST="$(hostname)"
SERVER_USER="${USER}"
DATA_DIR="/var/lib/mysql"  
# Replace with your data directory path
BACKUP_DIR="/shared/data/backup/hot/"
# SERVER_PASSWORD="your_db_password"

if [ -n "$1" ];then
	BACKUP_DATE="$1"
else
	echo "Error: usage $0 <backup_timestamp>"
	echo "$(ls ${BACKUP_DIR})"
	exit 1
fi

FULL_BACKUP_DIRECTORY="${BACKUP_DIR}/${BACKUP_DATE}"

if [ $(whoami) != "root" ]; then
	echo "Must be run with sudo"
	exit 1
fi

# Get current date for filename
START_DATE="$(date +%Y-%m-%dT%H%M%S)"

xtrabackup --user="${SERVER_USER}" --prepare --target-dir="${FULL_BACKUP_DIRECTORY}"
#

# stop mysql before restoring
systemctl stop mysql

if [ $(systemctl status mysql |grep -i status: |grep -c shutdown) -gt 0 ];then
	echo "Confirmed the mysqld has been stopped. Proceeding with restore."
else
	echo "Error: mysqld appears to still be online"
	systemctl status mysql
	exit 1
fi

# remove previous database
find "${DATA_DIR}" -mindepth 1 -maxdepth 2 -user mysql | xargs -I{} rm -vrf {}

# xtrabackup copy back
xtrabackup --user="${SERVER_USER}" --copy-back --target-dir="${FULL_BACKUP_DIRECTORY}"
#
chown -R mysql:mysql "${DATA_DIR}"

systemctl start mysql


# Run xtrabackup with full backup command
# xtrabackup --backup \
#   --target-dir="${FULL_BACKUP_FILENAME}" \
#   --datadir="${DATA_DIR}" \
#   --user="${SERVER_USER}"
# 
# echo "Daily full backup completed at $(date)"
#  --password="${SERVER_PASSWORD}"
