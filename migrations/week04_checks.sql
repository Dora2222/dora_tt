-- queries/week04_checks.sql
-- Проверки после наполнения: объёмы, размер базы, распределения, контрольные суммы.

\echo '--- Количество строк по всем таблицам ---'
SELECT 'roles' AS tbl, count(*) AS cnt FROM beauty.roles
UNION ALL SELECT 'users',             count(*) FROM beauty.users
UNION ALL SELECT 'user_roles',        count(*) FROM beauty.user_roles
UNION ALL SELECT 'salons',            count(*) FROM beauty.salons
UNION ALL SELECT 'masters',           count(*) FROM beauty.masters
UNION ALL SELECT 'categories',        count(*) FROM beauty.categories
UNION ALL SELECT 'services',          count(*) FROM beauty.services
UNION ALL SELECT 'master_services',   count(*) FROM beauty.master_services
UNION ALL SELECT 'working_schedules', count(*) FROM beauty.working_schedules
UNION ALL SELECT 'appointments',      count(*) FROM beauty.appointments
UNION ALL SELECT 'reviews',           count(*) FROM beauty.reviews;

\echo '--- Размер базы и таблиц ---'
SELECT pg_size_pretty(pg_database_size(current_database())) AS db_size;

SELECT relname AS table_name,
       pg_size_pretty(pg_total_relation_size(oid)) AS total_size
FROM pg_class
WHERE relnamespace = 'beauty'::regnamespace
  AND relkind = 'r'
ORDER BY pg_total_relation_size(oid) DESC;

\echo '--- Записи по дням недели (1 = понедельник, 7 = воскресенье) ---'
SELECT extract(isodow FROM start_at AT TIME ZONE 'Asia/Almaty')::int AS isodow,
       count(*) AS cnt,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct
FROM beauty.appointments
GROUP BY 1
ORDER BY 1;

\echo '--- Записи по часам начала ---'
SELECT extract(hour FROM start_at AT TIME ZONE 'Asia/Almaty')::int AS hour,
       count(*) AS cnt,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct
FROM beauty.appointments
GROUP BY 1
ORDER BY 1;

\echo '--- Записи по месяцам (сезонность) ---'
SELECT to_char(start_at AT TIME ZONE 'Asia/Almaty', 'YYYY-MM') AS month,
       count(*) AS cnt
FROM beauty.appointments
GROUP BY 1
ORDER BY 1;

\echo '--- Статусы записей ---'
SELECT status, count(*) AS cnt,
       round(100.0 * count(*) / sum(count(*)) OVER (), 1) AS pct
FROM beauty.appointments
GROUP BY status
ORDER BY cnt DESC;

\echo '--- Оценки в отзывах ---'
SELECT rating, count(*) AS cnt
FROM beauty.reviews
GROUP BY rating
ORDER BY rating DESC;

\echo '--- Контрольные суммы для проверки воспроизводимости ---'
SELECT count(*) AS n,
       sum(extract(epoch FROM start_at))::bigint AS epoch_sum,
       sum(price_total) AS price_sum,
       sum(client_id) AS client_sum,
       sum(master_id) AS master_sum
FROM beauty.appointments;
