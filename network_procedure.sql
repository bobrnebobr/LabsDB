CREATE OR REPLACE PROCEDURE transfer_employees_setbased()
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employee
    SET position_id = 2
    WHERE position_id = 1;
END;
$$;

CALL transfer_employees_setbased();