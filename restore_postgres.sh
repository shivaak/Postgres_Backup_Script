#!/bin/bash

# Set variables
FULL_BACKUP_DIR="/backups/postgres/full"
SPECIFIC_BACKUP_DIR="/backups/postgres/specific_db"
LOG_FILE="/var/log/postgres_restore.log"
CONTAINER_NAME="postgres-container"

# Function to log messages
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> $LOG_FILE
}

# Usage function to guide the user
usage() {
  echo "Usage:"
  echo "$0 full <backup_file.sql>"
  echo "$0 specific <backup_file.sql> <database_name>"
  exit 1
}

# Ensure the correct number of arguments are passed
if [ "$1" == "full" ]; then
  if [ -z "$2" ]; then
    usage
  fi
elif [ "$1" == "specific" ]; then
  if [ -z "$2" ] || [ -z "$3" ]; then
    usage
  fi
else
  usage
fi

# Start the restore process based on the type
if [ "$1" == "full" ]; then
  BACKUP_FILE="$FULL_BACKUP_DIR/$2"

  # Start full instance restore log
  log "Starting full instance restore from backup: $BACKUP_FILE"

  # Check if the backup file exists
  if [ ! -f $BACKUP_FILE ]; then
    log "Backup file not found: $BACKUP_FILE"
    echo "Error: Backup file not found!"
    exit 1
  fi

  # Restore the full PostgreSQL instance
  if docker exec -i $CONTAINER_NAME psql -U postgres < $BACKUP_FILE; then
    log "Full instance restore successful from: $BACKUP_FILE"
  else
    log "Full instance restore failed from: $BACKUP_FILE"
    exit 1
  fi

elif [ "$1" == "specific" ]; then
  BACKUP_FILE="$SPECIFIC_BACKUP_DIR/$2"
  DB_NAME="$3"

  # Start specific database restore log
  log "Starting restore for database: $DB_NAME from backup: $BACKUP_FILE"

  # Check if the backup file exists
  if [ ! -f $BACKUP_FILE ]; then
    log "Backup file not found: $BACKUP_FILE"
    echo "Error: Backup file not found!"
    exit 1
  fi

  # Create the database if it doesn't exist
  docker exec -i $CONTAINER_NAME psql -U postgres -c "CREATE DATABASE $DB_NAME;" 2>> $LOG_FILE

  # Restore the specific database
  if docker exec -i $CONTAINER_NAME psql -U postgres -d $DB_NAME < $BACKUP_FILE; then
    log "Database restore successful for: $DB_NAME from: $BACKUP_FILE"
  else
    log "Database restore failed for: $DB_NAME from: $BACKUP_FILE"
    exit 1
  fi
fi
