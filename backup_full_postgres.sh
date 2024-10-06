#!/bin/bash

# Set variables
BACKUP_DIR="/backups/postgres/full"
DATE=$(date +"%Y%m%d%H%M")
CONTAINER_NAME="postgres-container"
BACKUP_FILE="$BACKUP_DIR/postgres_instance_backup_$DATE.sql"
LOG_FILE="/var/log/postgres_backup.log"

# Function to log messages, whether run manually or through cron
log() {
  if [ -t 1 ]; then
    # If it's a terminal (manual execution), log to console
    echo "$1"
  else
    # If not a terminal (cron), log to a file
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOG_FILE
  fi
}

# Start backup process log
log "Starting full instance backup"

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR

# Run the full backup
if docker exec $CONTAINER_NAME pg_dumpall -U postgres > $BACKUP_FILE; then
  log "Full instance backup successful: $BACKUP_FILE"
else
  log "Full instance backup failed"
  exit 1
fi

# Optional: Keep backups for 7 days only
find $BACKUP_DIR -type f -mtime +7 -name "*.sql" -exec rm {} \; >> $LOG_FILE 2>&1
log "Old backups cleaned up"
