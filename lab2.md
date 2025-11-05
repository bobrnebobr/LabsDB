# 2 Лабораторная

## 1. SELECT-запросы (чтение данных)

```sql
-- 1. Последние готовые к использованию единицы оборудования
SELECT
    equipment_id,
    name,
    purchase_date,
    status
FROM equipment
WHERE status = 'Ready to use'
ORDER BY purchase_date DESC
LIMIT 5;

-- 2. Общее количество оборудования по типам
SELECT
    et.type_name AS equipment_type,
    SUM(we.quantity) AS total_count
FROM warehouse_equipment we
JOIN equipment e ON we.equipment_id = e.equipment_id
JOIN equipment_type et ON e.type_id = et.type_id
GROUP BY et.type_name
ORDER BY total_count DESC;

-- 3. Склады с большим количеством оборудования
SELECT
    w.name AS warehouse_name,
    SUM(we.quantity) AS total_count
FROM warehouse_equipment we
JOIN warehouse w ON we.warehouse_id = w.warehouse_id
GROUP BY w.name
HAVING SUM(we.quantity) > 10
ORDER BY total_count DESC;

-- 4. Сотрудники, обслуживавшие компрессоры
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

-- 5. Оборудование с истекшей гарантией
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
```

### Пояснения к SELECT-запросам:
Показывает 5 последних единиц оборудования, готовых к использованию.
Считает количество каждого типа оборудования на складах.
Отображает склады с более чем 10 единицами оборудования.
Определяет сотрудников, обслуживавших компрессоры.
Показывает оборудование с истекшей гарантией и сколько лет прошло с покупки.

## 2. Модифицирующие запросы (INSERT / UPDATE / DELETE)
```sql
-- 1. Добавление нового поставщика
INSERT INTO supplier (name, contact_name, phone_number, email)
VALUES ('ООО "ТехМир"', 'Владимир Руденко', '84956667788', 'info@techmir.ru');

-- 2. Добавление нового заказа сотрудником
INSERT INTO "order" (employee_id, order_date)
SELECT employee_id, CURRENT_DATE
FROM employee
WHERE email = 'petr.kuznetsov@company.ru';

-- 3. Обновление статуса оборудования после ремонта
UPDATE equipment
SET status = 'Ready to use'
WHERE status = 'Need repair';

-- 4. Списываем оборудование
DELETE FROM equipment
WHERE status = 'Subject to disposal';

-- 5. Обновление количества оборудования после перемещения
UPDATE warehouse_equipment
SET quantity = quantity - 2
WHERE warehouse_id = (
    SELECT from_warehouse_id
    FROM equipment_movement
    WHERE equipment_id = 1
    ORDER BY movement_date DESC
    LIMIT 1
);
```

### Пояснения к модифицирующим запросам:
Добавляет нового поставщика для работы с оборудованием.
Создаёт заказ для конкретного сотрудника.
Обновляет статус оборудования на готовое после ремонта.
Удаляет оборудование, подлежащее списанию (нужно осторожно с внешними ключами).
Корректирует количество оборудования на складе после перемещения.

## 3. Представления
```sql
-- 1. Обычное представление
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

-- 2. Материализованное представление
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
```

### Пояснения к представлениям:
- view_equipment_details: обычное представление, позволяет видеть оборудование, его тип, поставщика, статус и количество на складах. Данные всегда актуальны.
- mv_warehouse_statistics: материализованное представление для быстрого просмотра сводной информации по складам. Обновляется командой REFRESH MATERIALIZED VIEW.

## 4. Ответы на вопросы
<ol>
<li> Потенциальные риски при некорректном DELETE или UPDATE без WHERE:
<ul><li>Можно случайно удалить или изменить все записи в таблице.</li>
<li>Потеря важных данных или нарушение связей через внешние ключи.</li>
<li>Трудно восстановить без резервной копии.</li>
</ul></li>
<li>Почему важно не использовать * в запросах
<ul>
<li>Получаем все колонки, даже ненужные → повышается нагрузка на сеть и память.</li>
<li>Неочевидно, какие данные реально используются, что усложняет поддержку и может быть небезопасно.</li>
</ul></li><li>Проблемы при параллельном выполнении запросов:
<ul>
    <li>Возможны конфликты при изменении одних и тех же данных (update/delete).</li>
    <li>Может возникнуть неактуальная информация из-за блокировок и транзакций.</li>
    <li>Нужно правильно настраивать транзакции и уровни изоляции, чтобы избежать потери данных.</li>
</ul>
</li>
</ol>
