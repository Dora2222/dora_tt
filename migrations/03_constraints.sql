-- Week 03: data integrity constraints for the beauty salon database.
-- Run after migrations/01_init.sql and migrations/02_schema.sql.
-- This migration is intended to be applied once to a schema created by those migrations.

BEGIN;

-- Replace the text status + CHECK with a real PostgreSQL ENUM.
ALTER TABLE beauty.appointments
    DROP CONSTRAINT IF EXISTS appointments_status_check;
ALTER TABLE beauty.appointments
    ALTER COLUMN status DROP DEFAULT;

CREATE TYPE beauty.appointment_status AS ENUM
    ('booked', 'completed', 'cancelled');

ALTER TABLE beauty.appointments
    ALTER COLUMN status TYPE beauty.appointment_status
    USING status::text::beauty.appointment_status;
ALTER TABLE beauty.appointments
    ALTER COLUMN status SET DEFAULT 'booked'::beauty.appointment_status;

-- Foreign keys and intentional ON DELETE behaviours.
-- A deleted owner account must not delete the salon listing.
ALTER TABLE beauty.salons
    ADD CONSTRAINT fk_salons_owner
    FOREIGN KEY (owner_id) REFERENCES beauty.users(id)
    ON DELETE SET NULL;

-- Keep a service if its category is removed; the category can be reassigned later.
ALTER TABLE beauty.services
    ADD CONSTRAINT fk_services_category
    FOREIGN KEY (category_id) REFERENCES beauty.categories(id)
    ON DELETE SET NULL;

-- Role assignments are dependent rows and should disappear with the user.
ALTER TABLE beauty.user_roles
    ADD CONSTRAINT fk_user_roles_user
    FOREIGN KEY (user_id) REFERENCES beauty.users(id)
    ON DELETE CASCADE;

-- Do not delete a role while it is assigned to users.
ALTER TABLE beauty.user_roles
    ADD CONSTRAINT fk_user_roles_role
    FOREIGN KEY (role_id) REFERENCES beauty.roles(id)
    ON DELETE RESTRICT;

-- Keep a master profile attached to its account and salon; remove/reassign links explicitly.
ALTER TABLE beauty.masters
    ADD CONSTRAINT fk_masters_user
    FOREIGN KEY (user_id) REFERENCES beauty.users(id)
    ON DELETE RESTRICT;

ALTER TABLE beauty.masters
    ADD CONSTRAINT fk_masters_salon
    FOREIGN KEY (salon_id) REFERENCES beauty.salons(id)
    ON DELETE RESTRICT;

-- These are bridge/schedule records and depend on the master.
ALTER TABLE beauty.master_services
    ADD CONSTRAINT fk_master_services_master
    FOREIGN KEY (master_id) REFERENCES beauty.masters(id)
    ON DELETE CASCADE;

-- A service in use by a master should not be removed from the catalogue.
ALTER TABLE beauty.master_services
    ADD CONSTRAINT fk_master_services_service
    FOREIGN KEY (service_id) REFERENCES beauty.services(id)
    ON DELETE RESTRICT;

ALTER TABLE beauty.working_schedules
    ADD CONSTRAINT fk_working_schedules_master
    FOREIGN KEY (master_id) REFERENCES beauty.masters(id)
    ON DELETE CASCADE;

-- Preserve booking history; referenced client/master/service records cannot be deleted.
ALTER TABLE beauty.appointments
    ADD CONSTRAINT fk_appointments_client
    FOREIGN KEY (client_id) REFERENCES beauty.users(id)
    ON DELETE RESTRICT;

ALTER TABLE beauty.appointments
    ADD CONSTRAINT fk_appointments_master
    FOREIGN KEY (master_id) REFERENCES beauty.masters(id)
    ON DELETE RESTRICT;

ALTER TABLE beauty.appointments
    ADD CONSTRAINT fk_appointments_service
    FOREIGN KEY (service_id) REFERENCES beauty.services(id)
    ON DELETE RESTRICT;

-- A review belongs to one appointment and is removed if that appointment is removed.
ALTER TABLE beauty.reviews
    ADD CONSTRAINT fk_reviews_appointment
    FOREIGN KEY (appointment_id) REFERENCES beauty.appointments(id)
    ON DELETE CASCADE;

-- Domain-specific CHECK constraints.
ALTER TABLE beauty.categories
    ADD CONSTRAINT ck_categories_name_length
    CHECK (char_length(btrim(name)) BETWEEN 2 AND 80);

ALTER TABLE beauty.services
    ADD CONSTRAINT ck_services_name_length
    CHECK (char_length(btrim(name)) BETWEEN 2 AND 120);

ALTER TABLE beauty.salons
    ADD CONSTRAINT ck_salons_name_length
    CHECK (char_length(btrim(name)) BETWEEN 2 AND 160);

ALTER TABLE beauty.salons
    ADD CONSTRAINT ck_salons_address_length
    CHECK (char_length(btrim(address)) BETWEEN 5 AND 250);

ALTER TABLE beauty.salons
    ADD CONSTRAINT ck_salons_phone_format
    CHECK (phone IS NULL OR phone ~ '^[+]?[0-9][0-9() -]{8,18}$');

ALTER TABLE beauty.users
    ADD CONSTRAINT ck_users_phone_format
    CHECK (phone ~ '^[+]?[0-9][0-9() -]{8,18}$');

ALTER TABLE beauty.users
    ADD CONSTRAINT ck_users_email_format
    CHECK (email IS NULL OR email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+[.][A-Z]{2,}$');

ALTER TABLE beauty.masters
    ADD CONSTRAINT ck_masters_specialization_length
    CHECK (specialization IS NULL OR char_length(btrim(specialization)) BETWEEN 2 AND 120);

-- Project rule: salon appointments/schedules are within 06:00–23:00.
ALTER TABLE beauty.working_schedules
    ADD CONSTRAINT ck_working_schedules_business_hours
    CHECK (start_time >= TIME '06:00' AND end_time <= TIME '23:00');

-- A beauty service booking must last at least 10 minutes and no more than 8 hours.
ALTER TABLE beauty.appointments
    ADD CONSTRAINT ck_appointments_duration
    CHECK ((end_at - start_at) BETWEEN INTERVAL '10 minutes' AND INTERVAL '8 hours');

-- Reviews may omit the comment, but a supplied comment must contain useful text.
ALTER TABLE beauty.reviews
    ADD CONSTRAINT ck_reviews_comment_length
    CHECK (comment IS NULL OR char_length(btrim(comment)) BETWEEN 5 AND 2000);

-- UNIQUE rules: one account per phone; one master profile per user in a given salon.
ALTER TABLE beauty.users
    ADD CONSTRAINT uq_users_phone UNIQUE (phone);

ALTER TABLE beauty.masters
    ADD CONSTRAINT uq_masters_user_salon UNIQUE (user_id, salon_id);

COMMIT;
