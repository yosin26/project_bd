#!/bin/sh
set -e

BACKUP_DIR="${BACKUP_DIR:-/backups}"

# Проверяем, передан ли аргумент с именем файла
if [ -z "$1" ]; then
    echo "❌ Укажите имя файла бэкапа"
    echo "   Использование: $0 <имя_файла.sql.gz>"
    echo ""
    echo "📋 Доступные бэкапы:"
    ls -1 ${BACKUP_DIR}/*.sql.gz 2>/dev/null | xargs -n1 basename || echo "   Бэкапы не найдены"
    exit 1
fi

BACKUP_FILE="${BACKUP_DIR}/$1"

# Проверяем существование файла
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Файл $BACKUP_FILE не найден"
    exit 1
fi

echo "=========================================="
echo "📊 Информация о бэкапе: $1"
echo "=========================================="
echo ""

# Основная информация
echo "📁 Файл:         $(basename "$BACKUP_FILE")"
echo "📂 Полный путь:  $BACKUP_FILE"
echo "📏 Размер:       $(du -h "$BACKUP_FILE" | cut -f1)"
echo "📦 Точный размер: $(stat -c %s "$BACKUP_FILE" | numfmt --to=iec) байт"
echo ""

# Информация о датах
echo "📅 Создан:       $(date -r "$BACKUP_FILE" "+%Y-%m-%d %H:%M:%S")"
echo "🕒 Последний доступ: $(stat -c %x "$BACKUP_FILE" | cut -d. -f1)"
echo "🔧 Последнее изменение: $(stat -c %y "$BACKUP_FILE" | cut -d. -f1)"
echo ""

# Права доступа
echo "🔐 Права доступа: $(stat -c %A "$BACKUP_FILE") ($(stat -c %a "$BACKUP_FILE"))"
echo "👤 Владелец:     $(stat -c %U "$BACKUP_FILE")"
echo "👥 Группа:       $(stat -c %G "$BACKUP_FILE")"
echo ""

# Информация о содержимом (первые несколько строк)
echo "🔍 Первые строки бэкапа:"
echo "------------------------------------------"
gunzip -c "$BACKUP_FILE" | head -n 10 | sed 's/^/   /'
echo "..."

# Подсчет количества таблиц в бэкапе
echo ""
echo "📊 Статистика содержимого:"
TABLE_COUNT=$(gunzip -c "$BACKUP_FILE" | grep -i "CREATE TABLE" | wc -l)
INSERT_COUNT=$(gunzip -c "$BACKUP_FILE" | grep -i "^INSERT INTO" | wc -l)
echo "   • Таблиц:      $TABLE_COUNT"
echo "   • INSERT-ов:   $INSERT_COUNT"

echo "=========================================="
