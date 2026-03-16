-- Федерации
CREATE TABLE Federation (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100)
);

-- Регионы
CREATE TABLE Region (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    federation_id INTEGER NOT NULL REFERENCES Federation(id) ON DELETE CASCADE
);

-- Организации
CREATE TABLE Organization (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    inn VARCHAR(20) UNIQUE,
    address TEXT,
    status organization_status DEFAULT 'активен',
    federation_id INTEGER NOT NULL REFERENCES Federation(id),
    region_id INTEGER NOT NULL REFERENCES Region(id)
);

-- Пользователи
CREATE TABLE Users (
    id SERIAL PRIMARY KEY,
    fio VARCHAR(255) NOT NULL,
    dob DATE,
    email VARCHAR(255) UNIQUE NOT NULL,
    gender user_gender,
    createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    phone VARCHAR(20),
    federation_id INTEGER NOT NULL REFERENCES Federation(id),
    region_id INTEGER NOT NULL REFERENCES Region(id), -- регион проживания
    organization_id INTEGER NOT NULL REFERENCES Organization(id) -- член организации
);

-- Роли
CREATE TABLE Role (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL
);

-- Права
CREATE TABLE Permissions (
    id SERIAL PRIMARY KEY,
    code VARCHAR(100) UNIQUE NOT NULL,
    description TEXT
);

-- Роли пользователей
CREATE TABLE UserRoles (
    users_id INTEGER NOT NULL REFERENCES Users(id) ON DELETE CASCADE,
    role_id INTEGER NOT NULL REFERENCES Role(id) ON DELETE CASCADE,
    PRIMARY KEY (users_id, role_id)
);

-- Права ролей
CREATE TABLE RolePermissions (
    role_id INTEGER NOT NULL REFERENCES Role(id) ON DELETE CASCADE,
    permissions_id INTEGER NOT NULL REFERENCES Permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permissions_id)
);

-- Спортсмены
CREATE TABLE Athlete (
    id SERIAL PRIMARY KEY,
    currentWeight DECIMAL(5,2),
    insuranceId VARCHAR(100),
    insuranceExpiry DATE,
    rank VARCHAR(50),
    status athlete_status DEFAULT 'активен',
    users_id INTEGER UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE
);

-- Судьи
CREATE TABLE Judges (
    id SERIAL PRIMARY KEY,
    licenseNumber VARCHAR(100) UNIQUE,
    isActive BOOLEAN DEFAULT true,
    status judge_status DEFAULT 'активен',
    users_id INTEGER UNIQUE NOT NULL REFERENCES Users(id) ON DELETE CASCADE
);

-- Статистика
CREATE TABLE Statistics (
    id SERIAL PRIMARY KEY,
    wins INTEGER DEFAULT 0,
    loses INTEGER DEFAULT 0,
    ratingPoints INTEGER DEFAULT 0,
    athlete_id INTEGER UNIQUE NOT NULL REFERENCES Athlete(id) ON DELETE CASCADE
);

-- Дисциплины
CREATE TABLE Discipline (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

-- Возрастные группы
CREATE TABLE AgeGroup (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    minAge INTEGER,
    maxAge INTEGER
);

-- Уровни поясов
CREATE TABLE BeltLevel (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) UNIQUE NOT NULL
);

-- Весовые категории
CREATE TABLE WeightCategory (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    minWeight DECIMAL(5,2),
    maxWeight DECIMAL(5,2)
);

-- Турниры
CREATE TABLE Tournament (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(100),
    startDate DATE,
    endDate DATE,
    entryFee DECIMAL(10,2),
    federation_id INTEGER NOT NULL REFERENCES Federation(id),
    organization_id INTEGER NOT NULL REFERENCES Organization(id)
);

-- Заявки
CREATE TABLE Entry (
    id SERIAL PRIMARY KEY,
    declaredWeight DECIMAL(5,2),
    status entry_status DEFAULT 'ожидание',
    gender user_gender,
    discipline_id INTEGER NOT NULL REFERENCES Discipline(id),
    organization_id INTEGER NOT NULL REFERENCES Organization(id),
    age_group_id INTEGER NOT NULL REFERENCES AgeGroup(id),
    belt_level_id INTEGER NOT NULL REFERENCES BeltLevel(id),
    weight_category_id INTEGER NOT NULL REFERENCES WeightCategory(id),
    tournament_id INTEGER NOT NULL REFERENCES Tournament(id) ON DELETE CASCADE,
    athlete_id INTEGER NOT NULL REFERENCES Athlete(id) ON DELETE CASCADE
);

-- Поединки
CREATE TABLE Match (
    id SERIAL PRIMARY KEY,
    roundNumber INTEGER,
    status match_status DEFAULT 'запланирован',
    startTime TIMESTAMP,
    endTime TIMESTAMP,
    matchDuration INTEGER,
    tournament_id INTEGER NOT NULL REFERENCES Tournament(id) ON DELETE CASCADE,
    discipline_id INTEGER NOT NULL REFERENCES Discipline(id),
    entry_red_id INTEGER NOT NULL REFERENCES Entry(id), -- участник красный
    entry_blue_id INTEGER NOT NULL REFERENCES Entry(id), -- участник синий
    winner_id INTEGER REFERENCES Entry(id) -- победитель
);

