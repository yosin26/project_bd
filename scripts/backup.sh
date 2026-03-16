#!/bin/sh
set -e

BACKUP_DIR="${BACKUP_DIR:-/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/taekwondo_${TIMESTAMP}.sql.gz"
DB_HOST="${POSTGRES_HOST:-postgres}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_NAME="${POSTGRES_DB:-taekwondo_db}"
RETAIN_DAYS="${BACKUP_RETAIN_DAYS:-7}"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting backup of ${DB_NAME} to ${BACKUP_FILE}"

# Создаем бэкап
PGPASSWORD="${POSTGRES_PASSWORD}" pg_dump -h ${DB_HOST} -U ${DB_USER} -d ${DB_NAME} \
    --clean \
    --if-exists \
    --no-owner \
    --no-privileges \
    --verbose \
    2>> ${BACKUP_DIR}/backup.log \
    | gzip > ${BACKUP_FILE}

# Проверяем успешность создания бэкапа
if [ $? -eq 0 ] && [ -s ${BACKUP_FILE} ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup completed successfully: ${BACKUP_FILE} ($(du -h ${BACKUP_FILE} | cut -f1))"

    # Удаляем старые бэкапы
    find ${BACKUP_DIR} -name "taekwondo_*.sql.gz" -type f -mtime +${RETAIN_DAYS} -delete
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Old backups older than ${RETAIN_DAYS} days removed"
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup failed!"
    exit 1
fi
