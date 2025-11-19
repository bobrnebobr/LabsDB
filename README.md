# 3 Лабораторная

## 1. Анализ SELECT-запросов и выбор индексов

### Запросы из ЛР 2
```sql
-- 1. Последние готовые к использованию единицы оборудования
SELECT equipment_id, name, purchase_date, status
FROM equipment
WHERE status = 'Ready to use'
ORDER BY purchase_date DESC
LIMIT 5;

-- 2. Общее количество оборудования по типам
SELECT et.type_name, SUM(we.quantity) AS total_count
FROM warehouse_equipment we
JOIN equipment e ON we.equipment_id = e.equipment_id
JOIN equipment_type et ON e.type_id = et.type_id
GROUP BY et.type_name
ORDER BY total_count DESC;

-- 3. Склады с большим количеством оборудования
SELECT w.name, SUM(we.quantity) AS total_count
FROM warehouse_equipment we
JOIN warehouse w ON we.warehouse_id = w.warehouse_id
GROUP BY w.name
HAVING SUM(we.quantity) > 10
ORDER BY total_count DESC;

-- 4. Сотрудники, обслуживавшие компрессоры
SELECT DISTINCT e.first_name, e.last_name
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
    SELECT equipment_id, name, purchase_date, warranty_end
    FROM equipment
    WHERE warranty_end < CURRENT_DATE
)
SELECT * FROM expired
ORDER BY purchase_date;
```

### Используемые поля

* status, purchase_date - фильтр и сортировка
* equipment_id, warehouse_id, type_id - связи между таблицами
* type_name - поиск по имени типа
* warranty_end - поиск по дате

## 2. Созданные индексы

```sql
-- 1. Для фильтра + сортировки
CREATE INDEX idx_equipment_status_purchase
ON equipment(status, purchase_date);

-- 2. Для JOIN по складу/оборудованию
CREATE INDEX idx_we_equipment
ON warehouse_equipment(equipment_id);

CREATE INDEX idx_we_warehouse
ON warehouse_equipment(warehouse_id);

-- 3. Для поиска типа оборудования
CREATE INDEX idx_equipment_type_name
ON equipment_type(type_name);

-- 4. Для запросов по maintenance
CREATE INDEX idx_maintenance_employee
ON maintenance(employee_id);

CREATE INDEX idx_maintenance_equipment
ON maintenance(equipment_id);

-- 5. Для поиска оборудования с истекшей гарантией
CREATE INDEX idx_equipment_warranty_end
ON equipment(warranty_end);
```

### Краткое обоснование

* B-tree подходит почти для всех условий =, <, ORDER BY
* Индексы ускоряют фильтрацию, связи таблиц и поиск по дате/типу


## 3. Влияние индексов на операции INSERT / UPDATE / DELETE

* INSERT - немного медленнее, т.к. индекс тоже обновляется
* UPDATE - замедляется только если изменяется поле, входящее в индекс
* DELETE - требуется удалить строку и в индексе, что тоже немного замедляет

Индексы не мешают обычным модификациям и полезны для чтения

## 4. Ответы на вопросы

**1. Почему не стоит создавать индекс на каждый столбец?**

Индексы занимают место и замедляют вставки/обновлении

**2. Когда индекс может ухудшить работу?**

При частых изменениях данных - из-за постоянного пересчёта индекса

**3. Что такое селективность?**

Это доля уникальных значений. Чем селективнее столбец - тем полезнее индекс

**4. Что такое кардинальность?**

Количество уникальных значений

Высокая кардинальность => индекс эффективен, низкая => почти бесполезен
