CREATE TABLE IF NOT EXISTS position_counter
(
    position_id INT PRIMARY KEY,
    employee_count INT DEFAULT 0
);

INSERT INTO position_counter(position_id, employee_count)
SELECT position_id, COUNT(*)
FROM employee
GROUP BY position_id;

CREATE OR REPLACE FUNCTION update_position_counter()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.position_id IS NOT NULL THEN
        UPDATE position_counter
        SET employee_count = employee_count - 1
        WHERE position_id = OLD.position_id;
    END IF;

    IF NEW.position_id IS NOT NULL THEN
        UPDATE position_counter
        SET employee_count = employee_count + 1
        WHERE position_id = NEW.position_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_employee_update
AFTER UPDATE OF position_id ON employee
FOR EACH ROW
EXECUTE FUNCTION update_position_counter();

CREATE OR REPLACE FUNCTION trigger_back_employee()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE employee
    SET last_name = 'Updated'
    WHERE position_id = NEW.position_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_counter_update
AFTER UPDATE ON position_counter
FOR EACH ROW
EXECUTE FUNCTION trigger_back_employee();

UPDATE employee
SET position_id = 1
WHERE employee_id = 1;