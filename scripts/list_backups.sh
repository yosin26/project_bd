#!/bin/sh
set -e

BACKUP_DIR="${BACKUP_DIR:-/backups}"

echo "=========================================="
echo "📦 Список бэкапов:"
echo "=========================================="

if [ -d "$BACKUP_DIR" ]; then
    ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null || echo "Бэкапы не найдены"
else
    echo "❌ Директория $BACKUP_DIR не найдена"
fi

echo "=========================================="
