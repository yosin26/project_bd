#  Taekwondo Federation Database System
 
 ```mermaid
erDiagram
    Federation ||--o{ Region : "имеет"
    Federation ||--o{ Organization : "объединяет"
    Federation ||--o{ Tournament : "проводит"
    Federation ||--o{ Users : "состоит в"

    Region ||--o{ Organization : "включает"
    Region ||--o{ Users : "проживают"

    Organization ||--o{ Entry : "подает"
    Organization ||--o{ Tournament : "организует"
    Organization ||--o{ Users : "сотрудники"

    Users ||--o| Athlete : "роль"
    Users ||--o| Judges : "роль"
    Users ||--o{ UserRoles : "назначены"

    Role ||--o{ UserRoles : "присвоена"
    Role ||--o{ RolePermissions : "содержит"
    Permissions ||--o{ RolePermissions : "включен в"

    Athlete ||--o| Statistics : "имеет"
    Athlete ||--o{ Entry : "заявляется"

    Judges ||--o{ JudgeAssignment : "назначается"
    Judges ||--o{ Penalty : "выносит"
    Judges ||--o{ Score : "выставляет"

    Tournament ||--o{ Entry : "содержит"
    Tournament ||--o{ Match : "включает"
    Tournament ||--o{ JudgeAssignment : "требует"

    Discipline ||--o{ Entry : "тип"
    Discipline ||--o{ Match : "правила"

    AgeGroup ||--o{ Entry : "категория"
    BeltLevel ||--o{ Entry : "уровень"
    WeightCategory ||--o{ Entry : "рамки"

    Entry ||--o{ WeighIn : "проходит"
    Entry ||--o{ Penalty : "получает"
    Entry ||--o{ Match : "угол: красный"
    Entry ||--o{ Match : "угол: синий"
    Entry ||--o{ Match : "победитель"

    Match ||--o{ Score : "оценки"
    Match ||--o{ Penalty : "нарушения"

    Federation {
        Int id PK
        String name
        String type
    }

    Region {
        Int id PK
        String name
        Int federation_id FK
    }

    Organization {
        Int id PK
        String name
        String inn UK
        String address
        Enum status "organization_status"
        Int federation_id FK
        Int region_id FK
    }

    Users {
        Int id PK
        String fio
        Date dob
        String email UK
        Enum gender "user_gender"
        DateTime createdAt
        String phone
        Int federation_id FK
        Int region_id FK
        Int organization_id FK
    }

    Role {
        Int id PK
        String name UK
    }

    Permissions {
        Int id PK
        String code UK
        String description
    }

    UserRoles {
        Int users_id PK, FK
        Int role_id PK, FK
    }

    RolePermissions {
        Int role_id PK, FK
        Int permissions_id PK, FK
    }

    Athlete {
        Int id PK
        Float currentWeight
        String insuranceId
        Date insuranceExpiry
        String rank
        Enum status "athlete_status"
        Int users_id FK, UK
    }

    Judges {
        Int id PK
        String licenseNumber UK
        Boolean isActive
        Enum status "judge_status"
        Int users_id FK, UK
    }

    Statistics {
        Int id PK
        Int wins
        Int loses
        Int ratingPoints
        Int athlete_id FK, UK
    }

    Discipline {
        Int id PK
        String name UK
    }

    AgeGroup {
        Int id PK
        String name
        Int minAge
        Int maxAge
    }

    BeltLevel {
        Int id PK
        String name UK
    }

    WeightCategory {
        Int id PK
        String name
        Float minWeight
        Float maxWeight
    }

    Tournament {
        Int id PK
        String name
        String type
        Date startDate
        Date endDate
        Float entryFee
        Int federation_id FK
        Int organization_id FK
    }

    Entry {
        Int id PK
        Float declaredWeight
        Enum status "entry_status"
        Enum gender "user_gender"
        Int discipline_id FK
        Int organization_id FK
        Int age_group_id FK
        Int belt_level_id FK
        Int weight_category_id FK
        Int tournament_id FK
        Int athlete_id FK
    }

    Match {
        Int id PK
        Int roundNumber
        Enum status "match_status"
        DateTime startTime
        DateTime endTime
        Int matchDuration
        Int tournament_id FK
        Int discipline_id FK
        Int entry_red_id FK
        Int entry_blue_id FK
        Int winner_id FK
    }

    Score {
        Int id PK
        Int roundNumber
        Int blueScore
        Int redScore
        Float tulScore
        Int judges_id FK
        Int match_id FK
    }

    Penalty {
        Int id PK
        String type
        Int points
        Int entry_id FK
        Int match_id FK
        Int judges_id FK
    }

    WeighIn {
        Int id PK
        Float actualWeight
        DateTime weighDate
        Enum status "weighin_status"
        Float fineAmount
        Int entry_id FK
    }

    JudgeAssignment {
        Int id PK
        String role
        Int tournament_id FK
        Int judges_id FK
    }
 ```
## 📋 Справочник ENUM (Значения в базе)

Чтобы не лезть в SQL-код каждый раз, вот что "зашито" в эти типы на диаграмме:

|Тип ENUM|Возможные значения|
|---|---|
|**`user_gender`**|`male`, `female`|
|**`entry_status`**|`ожидание`, `подтверждена`, `отменена`, `дисквалифицирована`|
|**`match_status`**|`запланирован`, `активен`, `завершен`, `отменен`|
|**`organization_status`**|`активен`, `неактивен`, `заблокирован`|
|**`athlete_status`**|`активен`, `неактивен`, `дисквалифицирован`, `травмирован`|
|**`judge_status`**|`активен`, `неактивен`, `на больничном`, `на пенсии`|
|**`weighin_status`**|`ожидание`, `пройдено`, `не пройдено`|

