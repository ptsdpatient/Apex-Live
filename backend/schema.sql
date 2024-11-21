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
    phone_number TEXT
);

CREATE TABLE polling_stations(
    id SERIAL PRIMARY KEY,
    constituency INTEGER,
    pid VARCHAR,
    polling_station_name TEXT,
    polling_address TEXT,
    supervisor INTEGER,
    FOREIGN KEY (constituency) REFERENCES constituencies(id),
    FOREIGN KEY (supervisor) REFERENCES employees(id) ON DELETE SET NULL
);

CREATE TABLE cameras (
    id SERIAL PRIMARY KEY,
    operator INTEGER,
    PS INTEGER,
    category VARCHAR,
    created_at TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (PS) REFERENCES polling_stations(id) ON DELETE SET NULL,
    serial_number TEXT UNIQUE,
    sent_at TEXT,
    is_online INTEGER,
    removed_at TEXT,
    is_active BOOLEAN,
    FOREIGN KEY (operator) REFERENCES employees(id)
);

CREATE TABLE statistics(
    id SERIAL PRIMARY KEY,
    status_total INTEGER,
    status_online INTEGER,
    status_offline INTEGER,  
    log_time VARCHAR(25)
);

CREATE TABLE visible(
    id SERIAL PRIMARY KEY,
    ps_only INTEGER,
    ps INTEGER,
    FOREIGN KEY (ps_only) REFERENCES  polling_stations(id),
    taluka INTEGER,
    FOREIGN KEY (taluka) REFERENCES  taluka(id)
);