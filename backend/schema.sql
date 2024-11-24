DROP TABLE IF EXISTS streams CASCADE;
DROP TABLE IF EXISTS cameras CASCADE;
DROP TABLE IF EXISTS polling_stations CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS taluka CASCADE;
DROP TABLE IF EXISTS constituencies CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS visible CASCADE;
DROP TABLE IF EXISTS category CASCADE;
DROP TABLE IF EXISTS status_type CASCADE;
DROP TABLE IF EXISTS graph CASCADE;

CREATE TABLE taluka(
    id SERIAL PRIMARY KEY,
    taluka VARCHAR(60)
);

CREATE TABLE constituencies(
    id SERIAL PRIMARY KEY,
    ac_number VARCHAR,
    ac_name VARCHAR,
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
    created_at VARCHAR,
    FOREIGN KEY (PS) REFERENCES polling_stations(id) ON DELETE SET NULL,
    serial_number TEXT UNIQUE,
    is_online BOOLEAN DEFAULT FALSE,
    is_inactive BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (operator) REFERENCES employees(id)
);


CREATE TABLE status_type(
    id SERIAL PRIMARY KEY,
    status_name VARCHAR
);

CREATE TABLE category(
    id SERIAL PRIMARY KEY,
    category VARCHAR
);

CREATE TABLE users(
    id SERIAL PRIMARY KEY,
    is_admin BOOLEAN DEFAULT FALSE,
    username VARCHAR,
    user_limit INTEGER,    
    pass VARCHAR
);

CREATE TABLE graph(
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    FOREIGN KEY (user_id) REFERENCES users(id),
    status_online BOOLEAN DEFAULT FALSE,
    status_inactive BOOLEAN DEFAULT FALSE,
    status_offline BOOLEAN DEFAULT TRUE,  
    log_time VARCHAR(25)
);


CREATE TABLE visible(
    id SERIAL PRIMARY KEY,
    ps_only BOOLEAN DEFAULT FALSE,
    ps INTEGER,
    FOREIGN KEY (ps) REFERENCES  polling_stations(id),
    ac INTEGER,
    FOREIGN KEY (ac) REFERENCES  constituencies(id)
);