---
## 📖 Содержание
* [🚀 Быстрый старт](https://github.com/yosin26/project_bd/blob/master/README.md#-%D0%B1%D1%8B%D1%81%D1%82%D1%80%D1%8B%D0%B9-%D1%81%D1%82%D0%B0%D1%80%D1%82)
* [🏗️ Архитектура системы](https://github.com/yosin26/project_bd/tree/master#%EF%B8%8F-%D0%B0%D1%80%D1%85%D0%B8%D1%82%D0%B5%D0%BA%D1%82%D1%83%D1%80%D0%B0-%D1%81%D0%B8%D1%81%D1%82%D0%B5%D0%BC%D1%8B)
* [📦 Инфраструктура (Docker)](https://github.com/yosin26/project_bd/tree/master#-%D0%B8%D0%BD%D1%84%D1%80%D0%B0%D1%81%D1%82%D1%80%D1%83%D0%BA%D1%82%D1%83%D1%80%D0%B0-docker)
* [🖥️ Работа с БД и pgAdmin](https://github.com/yosin26/project_bd/tree/master#%EF%B8%8F-%D1%80%D0%B0%D0%B1%D0%BE%D1%82%D0%B0-%D1%81-%D0%B1%D0%B4-%D0%B8-pgadmin)
* [💾 Резервное копирование](https://github.com/yosin26/project_bd/tree/master#-%D1%80%D0%B5%D0%B7%D0%B5%D1%80%D0%B2%D0%BD%D0%BE%D0%B5-%D0%BA%D0%BE%D0%BF%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D0%BD%D0%B8%D0%B5)
* [🛠️ Решение проблем](https://github.com/yosin26/project_bd/tree/master#%EF%B8%8F-%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D0%B5-%D0%BF%D1%80%D0%BE%D0%B1%D0%BB%D0%B5%D0%BC)

---
## 🚀 Быстрый старт

1. **Клонируйте репозиторий:**
```bash
git clone https://github.com/your-repo/taekwondo-db.git
cd taekwondo-db
```

2. **Настройте окружение:**
Скопируйте пример и отредактируйте `.env`:
```bash
cp .env.example .env # Если есть пример, или создайте вручную
```

3. **Запустите систему:**
```bash
docker-compose up -d
```

*Система автоматически применит SQL-миграции из папки `/scripts` при первом запуске.*

---
## 🏗️ Архитектура системы

База данных построена на нормализованной схеме, учитывающей специфику единоборств:

* **Организационная иерархия**: Федерация → Регионы → Организации.
* **Ролевая модель**: Гибкая система RBAC (Permissions -> Roles -> UserRoles).
* **Турнирный блок**: Поддержка весовых категорий, возрастных групп и уровней поясов.
* **Механика матча**: Учет красного/синего углов, детализированные баллы от судей и фиксация победителя.
[### Схема сущностей (ER)](https://github.com/yosin26/project_bd/tree/master?tab=readme-ov-file#taekwondo-federation-database-system)

---
## 📦 Инфраструктура (Docker)

### Структура проекта
```text
.
├── scripts/               # SQL инициализация (01_enums, 02_tables, 03_data)
├── backups/               # Автоматические и ручные дампы базы
├── logs/                  # Системные логи PostgreSQL
├── docker-compose.yaml    # Оркестрация (Postgres, pgAdmin, Backup-service)
└── .env                   # Конфигурация доступа
```
### Основные команды управления

| Команда | Описание |
| --- | --- |
| `docker-compose up -d` | Запуск всех сервисов в фоне |
| `docker-compose ps` | Статус контейнеров и здоровья (healthcheck) |
| `docker-compose logs -f` | Просмотр логов в реальном времени |
| `docker-compose down -v` | Полная остановка с удалением данных |

---
## 🖥️ Работа с БД и pgAdmin

### Параметры подключения

* **Host**: `localhost` (внутри Docker: `postgres`)
* **Port**: `5432`
* **Database**: `taekwondo_db`
* **User**: `postgres`
### Веб-интерфейс (pgAdmin)

Доступен по адресу: [http://localhost:5050](https://www.google.com/search?q=http://localhost:5050)

* **Login**: `admin@taekwondo.ru`
* **Password**: `admin123` (по умолчанию из `.env`)
---
## 💾 Резервное копирование

Система включает автоматизированный сервис бэкапов:
* **Авто-бэкап**: Ежедневно в 02:00.
* **Срок хранения**: 7 дней.
**Ручное управление:**
```bash
# Создать бэкап сейчас
docker exec taekwondo-backup backup.sh

# Посмотреть список доступных копий
docker exec taekwondo-backup list_backups.sh

# Восстановить последнюю версию
docker exec taekwondo-backup restore.sh
```

---
## 🛠️ Решение проблем

> [!IMPORTANT]
> Если при запуске вы видите ошибку `Port 5432 is already in use`, измените значение `DB_PORT` в файле `.env`.

**Если таблицы не создались автоматически:**
Проверьте порядок выполнения скриптов в логах или выполните принудительную инициализацию:

```bash
docker exec -it taekwondo-postgres psql -U postgres -d taekwondo_db -f /scripts/02_create_tables.sql
```

**Полный сброс базы (ОСТОРОЖНО):**

```bash
docker-compose down -v && docker-compose up -d
```

---
