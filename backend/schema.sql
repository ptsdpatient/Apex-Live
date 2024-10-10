DROP TABLE IF EXISTS streams CASCADE;
DROP TABLE IF EXISTS cameras CASCADE;
DROP TABLE IF EXISTS polling_stations CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS taluka CASCADE;

CREATE TABLE taluka(
    id SERIAL PRIMARY KEY,
    taluka TEXT
);

CREATE TABLE employees(
    id SERIAL PRIMARY KEY,
    full_name TEXT,
    pass TEXT,
    is_admin INTEGER,
    phone_number TEXT
);

CREATE TABLE polling_stations(
    id SERIAL PRIMARY KEY,
    polling_station TEXT,
    polling_address TEXT,
    taluka INTEGER,
    operator INTEGER,
    FOREIGN KEY (operator) REFERENCES employees(id) ON DELETE SET NULL,
    FOREIGN KEY(taluka) REFERENCES taluka(id)
);

CREATE TABLE cameras (
    id SERIAL PRIMARY KEY,
    PS INTEGER ,
    FOREIGN KEY (PS) REFERENCES polling_stations(id) ON DELETE SET NULL,
    serial_number TEXT UNIQUE,
    sent_at TEXT,
    removed_at TEXT,
    is_active BOOLEAN
);

CREATE TABLE streams(
    id SERIAL PRIMARY KEY,
    camera INTEGER,
    FOREIGN KEY(camera) REFERENCES cameras(id),
    start_time TEXT,
    end_time TEXT
);