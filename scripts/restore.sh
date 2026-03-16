#!/bin/sh
set -e

BACKUP_DIR="${BACKUP_DIR:-/backups}"
DB_HOST="${POSTGRES_HOST:-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-taekwondo_db}"

# Показать доступные бэкапы
echo "Available backups:"
ls -lh ${BACKUP_DIR}/*.sql.gz 2>/dev/null || echo "No backups found"

# Если передан аргумент с именем файла, используем его
if [ ! -z "$1" ]; then
    BACKUP_FILE="${BACKUP_DIR}/$1"
else
    # Иначе используем последний бэкап
    BACKUP_FILE=$(ls -t ${BACKUP_DIR}/*.sql.gz 2>/dev/null | head -1)
fi

if [ -z "${BACKUP_FILE}" ] || [ ! -f "${BACKUP_FILE}" ]; then
    echo "Error: Backup file not found!"
    exit 1
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting restore from ${BACKUP_FILE}"

# Восстанавливаем из бэкапа
gunzip -c ${BACKUP_FILE} | PGPASSWORD="${POSTGRES_PASSWORD}" psql -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME}

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Restore completed successfully"
