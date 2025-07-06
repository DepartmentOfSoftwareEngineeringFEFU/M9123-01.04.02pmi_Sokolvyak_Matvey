-- Создание пользователей и ролей
CREATE USER admin WITH SUPERUSER PASSWORD '12345';
CREATE USER normal_user CONNECTION LIMIT 5;
CREATE ROLE mute_user WITH NOLOGIN;
CREATE ROLE banned_user WITH NOLOGIN;  -- Исправлено опечатку baned -> banned
    
-- Создание базы данных
CREATE DATABASE cars_data;

-- Подключение к базе данных
\c cars_data

-- Создание таблиц
CREATE TABLE concern (
    concern_name VARCHAR(50) PRIMARY KEY,
    concern_country VARCHAR(50)
);

CREATE TABLE transmission (
    trms_model SERIAL PRIMARY KEY, 
    trms_type VARCHAR(50) NOT NULL, 
    trms_steps INTEGER
);
        
CREATE TABLE engine ( 
    engine_id SERIAL PRIMARY KEY, 
    engine_fuel VARCHAR(50), 
    engine_capacity real
);

CREATE TABLE cars ( 
    car_model VARCHAR(50) PRIMARY KEY, 
    car_mark VARCHAR(50) NOT NULL UNIQUE, 
    car_transmission INTEGER, 
    car_engine INTEGER,
    car_release_year INTEGER, 
    CONSTRAINT car_mark_fk FOREIGN KEY (car_mark) REFERENCES concern (concern_name), 
    CONSTRAINT car_transmission_fk FOREIGN KEY (car_transmission) REFERENCES transmission (trms_model), 
    CONSTRAINT car_engine_fk FOREIGN KEY (car_engine) REFERENCES engine (engine_id)
);

-- Заполнение таблицы concern (исправлены кавычки и убраны лишние пробелы)
INSERT INTO concern (concern_name, concern_country) VALUES ('Lada', 'Russia');
INSERT INTO concern (concern_name, concern_country)VALUES ('Toyota', 'Japan');
INSERT INTO concern (concern_name, concern_country) VALUES ('Suzuki', 'Japan');
INSERT INTO concern (concern_name, concern_country) VALUES ('Honda', 'Japan');
INSERT INTO concern (concern_name, concern_country) VALUES ('Ford', 'USA');
INSERT INTO concern (concern_name, concern_country) VALUES ('Jeep', 'USA');

-- Заполнение таблицы transmission (исправлена синтаксическая ошибка)
INSERT INTO transmission (trms_type, trms_steps) VALUES ('Mechanic', 4);
INSERT INTO transmission (trms_type, trms_steps) VALUES ('Mechanic', 5);
INSERT INTO transmission (trms_type, trms_steps) VALUES ('Mechanic', 6);
INSERT INTO transmission (trms_type, trms_steps) VALUES ('Mechanic', 7);
INSERT INTO transmission (trms_type, trms_steps) VALUES ('Automatic', 5);
INSERT INTO transmission (trms_type, trms_steps) VALUES ('Automatic', 6);
INSERT INTO transmission (trms_type, trms_steps) VALUES ('Automatic', 7);
    
-- Заполнение таблицы engine
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Gasoline', 1.0);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Gasoline', 1.5);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Gasoline', 2.0);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Gasoline', 3.0);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Gasoline', 3.5);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Diesel', 2.0);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Diesel', 3.0);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Diesel', 4.0);
INSERT INTO engine (engine_fuel, engine_capacity) VALUES ('Diesel', 5.0);

-- Заполнение таблицы cars (исправлены лишние пробелы в значениях)
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Niva', 'Lada', 2, 2, 1977);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Priora', 'Lada', 2, 2, 2009);  -- Исправлено 'Priora ' на 'Lada'
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Corolla e90', 'Toyota', 1, 2, 1992);  -- Удален лишний пробел
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Camry xv10', 'Toyota', 1, 4, 1993);  -- Удален лишний пробел
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('RAV4', 'Toyota', 2, 3, 1999);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Hilux', 'Toyota', 3, 7, 2015);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Swift', 'Suzuki', 2, 1, 2005);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('SX4', 'Suzuki', 5, 6, 2012);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Jimny', 'Suzuki', 3, 2, 2020);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Civic', 'Honda', 3, 3, 2019);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Accord', 'Honda', 5, 5, 2022);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Focus', 'Ford', 2, 2, 2018);
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Mustang 5', 'Ford', 7, 7, 2023);  -- Удален лишний пробел
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Cherokee', 'Jeep', 4, 7, 2024);  -- Удален лишний пробел
INSERT INTO cars (car_model, car_mark, car_transmission, car_engine, car_release_year) VALUES ('Wrangler', 'Jeep', 5, 8, 2025);  -- Удален лишний пробел
