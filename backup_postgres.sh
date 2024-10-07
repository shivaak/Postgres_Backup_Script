#!/bin/bash

# Set directories for backups
SPECIFIC_BACKUP_DIR="/backups/postgres/specific_db"
FULL_BACKUP_DIR="/backups/postgres/full"
DATE=$(date +"%Y%m%d%H%M")
CONTAINER_NAME="postgres-container"
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

# Usage function
usage() {
  echo "Usage: $0 [full|specific <db_name>]"
  exit 1
}

# Ensure proper usage
if [ "$1" == "specific" ]; then
  if [ -z "$2" ]; then
    usage
  fi
elif [ "$1" != "full" ]; then
  usage
fi

# Start the backup process based on the input
if [ "$1" == "specific" ]; then
  DB_NAME="$2"
  BACKUP_FILE="$SPECIFIC_BACKUP_DIR/${DB_NAME}_backup_$DATE.sql"

  # Start specific database backup log
  log "Starting backup for database: $DB_NAME"

  # Ensure the backup directory exists
  mkdir -p $SPECIFIC_BACKUP_DIR

  # Run the backup for the specific database
  if docker exec $CONTAINER_NAME pg_dump -U postgres $DB_NAME > $BACKUP_FILE; then
    log "Backup successful: $BACKUP_FILE"
  else
    log "Backup failed for database: $DB_NAME"
    exit 1
  fi

elif [ "$1" == "full" ]; then
  BACKUP_FILE="$FULL_BACKUP_DIR/postgres_instance_backup_$DATE.sql"

  # Start full instance backup log
  log "Starting full instance backup"

  # Ensure the backup directory exists
  mkdir -p $FULL_BACKUP_DIR

  # Run the full instance backup
  if docker exec $CONTAINER_NAME pg_dumpall -U postgres > $BACKUP_FILE; then
    log "Full instance backup successful: $BACKUP_FILE"
  else
    log "Full instance backup failed"
    exit 1
  fi
fi

# Optional: Keep backups for 7 days only
if [ "$1" == "specific" ]; then
  find $SPECIFIC_BACKUP_DIR -type f -mtime +7 -name "*.sql" -exec rm {} \;
else
  find $FULL_BACKUP_DIR -type f -mtime +7 -name "*.sql" -exec rm {} \; >> $LOG_FILE 2>&1
fi
log "Old backups cleaned up"
