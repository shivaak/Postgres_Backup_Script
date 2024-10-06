### README.md

```markdown
# PostgreSQL Backup and Restore Scripts

This project contains scripts to back up and restore PostgreSQL databases running in Docker containers. It supports both full instance backup and specific database backup, as well as corresponding restore options.

## Prerequisites

1. PostgreSQL is running as a Docker container (replace `postgres-container` with the actual container name).
2. Scripts must have the appropriate permissions and logs set up for backups and restores.
3. Ensure Docker is installed and running.

## Backup Setup

Before running any backup or restore scripts, create the log files and give the necessary permissions.

### 1. Create Log Files

```bash
sudo touch /var/log/postgres_backup.log
sudo touch /var/log/postgres_restore.log
sudo chown $(whoami):$(whoami) /var/log/postgres_backup.log /var/log/postgres_restore.log
```

### 2. Give Execute Permission to Scripts

Make sure the backup and restore scripts are executable:

```bash
chmod +x backup_postgres_instance.sh
chmod +x backup_specific_db.sh
chmod +x restore_postgres.sh
```

### Full Instance Backup

To back up the entire PostgreSQL instance:

1. Run the script:

   ```bash
   ./backup_postgres_instance.sh
   ```

2. This will create a full backup in `/backups/postgres/full/` and append logs to `/var/log/postgres_backup.log`.

### Specific Database Backup

To back up a specific database:

1. Modify the `backup_specific_db.sh` script to specify your database name:

   ```bash
   DB_NAME="your_database_name"  # Replace with your actual database name
   ```

2. Run the script:

   ```bash
   ./backup_specific_db.sh
   ```

3. This will create a backup of the specified database in `/backups/postgres/specific_db/` and append logs to `/var/log/postgres_backup.log`.

## Restore Scripts

You can restore either the full PostgreSQL instance or a specific database using the `restore_postgres.sh` script.

### Full Instance Restore

1. To restore a full instance backup, run:

   ```bash
   ./restore_postgres.sh full <backup_file.sql>
   ```

   Example:

   ```bash
   ./restore_postgres.sh full postgres_instance_backup_202409101140.sql
   ```

### Specific Database Restore

1. To restore a specific database, run:

   ```bash
   ./restore_postgres.sh specific <backup_file.sql> <database_name>
   ```

   Example:

   ```bash
   ./restore_postgres.sh specific test_db_backup_202409101130.sql test_db
   ```

Both of these commands log the restore process in `/var/log/postgres_restore.log`.

## Manual Restore

If you want to manually restore backups without using the restore scripts, follow these steps:

### Manual Full Instance Restore

1. **Stop the PostgreSQL container** (optional, but recommended):

   ```bash
   docker stop postgres-container
   ```

2. **Start a new temporary PostgreSQL container** for the restore:

   ```bash
   docker run --name temp-postgres-container -e POSTGRES_PASSWORD=mysecretpassword -d postgres
   ```

3. **Copy the full backup file into the new container**:

   ```bash
   docker cp /backups/postgres/full/<backup_file.sql> temp-postgres-container:/tmp/
   ```

4. **Restore the full instance**:

   ```bash
   docker exec -i temp-postgres-container psql -U postgres < /tmp/<backup_file.sql>
   ```

5. **Verify the restoration** by connecting to the container and listing databases:

   ```bash
   docker exec -it temp-postgres-container psql -U postgres -c "\l"
   ```

6. **Stop and replace the original container** if needed:

   ```bash
   docker stop postgres-container
   docker rm postgres-container
   docker rename temp-postgres-container postgres-container
   docker start postgres-container
   ```

### Manual Specific Database Restore

1. **Create the database if it doesn’t already exist**:

   ```bash
   docker exec -i postgres-container psql -U postgres -c "CREATE DATABASE <database_name>;"
   ```

2. **Copy the specific database backup file to the container**:

   ```bash
   docker cp /backups/postgres/specific_db/<backup_file.sql> postgres-container:/tmp/
   ```

3. **Restore the specific database**:

   ```bash
   docker exec -i postgres-container psql -U postgres -d <database_name> < /tmp/<backup_file.sql>
   ```

4. **Verify the restoration**:

   ```bash
   docker exec -i postgres-container psql -U postgres -d <database_name> -c "\dt"
   ```

This will list the tables in the database and confirm that the restoration was successful.

---

## Additional Notes

- Make sure that all backups and restore operations are tested in a non-production environment before using them in production.
- Regularly monitor the logs for both backup and restore processes:

  ```bash
  tail -f /var/log/postgres_backup.log
  tail -f /var/log/postgres_restore.log
  ```

- Adjust the retention period of the backups by modifying the `find` command in the backup scripts.
```

### Key Highlights of the Changes:
1. **No Table of Contents**: As requested, I removed the table of contents section.
2. **Mention of Database Name in Specific Backup**: Clearly noted in the **Specific Database Backup** section that the `DB_NAME` variable must be modified in the `backup_specific_db.sh` script.

This README is ready to be committed to Git and should provide a clear and concise guide for setting up backups and performing restores.