-- Счет
CREATE TABLE Score (
    id SERIAL PRIMARY KEY,
    roundNumber INTEGER,
    blueScore INTEGER DEFAULT 0,
    redScore INTEGER DEFAULT 0,
    tulScore DECIMAL(5,2),
    judges_id INTEGER NOT NULL REFERENCES Judges(id),
    match_id INTEGER NOT NULL REFERENCES Match(id) ON DELETE CASCADE
);

-- Штрафы
CREATE TABLE Penalty (
    id SERIAL PRIMARY KEY,
    type VARCHAR(100),
    points INTEGER,
    entry_id INTEGER NOT NULL REFERENCES Entry(id),
    match_id INTEGER NOT NULL REFERENCES Match(id) ON DELETE CASCADE,
    judges_id INTEGER NOT NULL REFERENCES Judges(id)
);

-- Взвешивание
CREATE TABLE WeighIn (
    id SERIAL PRIMARY KEY,
    actualWeight DECIMAL(5,2),
    weighDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status weighin_status DEFAULT 'ожидание',
    fineAmount DECIMAL(10,2),
    entry_id INTEGER NOT NULL REFERENCES Entry(id) ON DELETE CASCADE
);

-- Назначение судей
CREATE TABLE JudgeAssignment (
    id SERIAL PRIMARY KEY,
    role VARCHAR(100),
    tournament_id INTEGER NOT NULL REFERENCES Tournament(id) ON DELETE CASCADE,
    judges_id INTEGER NOT NULL REFERENCES Judges(id) ON DELETE CASCADE
);

-- Индексы для производительности
CREATE INDEX idx_region_federation ON Region(federation_id);
CREATE INDEX idx_organization_federation ON Organization(federation_id);
CREATE INDEX idx_organization_region ON Organization(region_id);
CREATE INDEX idx_users_federation ON Users(federation_id);
CREATE INDEX idx_users_region ON Users(region_id);
CREATE INDEX idx_users_organization ON Users(organization_id);
CREATE INDEX idx_users_email ON Users(email);
CREATE INDEX idx_entry_tournament ON Entry(tournament_id);
CREATE INDEX idx_entry_athlete ON Entry(athlete_id);
CREATE INDEX idx_entry_discipline ON Entry(discipline_id);
CREATE INDEX idx_entry_status ON Entry(status);
CREATE INDEX idx_match_tournament ON Match(tournament_id);
CREATE INDEX idx_match_red ON Match(entry_red_id);
CREATE INDEX idx_match_blue ON Match(entry_blue_id);
CREATE INDEX idx_match_winner ON Match(winner_id);
CREATE INDEX idx_match_status ON Match(status);
CREATE INDEX idx_score_match ON Score(match_id);
CREATE INDEX idx_score_judges ON Score(judges_id);
CREATE INDEX idx_penalty_match ON Penalty(match_id);
CREATE INDEX idx_penalty_entry ON Penalty(entry_id);
CREATE INDEX idx_penalty_judges ON Penalty(judges_id);
CREATE INDEX idx_weighin_entry ON WeighIn(entry_id);
CREATE INDEX idx_weighin_status ON WeighIn(status);
CREATE INDEX idx_judgeassignment_tournament ON JudgeAssignment(tournament_id);
CREATE INDEX idx_judgeassignment_judges ON JudgeAssignment(judges_id);
CREATE INDEX idx_athlete_status ON Athlete(status);
CREATE INDEX idx_judges_status ON Judges(status);
CREATE INDEX idx_tournament_dates ON Tournament(startDate, endDate);

-- Комментарии к таблицам
COMMENT ON TABLE Federation IS 'Федерации тхэквондо';
COMMENT ON TABLE Region IS 'Регионы';
COMMENT ON TABLE Organization IS 'Организации/клубы';
COMMENT ON TABLE Users IS 'Пользователи системы';
COMMENT ON COLUMN Users.region_id IS 'Регион проживания';
COMMENT ON COLUMN Users.organization_id IS 'Член организации';
COMMENT ON TABLE Athlete IS 'Спортсмены';
COMMENT ON COLUMN Athlete.status IS 'Статус спортсмена: активен, неактивен, дисквалифицирован, травмирован';
COMMENT ON TABLE Judges IS 'Судьи';
COMMENT ON COLUMN Judges.status IS 'Статус судьи: активен, неактивен, на больничном, на пенсии';
COMMENT ON TABLE Match IS 'Поединки';
COMMENT ON COLUMN Match.entry_red_id IS 'Участник в красном углу';
COMMENT ON COLUMN Match.entry_blue_id IS 'Участник в синем углу';
COMMENT ON COLUMN Match.winner_id IS 'Победитель поединка';
