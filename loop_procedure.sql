CREATE OR REPLACE PROCEDURE transfer_employees_loop()
LANGUAGE plpgsql
AS $$
DECLARE
    emp_record employee%ROWTYPE;
BEGIN
    FOR emp_record IN
        SELECT * FROM employee WHERE position_id = 1
    LOOP
        UPDATE employee
        SET position_id = 2
        WHERE employee_id = emp_record.employee_id;
    END LOOP;
END;
$$;

CALL transfer_employees_loop();