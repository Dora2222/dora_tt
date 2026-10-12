-- Week 03 negative tests.
-- Every INSERT marked NEGATIVE is expected to fail. The SQLSTATE is in the comment.
-- Do not run this file with psql's -v ON_ERROR_STOP=1: expected errors must not stop later tests.
-- The fixture and all test changes are rolled back at the end.
\set ON_ERROR_STOP off
\set VERBOSITY verbose

BEGIN;

-- Valid fixture used only to test the UNIQUE constraint; final ROLLBACK removes it.
INSERT INTO beauty.users (first_name, last_name, phone, email)
VALUES ('Test', 'Fixture', '+7-700-000-00-01', 'fixture@example.kz');

\echo 'NEGATIVE TEST 1: invalid email; expected SQLSTATE 23514 (check_violation)'
SAVEPOINT neg_email;
INSERT INTO beauty.users (first_name, last_name, phone, email)
VALUES ('Test', 'BadEmail', '+7-700-000-00-02', 'not-an-email');
ROLLBACK TO SAVEPOINT neg_email;
RELEASE SAVEPOINT neg_email;

\echo 'NEGATIVE TEST 2: duplicate phone; expected SQLSTATE 23505 (unique_violation)'
SAVEPOINT neg_unique_phone;
INSERT INTO beauty.users (first_name, last_name, phone, email)
VALUES ('Duplicate', 'Phone', '+7-700-000-00-01', 'duplicate@example.kz');
ROLLBACK TO SAVEPOINT neg_unique_phone;
RELEASE SAVEPOINT neg_unique_phone;

\echo 'NEGATIVE TEST 3: invalid salon phone; expected SQLSTATE 23514 (check_violation)'
SAVEPOINT neg_salon_phone;
INSERT INTO beauty.salons (name, address, phone)
VALUES ('Negative test salon', 'Test address, Almaty', 'not-a-phone');
ROLLBACK TO SAVEPOINT neg_salon_phone;
RELEASE SAVEPOINT neg_salon_phone;

\echo 'NEGATIVE TEST 4: missing owner user; expected SQLSTATE 23503 (foreign_key_violation)'
SAVEPOINT neg_owner_fk;
INSERT INTO beauty.salons (name, address, phone, owner_id)
VALUES ('FK test salon', 'Test address, Almaty', '+7-700-000-00-03', 999999999);
ROLLBACK TO SAVEPOINT neg_owner_fk;
RELEASE SAVEPOINT neg_owner_fk;

\echo 'NEGATIVE TEST 5: unsupported appointment status; expected SQLSTATE 22P02 (invalid_text_representation)'
SAVEPOINT neg_status_enum;
INSERT INTO beauty.appointments
    (client_id, master_id, service_id, start_at, end_at, status)
VALUES
    (999999999, 999999999, 999999999,
     now() + INTERVAL '1 day', now() + INTERVAL '2 hours', 'pending');
ROLLBACK TO SAVEPOINT neg_status_enum;
RELEASE SAVEPOINT neg_status_enum;

ROLLBACK;
\echo 'Finished: test fixture/data were rolled back.'
