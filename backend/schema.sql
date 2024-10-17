DROP TABLE IF EXISTS streams CASCADE;
DROP TABLE IF EXISTS cameras CASCADE;
DROP TABLE IF EXISTS polling_stations CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS taluka CASCADE;
DROP TABLE IF EXISTS constituencies CASCADE;

CREATE TABLE taluka(
    id SERIAL PRIMARY KEY,
    taluka TEXT
);

CREATE TABLE constituencies(
    id SERIAL PRIMARY KEY,
    ac_number TEXT,
    ac_name TEXT,
    taluka INTEGER,
    FOREIGN KEY (taluka) REFERENCES taluka(id)
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
    constituency INTEGER,
    polling_station_name TEXT,
    polling_address TEXT,
    operator INTEGER,
    FOREIGN KEY (constituency) REFERENCES constituencies(id),
    FOREIGN KEY (operator) REFERENCES employees(id) ON DELETE SET NULL
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