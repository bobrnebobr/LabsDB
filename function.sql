CREATE OR REPLACE FUNCTION get_full_name(emp_id INT)
RETURNS VARCHAR AS $$
DECLARE
    full_name VARCHAR;
BEGIN
    SELECT first_name || ' ' || last_name
    INTO full_name
    FROM employee
    WHERE employee_id = emp_id;

    RETURN full_name;
END;
$$ LANGUAGE plpgsql;

SELECT get_full_name(2);