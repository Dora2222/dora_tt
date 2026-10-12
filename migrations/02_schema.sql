

-- Доработка таблиц из недели 1
ALTER TABLE beauty.salons   ADD COLUMN owner_id    bigint;
ALTER TABLE beauty.services ADD COLUMN category_id bigint;
ALTER TABLE beauty.services ADD COLUMN description text;

CREATE TABLE beauty.roles (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        text NOT NULL,
  description text
);

CREATE TABLE beauty.users (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name  text NOT NULL,
  phone      text NOT NULL,
  email      text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE beauty.user_roles (
  user_id     bigint NOT NULL,
  role_id     bigint NOT NULL,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE beauty.masters (
  id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id        bigint NOT NULL,
  salon_id       bigint NOT NULL,
  specialization text,
  bio            text,
  created_at     timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE beauty.master_services (
  master_id    bigint NOT NULL,
  service_id   bigint NOT NULL,
  price        numeric(10,2) CHECK (price >= 0),
  duration_min integer NOT NULL CHECK (duration_min > 0),
  PRIMARY KEY (master_id, service_id)
);

CREATE TABLE beauty.working_schedules (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  master_id  bigint NOT NULL,
  work_date  date NOT NULL,
  start_time time NOT NULL,
  end_time   time NOT NULL,
  CHECK (end_time > start_time)
);

CREATE TABLE beauty.appointments (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  client_id   bigint NOT NULL,
  master_id   bigint NOT NULL,
  service_id  bigint NOT NULL,
  start_at    timestamptz NOT NULL,
  end_at      timestamptz NOT NULL,
  status      text NOT NULL DEFAULT 'booked'
              CHECK (status IN ('booked', 'completed', 'cancelled')),
  price_total numeric(10,2) CHECK (price_total >= 0),
  created_at  timestamptz NOT NULL DEFAULT now(),
  CHECK (end_at > start_at)
);

CREATE TABLE beauty.reviews (
  id             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  appointment_id bigint NOT NULL,
  rating         smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment        text,
  created_at     timestamptz NOT NULL DEFAULT now()
);

-- Комментарии к таблицам
COMMENT ON TABLE beauty.roles            IS 'Справочник ролей пользователей: клиент, мастер, владелец салона, администратор';
COMMENT ON TABLE beauty.users            IS 'Учётные записи всех пользователей сервиса';
COMMENT ON TABLE beauty.user_roles       IS 'Связь M:N: какие роли есть у пользователя';
COMMENT ON TABLE beauty.salons           IS 'Салоны красоты (справочник из 2GIS)';
COMMENT ON TABLE beauty.masters          IS 'Мастера: профиль пользователя-мастера в конкретном салоне';
COMMENT ON TABLE beauty.categories       IS 'Категории услуг: маникюр, брови, массаж и т. д.';
COMMENT ON TABLE beauty.services         IS 'Каталог услуг с базовой ценой';
COMMENT ON TABLE beauty.master_services  IS 'Связь M:N: какие услуги выполняет мастер, с его ценой и длительностью';
COMMENT ON TABLE beauty.working_schedules IS 'График работы мастера по датам';
COMMENT ON TABLE beauty.appointments     IS 'ТАБЛИЦА-ФАКТ: записи клиентов к мастерам, к неделе 4 вырастет до 300 000 строк';
COMMENT ON TABLE beauty.reviews          IS 'Отзывы клиентов о выполненных записях (текстовое поле для поиска)';

-- Комментарии к неочевидным колонкам
COMMENT ON COLUMN beauty.salons.owner_id            IS 'Ссылка на users.id: владелец салона';
COMMENT ON COLUMN beauty.services.category_id       IS 'Ссылка на categories.id';
COMMENT ON COLUMN beauty.services.price             IS 'Базовая цена услуги в тенге; цена мастера может отличаться, см. master_services.price';
COMMENT ON COLUMN beauty.user_roles.assigned_at     IS 'Когда пользователю назначена роль (атрибут связи)';
COMMENT ON COLUMN beauty.masters.user_id            IS 'Ссылка на users.id: учётная запись мастера';
COMMENT ON COLUMN beauty.masters.salon_id           IS 'Ссылка на salons.id: салон, где работает мастер';
COMMENT ON COLUMN beauty.master_services.price      IS 'Цена этой услуги у этого мастера в тенге (атрибут связи)';
COMMENT ON COLUMN beauty.master_services.duration_min IS 'За сколько минут мастер выполняет услугу (атрибут связи)';
COMMENT ON COLUMN beauty.working_schedules.master_id IS 'Ссылка на masters.id';
COMMENT ON COLUMN beauty.appointments.client_id     IS 'Ссылка на users.id: клиент';
COMMENT ON COLUMN beauty.appointments.master_id     IS 'Ссылка на masters.id';
COMMENT ON COLUMN beauty.appointments.service_id    IS 'Ссылка на services.id';
COMMENT ON COLUMN beauty.appointments.status        IS 'booked — записан, completed — выполнена, cancelled — отменена';
COMMENT ON COLUMN beauty.appointments.price_total   IS 'Цена на момент записи в тенге: прайс может измениться, а история нет';
COMMENT ON COLUMN beauty.reviews.appointment_id     IS 'Ссылка на appointments.id: к какой записи относится отзыв';
COMMENT ON COLUMN beauty.reviews.rating             IS 'Оценка от 1 до 5';