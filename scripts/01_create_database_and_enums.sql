\c taekwondo_db;

-- Создание ENUM типов
CREATE TYPE user_gender AS ENUM ('male', 'female');
CREATE TYPE entry_status AS ENUM ('ожидание', 'подтверждена', 'отменена', 'дисквалифицирована');
CREATE TYPE match_status AS ENUM ('запланирован', 'активен', 'завершен', 'отменен');
CREATE TYPE organization_status AS ENUM ('активен', 'неактивен', 'заблокирован');
CREATE TYPE athlete_status AS ENUM ('активен', 'неактивен', 'дисквалифицирован', 'травмирован');
CREATE TYPE judge_status AS ENUM ('активен', 'неактивен', 'на больничном', 'на пенсии');
CREATE TYPE weighin_status AS ENUM ('ожидание', 'пройдено', 'не пройдено');
