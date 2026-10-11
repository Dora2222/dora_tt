DROP SCHEMA IF EXISTS beauty CASCADE;
CREATE SCHEMA beauty;

CREATE TABLE beauty.categories (
  id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name        text NOT NULL,
  description text,
  created_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE beauty.services (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name       text NOT NULL,
  price      numeric(10,2) CHECK (price >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE beauty.salons (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name       text NOT NULL,
  address    text NOT NULL,
  phone      text,
  created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO beauty.categories (name, description) VALUES
  ('Стрижки и укладки', 'Женские, мужские и детские стрижки, укладка и причёски'),
  ('Окрашивание волос', 'Окрашивание в один тон, мелирование, сложные техники'),
  ('Уход за волосами', 'Кератиновое выпрямление, ботокс, восстановление волос'),
  ('Маникюр', 'Классический и аппаратный маникюр, покрытие гель-лаком'),
  ('Педикюр', 'Классический и аппаратный педикюр, обработка стоп'),
  ('Брови', 'Коррекция, окрашивание и ламинирование бровей'),
  ('Ресницы', 'Наращивание, ламинирование и окрашивание ресниц'),
  ('Косметология', 'Чистка лица, пилинги, уходовые процедуры'),
  ('Эпиляция', 'Шугаринг и восковая эпиляция'),
  ('Массаж', 'Классический, лечебный и расслабляющий массаж');

  INSERT INTO beauty.salons (name, address, phone) VALUES
  ('ERKE ERSIN beauty studio', 'улица Жолдасбекова, 9а', '+7-747-995-05-02'),
  ('Mn studio', 'микрорайон Думан-2, 57/2', '+7-778-601-28-74'),
  ('Janelle Beauty', 'ЖК Евразия, улица Масанчи, 23/2', '+7-707-615-14-38'),
  ('Zuhra hanum beauty', 'ЖК Central Park Residence, улица Ришата и Муслима Абдуллиных, 28/1', '+7-701-700-03-54'),
  ('Krasnoe Yabloko', 'проспект Назарбаева, 77', '+7-707-532-98-88'),
  ('Stella Beauty Concept', 'проспект Назарбаева, 113', '+7-707-167-15-13'),
  ('Timeless Beauty Studio', 'улица Кунаева, 43, кабинет 215', '+7-707-335-52-91'),
  ('Qoroleva_lashes', 'ТЦ Квартал, проспект Жибек Жолы, 50 блок В, офис 23', '+7-707-666-99-83'),
  ('Level Beauty Concept', 'улица Кунаева, 43, кабинет 206', '+7-700-600-20-26'),
  ('Nazira Erkin Image Studio', 'Гостиница Казахстан, проспект Достык, 52/2, офис 613', '+7-778-640-66-79');


  INSERT INTO beauty.services (name, price) VALUES
  ('Женская стрижка', 10000),
  ('Авторский пилинг головы', 15000),
  ('Маникюр классический', 6000),
  ('Маникюр с гель покрытием', 9500),
  ('Классический педикюр', 10000),
  ('Ламинирование бровей', 8000),
  ('Наращивание ресниц', 12000),
  ('Шугаринг ног', 8000),
  ('Чистка лица', 20000),
  ('Массаж спины', 10000);
  