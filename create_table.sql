CREATE TYPE type_sex AS ENUM ('Male', 'Female');

CREATE TYPE type_equipment_status AS ENUM ('Ready to use', 'Need repair', 'Subject to disposal', 'Lost');

CREATE TYPE equipment_maintenance_type AS ENUM ('Scheduled inspection', 'Repair', 'Inspection');
CREATE TABLE IF NOT EXISTS position (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS employee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(50) UNIQUE,
    sex type_sex,
    position_id INT NOT NULL REFERENCES position(position_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS warehouse (
    warehouse_id SERIAL PRIMARY KEY,
    location VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL
);

CREATE TABLE IF NOT EXISTS supplier (
    supplier_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    contact_name VARCHAR(100),
    phone_number VARCHAR(20),
    email VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS equipment_type (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS equipment (
    equipment_id SERIAL PRIMARY KEY,
    type_id INT NOT NULL REFERENCES equipment_type(type_id) ON DELETE CASCADE,
    supplier_id INT REFERENCES supplier(supplier_id) ON DELETE CASCADE,
    purchase_date DATE NOT NULL,
    warranty_end DATE,
    status type_equipment_status NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

CREATE TABLE IF NOT EXISTS "order" (
    order_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employee(employee_id) ON DELETE CASCADE,
    order_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS order_equipment (
    order_id INT NOT NULL REFERENCES "order"(order_id) ON DELETE CASCADE,
    equipment_id INT NOT NULL REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK(quantity > 0),
    PRIMARY KEY (order_id, equipment_id)
);

CREATE TABLE IF NOT EXISTS warehouse_equipment (
    warehouse_equipment_id SERIAL PRIMARY KEY,
    warehouse_id INT NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    equipment_id INT NOT NULL REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0),
    UNIQUE (warehouse_id, equipment_id)
);

CREATE TABLE IF NOT EXISTS maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    equipment_id INT NOT NULL REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    employee_id INT NOT NULL REFERENCES employee(employee_id) ON DELETE CASCADE,
    maintenance_type equipment_maintenance_type NOT NULL,
    maintenance_date DATE,
    description TEXT
);

CREATE TABLE IF NOT EXISTS equipment_movement (
    movement_id SERIAL PRIMARY KEY,
    equipment_id INT NOT NULL REFERENCES equipment(equipment_id) ON DELETE CASCADE,
    from_warehouse_id INT NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    to_warehouse_id INT NOT NULL REFERENCES warehouse(warehouse_id) ON DELETE CASCADE,
    movement_date DATE NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0)
);
