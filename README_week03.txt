WEEK 03 FILES

Copy/merge these folders into the root of your existing tursunova-db project:
- migrations/03_constraints.sql
- queries/week03_negative.sql
- reports/week03.md

IMPORTANT
Your existing migrations/01_init.sql contains DROP SCHEMA IF EXISTS beauty CASCADE.
It deletes all objects and data in schema beauty. Since your current database already has migrations 01 and 02 applied, run only migration 03 now. Do not rerun 01 in the current database unless you intentionally want to recreate the schema and lose its data.

PowerShell terminal commands (from project root):

1) Configure UTF-8 for this terminal session:
   chcp 65001
   $env:PGCLIENTENCODING = "UTF8"

2) Apply the new migration once:
   psql -h localhost -p 5432 -U beauty_app -d beauty -v ON_ERROR_STOP=1 -f .\migrations\03_constraints.sql

3) Create folders if needed:
   New-Item -ItemType Directory -Force .\queries, .\reports | Out-Null

4) Run negative tests and save the actual server output. Do NOT use -v ON_ERROR_STOP=1 for this test file:
   psql -h localhost -p 5432 -U beauty_app -d beauty -f .\queries\week03_negative.sql 2>&1 | Tee-Object -FilePath .\reports\week03_negative_output.txt

5) Inspect table type and constraints:
   psql -h localhost -p 5432 -U beauty_app -d beauty
   \d beauty.appointments
   \d beauty.users
   \d beauty.masters
   \q

6) Open reports/week03_negative_output.txt, copy the actual ERROR lines for tests 1-5 into reports/week03.md, replacing the five placeholders under 'Фактический результат' and adding the lines in 'Фактический вывод PostgreSQL'.

7) Git commands from the project root:
   git status
   git add migrations/03_constraints.sql queries/week03_negative.sql reports/week03.md reports/week03_negative_output.txt
   git commit -m "Add week 03 database constraints and negative tests"

If you run the new migration and receive an error, stop and inspect it; do not rerun migrations 01 or 02 blindly. The 03 migration is a one-time migration.
