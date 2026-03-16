#!/bin/sh
set -e

BACKUP_DIR="${BACKUP_DIR:-/backups}"
BACKUP_RETAIN_DAYS="${BACKUP_RETAIN_DAYS:-7}"

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "📦 Список бэкапов базы данных"
echo "=========================================="
echo ""

# Проверяем существование директории
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ Директория $BACKUP_DIR не найдена${NC}"
    exit 1
fi

# Подсчет статистики
TOTAL_BACKUPS=$(find ${BACKUP_DIR} -name "taekwondo_*.sql.gz" -type f | wc -l)
TOTAL_SIZE=$(du -sh ${BACKUP_DIR} 2>/dev/null | cut -f1)
LATEST_BACKUP=$(find ${BACKUP_DIR} -name "taekwondo_*.sql.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -f2- -d" ")

# Функция для форматирования даты
format_date() {
    local file=$1
    if [[ "$file" =~ taekwondo_([0-9]{4})([0-9]{2})([0-9]{2})_([0-9]{2})([0-9]{2})([0-9]{2})\.sql\.gz ]]; then
        echo "${BASH_REMATCH[1]}-${BASH_REMATCH[2]}-${BASH_REMATCH[3]} ${BASH_REMATCH[4]}:${BASH_REMATCH[5]}:${BASH_REMATCH[6]}"
    else
        date -r "$file" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "Неизвестно"
    fi
}

# Функция для определения возраста бэкапа
get_age_color() {
    local file=$1
    local file_date=$(stat -c %Y "$file" 2>/dev/null || echo "0")
    local current_date=$(date +%s)
    local diff_days=$(( ($current_date - $file_date) / 86400 ))

    if [ $diff_days -le 1 ]; then
        echo "${GREEN}" # свежий
    elif [ $diff_days -le 3 ]; then
        echo "${YELLOW}" # нормальный
    else
        echo "${RED}" # старый
    fi
}

# Выводим информацию о директории
echo -e "${BLUE}Директория:${NC} $BACKUP_DIR"
echo -e "${BLUE}Всего бэкапов:${NC} $TOTAL_BACKUPS"
echo -e "${BLUE}Общий размер:${NC} $TOTAL_SIZE"
echo -e "${BLUE}Храним последние:${NC} $BACKUP_RETAIN_DAYS дней"
echo ""

# Если есть бэкапы, показываем их
if [ $TOTAL_BACKUPS -gt 0 ]; then
    echo "=========================================="
    echo "📋 Список бэкапов:"
    echo "=========================================="
    echo ""

    # Формируем список бэкапов с сортировкой по дате (новые сверху)
    find ${BACKUP_DIR} -name "taekwondo_*.sql.gz" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | \
        while read line; do
            file=$(echo "$line" | cut -f2- -d" ")
            filename=$(basename "$file")
            filesize=$(du -h "$file" | cut -f1)
            file_date=$(format_date "$file")
            age_color=$(get_age_color "$file")

            # Определяем статус
            if [ "$file" = "$LATEST_BACKUP" ]; then
                status="⭐ ПОСЛЕДНИЙ"
            else
                status="   "
            fi

            # Выводим информацию
            echo -e "${age_color}📄 $filename${NC}"
            echo "   Размер: $filesize"
            echo "   Дата:   $file_date"
            echo -e "   Статус: ${age_color}$status${NC}"
            echo ""
        done

    # Информация о последнем бэкапе
    if [ -n "$LATEST_BACKUP" ]; then
        echo "=========================================="
        echo -e "${GREEN}✅ Последний бэкап:${NC}"
        echo "   $(basename "$LATEST_BACKUP")"
        echo "   Размер: $(du -h "$LATEST_BACKUP" | cut -f1)"
        echo "   Создан: $(format_date "$LATEST_BACKUP")"
        echo "=========================================="
    fi
else
    echo -e "${YELLOW}⚠️  Бэкапы не найдены${NC}"
    echo "   Создайте первый бэкап командой:"
    echo "   docker exec taekwondo-backup backup.sh"
fi

# Проверка свободного места
echo ""
echo "=========================================="
echo "💾 Информация о диске:"
echo "=========================================="
df -h "$BACKUP_DIR" | awk 'NR==1 {printf "   %-15s %8s %8s %8s %6s\n", "Файловая система", "Размер", "Использовано", "Доступно", "Использовано %"} NR==2 {printf "   %-15s %8s %8s %8s %6s\n", $1, $2, $3, $4, $5}'

# Рекомендации
echo ""
echo "=========================================="
echo "💡 Рекомендации:"
echo "=========================================="
echo "• Для восстановления используйте: docker exec taekwondo-backup restore.sh [имя_файла]"
echo "• Для создания нового бэкапа: docker exec taekwondo-backup backup.sh"
echo "• Для просмотра этого списка: docker exec taekwondo-backup list_backups.sh"
