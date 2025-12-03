BEGIN;

SELECT pg_advisory_lock(1001);
SELECT pg_advisory_lock(2001);

UPDATE employee
SET position_id = 2
WHERE employee_id = 2;

SELECT pg_advisory_unlock(2001);
SELECT pg_advisory_unlock(1001);

COMMIT;
