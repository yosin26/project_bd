# Используем официальный образ PostgreSQL 16
FROM postgres:16-alpine

# Устанавливаем локализацию для поддержки русского языка
RUN apk add --no-cache tzdata

# Копируем SQL скрипты в правильном порядке
COPY scripts/01_create_database_and_enums.sql /docker-entrypoint-initdb.d/01_create_database_and_enums.sql
COPY scripts/02_create_tables.sql /docker-entrypoint-initdb.d/02_create_tables.sql
COPY scripts/03_insert_data.sql /docker-entrypoint-initdb.d/03_insert_data.sql

# Даем права на выполнение
RUN chmod 644 /docker-entrypoint-initdb.d/*.sql

# Создаем директорию для бэкапов
RUN mkdir -p /backups

# Добавляем healthcheck скрипт
COPY scripts/clear_tables.sql /scripts/clear_tables.sql

# Устанавливаем locale для корректной сортировки
ENV LANG ru_RU.utf8
ENV LC_COLLATE ru_RU.utf8

LABEL version="1.0"
LABEL description="PostgreSQL 16 for Taekwondo Federation"
LABEL maintainer="Taekwondo Federation"
