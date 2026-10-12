\set VERBOSITY verbose

-- Подготовка: корректные тестовые данные
INSERT INTO beauty.users (first_name, last_name, phone, email) VALUES
  ('Тест', 'Клиентов', '+77001112233', 'client@example.com'),
  ('Тест', 'Мастеров', '+77004445566', 'master@example.com');

INSERT INTO beauty.masters (user_id, salon_id, specialization)
SELECT u.id, s.id, 'тест-мастер'
FROM beauty.users u, beauty.salons s
WHERE u.phone = '+77004445566' AND s.name = 'Mn studio';

INSERT INTO beauty.working_schedules (master_id, work_date, start_time, end_time)
SELECT id, '2026-11-02', '10:00', '18:00'
FROM beauty.masters WHERE specialization = 'тест-мастер';

-- Тест 1. Ожидается 23503 (fk_appointments_client_id): клиента с id -1 нет
INSERT INTO beauty.appointments (client_id, master_id, service_id, start_at, end_at)
SELECT -1, m.id, s.id, '2026-11-02 10:00+05', '2026-11-02 11:00+05'
FROM beauty.masters m, beauty.services s
WHERE m.specialization = 'тест-мастер' AND s.name = 'Маникюр классический';

-- Тест 2. Ожидается 23503 (fk_masters_salon_id): салон с мастерами удалить нельзя
DELETE FROM beauty.salons WHERE name = 'Mn studio';

-- Тест 3. Ожидается 23514 (chk_appointments_completed_has_price): выполнена, но без цены
INSERT INTO beauty.appointments (client_id, master_id, service_id, start_at, end_at, status, price_total)
SELECT c.id, m.id, s.id, '2026-11-02 12:00+05', '2026-11-02 13:00+05', 'completed', NULL
FROM beauty.users c, beauty.masters m, beauty.services s
WHERE c.phone = '+77001112233' AND m.specialization = 'тест-мастер'
  AND s.name = 'Маникюр классический';

-- Тест 4. Ожидается 23514 (chk_appointments_max_duration): запись длиной 9 часов
INSERT INTO beauty.appointments (client_id, master_id, service_id, start_at, end_at)
SELECT c.id, m.id, s.id, '2026-11-02 09:00+05', '2026-11-02 18:00+05'
FROM beauty.users c, beauty.masters m, beauty.services s
WHERE c.phone = '+77001112233' AND m.specialization = 'тест-мастер'
  AND s.name = 'Маникюр классический';

-- Тест 5. Ожидается 23505 (uq_users_phone): телефон уже занят
INSERT INTO beauty.users (first_name, last_name, phone)
VALUES ('Дубль', 'Клиентов', '+77001112233');

-- Тест 6. Ожидается 23514 (chk_users_phone_format): телефон не в формате +7XXXXXXXXXX
INSERT INTO beauty.users (first_name, last_name, phone)
VALUES ('Неверный', 'Телефонов', '87001112233');

-- Тест 7. Ожидается 23505 (uq_schedule_master_date): второй график на тот же день
INSERT INTO beauty.working_schedules (master_id, work_date, start_time, end_time)
SELECT id, '2026-11-02', '12:00', '20:00'
FROM beauty.masters WHERE specialization = 'тест-мастер';

-- Тест 8. Ожидается 22P02 (тип beauty.appointment_status): такого статуса нет в ENUM
INSERT INTO beauty.appointments (client_id, master_id, service_id, start_at, end_at, status)
SELECT c.id, m.id, s.id, '2026-11-02 14:00+05', '2026-11-02 15:00+05', 'done'
FROM beauty.users c, beauty.masters m, beauty.services s
WHERE c.phone = '+77001112233' AND m.specialization = 'тест-мастер'
  AND s.name = 'Маникюр классический';

-- Очистка тестовых данных
DELETE FROM beauty.masters WHERE specialization = 'тест-мастер';
DELETE FROM beauty.users WHERE phone IN ('+77001112233', '+77004445566');

no changes added to commit (use "git add" and/or "git commit -a")
PS C:\Users\user\OneDrive\Desktop\tursunova-db> git add migrations/03_constraints.sql queries/week03_negative.sql reports/week03.md
warning: in the working copy of 'migrations/03_constraints.sql', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'queries/week03_negative.sql', LF will be replaced by CRLF the next time Git touches it
warning: in the working copy of 'reports/week03.md', LF will be replaced by CRLF the next time Git touches it
PS C:\Users\user\OneDrive\Desktop\tursunova-db> git commit -m "Add week 03 database constraints and negative tests"
[main abaa8f9] Add week 03 database constraints and negative tests
 3 files changed, 280 insertions(+)
 create mode 100644 migrations/03_constraints.sql
 create mode 100644 queries/week03_negative.sql
 create mode 100644 reports/week03.md
PS C:\Users\user\OneDrive\Desktop\tursunova-db> 