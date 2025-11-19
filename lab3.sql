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