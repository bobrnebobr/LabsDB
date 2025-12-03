CREATE OR REPLACE PROCEDURE transfer_employee(emp_id INT, new_position INT)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employee
    SET position_id = new_position
    WHERE employee_id = emp_id;

    COMMIT;
END;
$$;

CALL transfer_employee(1, 3);