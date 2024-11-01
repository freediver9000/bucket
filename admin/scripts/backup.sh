#!/bin/bash
#


# Set server details (replace with your actual values)
SERVER_HOST="$(hostname)"
SERVER_USER="${USER}"
DATA_DIR="/var/lib/mysql"  # Replace with your data directory path
BACKUP_DIR="/shared/data/backup/hot"
# SERVER_PASSWORD="your_db_password"

if [ $(whoami) != "root" ]; then
	echo "Must be run with sudo"
	exit 1
fi

# Get current date for filename
START_DATE="$(date +%Y-%m-%dT%H%M%S)"
FULL_BACKUP_FILENAME="${BACKUP_DIR}/${START_DATE}"

# Run xtrabackup with full backup command
xtrabackup --backup \
  --target-dir="${FULL_BACKUP_FILENAME}" \
  --datadir="${DATA_DIR}" \
  --user="${SERVER_USER}"

echo "Daily full backup completed at $(date)"
#  --password="${SERVER_PASSWORD}"
