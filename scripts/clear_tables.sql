-- Очистка данных (в правильном порядке)
TRUNCATE TABLE
    Penalty, Score, Match, Entry, Tournament, Statistics,
    Athlete, Judges, UserRoles, RolePermissions, Users,
    Organization, Region, Federation, Role, Permissions,
    Discipline, AgeGroup, BeltLevel, WeightCategory,
    JudgeAssignment, WeighIn
RESTART IDENTITY CASCADE;
