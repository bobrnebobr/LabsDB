CREATE TABLE IF NOT EXISTS employee_log
(
    log_id SERIAL PRIMARY KEY,
    employee_id INT,
    action VARCHAR(50),
    action_time TIMESTAMP DEFAULT now()
);

CREATE OR REPLACE FUNCTION log_employee_insert()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employee_log(employee_id, action)
    VALUES (NEW.employee_id, 'INSERT');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employee
FOR EACH ROW
EXECUTE FUNCTION log_employee_insert();

INSERT INTO employee(first_name, last_name, phone, email, sex, position_id)
VALUES ('Test', 'User', '12345', 'test@example.com', 'Male', 1);

SELECT * FROM employee_log ORDER BY log_id DESC LIMIT 1;

