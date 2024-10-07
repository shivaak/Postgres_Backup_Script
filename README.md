# PostgreSQL Backup and Restore Guide

This guide explains how to use the `backup_postgres.sh` and `restore_postgres.sh` scripts for backing up and restoring PostgreSQL databases running in Docker containers. It also covers manual restoration steps in case you need to restore a backup without using the restore script.

## Prerequisites

1. PostgreSQL is running as a Docker container (replace `postgres-container` with the actual container name).
2. The necessary permissions are set for both the backup and restore scripts.
3. Docker is installed and running on your system.

## Setting Up

Before running the scripts, ensure the log files are created, and the necessary permissions are set:

### 1. Create Log Files

```bash
sudo touch /var/log/postgres_backup.log
sudo touch /var/log/postgres_restore.log
sudo chown $(whoami):$(whoami) /var/log/postgres_backup.log /var/log/postgres_restore.log
```

### 2. Set Execute Permission on Scripts

Make sure the scripts are executable:

```bash
chmod +x backup_postgres.sh
chmod +x restore_postgres.sh
```

## Backup Script (`backup_postgres.sh`)

The `backup_postgres.sh` script can be used for both full instance and specific database backups.

### Usage

- **Full Instance Backup**: Backs up the entire PostgreSQL instance.

  ```bash
  ./backup_postgres.sh full
  ```

- **Specific Database Backup**: Backs up a specific database.

  ```bash
  ./backup_postgres.sh specific <db_name>
  ```

  Example:

  ```bash
  ./backup_postgres.sh specific test_db
  ```

### Logging

- Logs for the backup process are automatically saved to `/var/log/postgres_backup.log`.
- The script logs both successes and failures. If run manually, it will also print logs to the console.

## Restore Script (`restore_postgres.sh`)

The `restore_postgres.sh` script can be used for restoring both full instance and specific database backups.

### Usage

- **Full Instance Restore**: Restores the entire PostgreSQL instance from a full backup file.

  ```bash
  ./restore_postgres.sh full <backup_file.sql>
  ```

  Example:

  ```bash
  ./restore_postgres.sh full postgres_instance_backup_202409101140.sql
  ```

- **Specific Database Restore**: Restores a specific database from a backup file.

  ```bash
  ./restore_postgres.sh specific <backup_file.sql> <db_name>
  ```

  Example:

  ```bash
  ./restore_postgres.sh specific test_db_backup_202409101130.sql test_db
  ```

### Logging

- Logs for the restore process are saved to `/var/log/postgres_restore.log`.
- The script handles logging for both successes and failures. When run manually, it also prints logs to the console.

## Manual Restore Without Using the Script

In case you need to manually restore a PostgreSQL backup without using the `restore_postgres.sh` script, follow these detailed steps:

### Full Instance Restore (Manual)

1. **Stop the PostgreSQL container** (optional but recommended to avoid conflicts):

   ```bash
   docker stop postgres-container
   ```

2. **Start a temporary PostgreSQL container** for restoring the backup:

   ```bash
   docker run --name temp-postgres-container -e POSTGRES_PASSWORD=mysecretpassword -d postgres
   ```

3. **Copy the full backup file to the new container**:

   ```bash
   docker cp /backups/postgres/full/<backup_file.sql> temp-postgres-container:/tmp/
   ```

4. **Restore the full instance** using the backup file:

   ```bash
   docker exec -i temp-postgres-container psql -U postgres < /tmp/<backup_file.sql>
   ```

5. **Verify the restoration** by checking the list of databases:

   ```bash
   docker exec -it temp-postgres-container psql -U postgres -c "\l"
   ```

6. **Replace the original container** if needed:

   - **Stop and remove the original container**:

     ```bash
     docker stop postgres-container
     docker rm postgres-container
     ```

   - **Rename the temporary container** to take the place of the original:

     ```bash
     docker rename temp-postgres-container postgres-container
     ```

   - **Start the renamed container**:

     ```bash
     docker start postgres-container
     ```

### Specific Database Restore (Manual)

1. **Create the target database** if it doesn’t already exist:

   ```bash
   docker exec -i postgres-container psql -U postgres -c "CREATE DATABASE <database_name>;"
   ```

2. **Copy the specific database backup file to the container**:

   ```bash
   docker cp /backups/postgres/specific_db/<backup_file.sql> postgres-container:/tmp/
   ```

3. **Restore the specific database** from the backup file:

   ```bash
   docker exec -i postgres-container psql -U postgres -d <database_name> < /tmp/<backup_file.sql>
   ```

4. **Verify the restoration** by listing the tables in the database:

   ```bash
   docker exec -i postgres-container psql -U postgres -d <database_name> -c "\dt"
   ```

This will confirm that the tables in the database have been restored successfully.

## Cron Setup for Automatic Backups

To schedule automatic daily backups using cron, follow these steps:

1. Open crontab for editing:

   ```bash
   crontab -e
   ```

2. Add the cron job for running the backup at 4 AM every day:

   - **For full instance backup**:

     ```bash
     0 4 * * * /path/to/backup_postgres.sh full
     ```

   - **For specific database backup**:

     ```bash
     0 4 * * * /path/to/backup_postgres.sh specific <db_name>
     ```

3. Save and close the crontab file.

Logs will be managed by the script itself, so no need to redirect output manually in the cron job.

## Additional Notes

- Ensure that you have the correct permissions for the backup and restore directories.
- Regularly check `/var/log/postgres_backup.log` and `/var/log/postgres_restore.log` for any issues or successes with backups and restores:

  ```bash
  tail -f /var/log/postgres_backup.log
  tail -f /var/log/postgres_restore.log
  ```

- It's recommended to test backups and restores in a non-production environment to ensure everything is working as expected.
```
