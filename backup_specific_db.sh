#!/bin/bash

# Set variables
BACKUP_DIR="/backups/postgres/specific_db"
DATE=$(date +"%Y%m%d%H%M")
CONTAINER_NAME="postgres-container"
DB_NAME="test_db"  # Replace with your actual DB name
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$DATE.sql"

# Function to log messages, whether run manually or through cron
log() {
  if [ -t 1 ]; then
    # If it's a terminal (manual execution), log to console
    echo "$1"
  else
    # If not a terminal (cron), log to a file
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> /var/log/postgres_backup.log
  fi
}

# Start backup process log
log "Starting backup for database: $DB_NAME"

# Ensure the backup directory exists
mkdir -p $BACKUP_DIR

# Run the backup
if docker exec $CONTAINER_NAME pg_dump -U postgres $DB_NAME > $BACKUP_FILE; then
  log "Backup successful: $BACKUP_FILE"
else
  log "Backup failed for database: $DB_NAME"
  exit 1
fi

# Optional: Keep backups for 7 days only
find $BACKUP_DIR -type f -mtime +7 -name "*.sql" -exec rm {} \;
log "Old backups cleaned up"
