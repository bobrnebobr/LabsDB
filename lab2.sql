--- SELECT-запросы (чтение данных) ---

SELECT
    equipment_id,
    name,
    purchase_date,
    status
FROM equipment
WHERE status = 'Ready to use'
ORDER BY purchase_date DESC
LIMIT 5;

SELECT
    et.type_name AS equipment_type,
    SUM(we.quantity) AS total_count
FROM warehouse_equipment we
JOIN equipment e ON we.equipment_id = e.equipment_id
JOIN equipment_type et ON e.type_id = et.type_id
GROUP BY et.type_name
ORDER BY total_count DESC;

SELECT
    w.name AS warehouse_name,
    SUM(we.quantity) AS total_count
FROM warehouse_equipment we
JOIN warehouse w ON we.warehouse_id = w.warehouse_id
GROUP BY w.name
HAVING SUM(we.quantity) > 10
ORDER BY total_count DESC;

SELECT DISTINCT
    e.first_name,
    e.last_name
FROM employee e
WHERE EXISTS (
    SELECT 1
    FROM maintenance m
    JOIN equipment eq ON m.equipment_id = eq.equipment_id
    JOIN equipment_type et ON eq.type_id = et.type_id
    WHERE m.employee_id = e.employee_id
      AND et.type_name = 'Компрессор'
);

WITH expired AS (
    SELECT
        equipment_id,
        name,
        purchase_date,
        warranty_end,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, purchase_date)) AS years_since_purchase
    FROM equipment
    WHERE warranty_end IS NOT NULL
      AND warranty_end < CURRENT_DATE
)
SELECT * FROM expired
ORDER BY years_since_purchase DESC;

--- Модифицирующие запросы ---
INSERT INTO supplier (name, contact_name, phone_number, email)
VALUES ('ООО "ТехМир"', 'Владимир Руденко', '84956667788', 'info@techmir.ru');

INSERT INTO "order" (employee_id, order_date)
SELECT employee_id, CURRENT_DATE
FROM employee
WHERE email = 'petr.kuznetsov@company.ru';

UPDATE equipment
SET status = 'Ready to use'
WHERE status = 'Need repair';

DELETE FROM equipment
WHERE status = 'Subject to disposal';

UPDATE warehouse_equipment
SET quantity = quantity - 2
WHERE warehouse_id = (
    SELECT from_warehouse_id
    FROM equipment_movement
    WHERE equipment_id = 1
    ORDER BY movement_date DESC
    LIMIT 1
);


--- Представления ---
CREATE OR REPLACE VIEW view_equipment_details AS
SELECT
    e.equipment_id,
    e.name AS equipment_name,
    et.type_name AS equipment_type,
    s.name AS supplier_name,
    e.status,
    w.name AS warehouse_name,
    we.quantity AS warehouse_quantity
FROM equipment e
LEFT JOIN equipment_type et ON e.type_id = et.type_id
LEFT JOIN supplier s ON e.supplier_id = s.supplier_id
LEFT JOIN warehouse_equipment we ON e.equipment_id = we.equipment_id
LEFT JOIN warehouse w ON we.warehouse_id = w.warehouse_id;

CREATE MATERIALIZED VIEW mv_warehouse_statistics AS
SELECT
    w.warehouse_id,
    w.name AS warehouse_name,
    COUNT(DISTINCT e.equipment_id) AS total_equipment_types,
    SUM(we.quantity) AS total_quantity
FROM warehouse_equipment we
JOIN warehouse w ON we.warehouse_id = w.warehouse_id
JOIN equipment e ON we.equipment_id = e.equipment_id
GROUP BY w.warehouse_id, w.name;

REFRESH MATERIALIZED VIEW mv_warehouse_statistics;