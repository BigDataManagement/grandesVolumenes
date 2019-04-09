DROP DATABASE IF EXISTS sakila_olap;
CREATE DATABASE sakila_olap;

DROP TABLE IF EXISTS sakila_olap.time_dimension;
CREATE TABLE sakila_olap.time_dimension (
time_id                 INTEGER PRIMARY KEY,  -- year*10000+month*100+day
db_date                 DATE NOT NULL,
year                    INTEGER NOT NULL,
month                   INTEGER NOT NULL, -- 1 to 12
day                     INTEGER NOT NULL, -- 1 to 31
quarter                 INTEGER NOT NULL, -- 1 to 4
week                    INTEGER NOT NULL, -- 1 to 52/53
day_name                VARCHAR(9) NOT NULL, -- 'Monday', 'Tuesday'...
month_name              VARCHAR(9) NOT NULL, -- 'January', 'February'...
holiday_flag            CHAR(1) DEFAULT 'f',
weekend_flag            CHAR(1) DEFAULT 'f',
event                   VARCHAR(50),
UNIQUE td_ymd_idx (year,month,day),
UNIQUE td_dbdate_idx (db_date)
);

DROP TABLE IF EXISTS sakila_olap.customer_dimension;
CREATE TABLE sakila_olap.customer_dimension(
customer_id SMALLINT UNSIGNED NOT NULL,
first_name VARCHAR(45) NOT NULL,
last_name VARCHAR(45) NOT NULL,
email VARCHAR(50),
PRIMARY KEY  (customer_id)
);

DROP TABLE IF EXISTS sakila_olap.store_dimension;
CREATE TABLE sakila_olap.store_dimension(
store_id SMALLINT UNSIGNED NOT NULL,
PRIMARY KEY  (store_id)
);

DROP TABLE IF EXISTS sakila_olap.film_dimension;
CREATE TABLE sakila_olap.film_dimension (
film_id smallint(5) unsigned NOT NULL AUTO_INCREMENT,
title varchar(255) NOT NULL,
rental_rate decimal(4,2) NOT NULL DEFAULT '4.99',
PRIMARY KEY (film_id)
);

DROP TABLE IF EXISTS sakila_olap.location_dimension;
CREATE TABLE sakila_olap.location_dimension (
location_id SMALLINT(5) NOT NULL, -- City_id
city_name VARCHAR(50) NOT NULL,
country_name VARCHAR(50) NOT NULL,
PRIMARY KEY (location_id)
);

DROP TABLE IF EXISTS sakila_olap.rental_fact;
CREATE TABLE sakila_olap.rental_fact(
rental_id INT NOT NULL AUTO_INCREMENT,
film_id SMALLINT(5) unsigned NOT NULL,
customer_id SMALLINT UNSIGNED NOT NULL,
store_id SMALLINT(5) UNSIGNED NOT NULL,
time_id INT(11) NOT NULL,
location_id SMALLINT NOT NULL,
cantidad_rentas_dia SMALLINT NOT NULL,
cantidad_rentas_dia_usuario SMALLINT,
cantidad_rentas_mes_usuario SMALLINT,
cantidad_rentas_mes_genero SMALLINT,
cantidad_rentas_pelicula_year SMALLINT,
cantidad_rentas_pelicula_pais_mes SMALLINT,
PRIMARY KEY  (rental_id),
KEY idx_fk_customer_id (customer_id),
KEY idx_fk_store_id (store_id),
KEY idx_fk_time_id (time_id),
KEY idx_fk_film_id (film_id),
KEY idx_fk_location_id (location_id),
CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES sakila_olap.customer_dimension (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT fk_rental_time FOREIGN KEY (time_id) REFERENCES sakila_olap.time_dimension (time_id) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT fk_rental_store FOREIGN KEY (store_id) REFERENCES sakila_olap.store_dimension (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT fk_rental_film FOREIGN KEY (film_id) REFERENCES sakila_olap.film_dimension (film_id) ON DELETE RESTRICT ON UPDATE CASCADE,
CONSTRAINT fk_rental_location FOREIGN KEY (location_id) REFERENCES sakila_olap.location_dimension (location_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

DROP PROCEDURE IF EXISTS sakila_olap.fill_date_dimension;
DELIMITER //
CREATE PROCEDURE sakila_olap.fill_date_dimension(IN startdate DATE,IN stopdate DATE) 
BEGIN
    DECLARE currentdate DATE;
    SET currentdate = startdate;
    WHILE currentdate < stopdate DO
        INSERT INTO time_dimension VALUES (
                        YEAR(currentdate)*10000+MONTH(currentdate)*100 + DAY(currentdate),
                        currentdate,
                        YEAR(currentdate),
                        MONTH(currentdate),
                        DAY(currentdate),
                        QUARTER(currentdate),
                        WEEKOFYEAR(currentdate),
                        DATE_FORMAT(currentdate,'%W'),
                        DATE_FORMAT(currentdate,'%M'),
                        'f',
                        CASE DAYOFWEEK(currentdate) WHEN 1 THEN 't' WHEN 7 then 't' ELSE 'f' END,
                        NULL);
        SET currentdate = ADDDATE(currentdate,INTERVAL 1 DAY);
    END WHILE;
END
//
DELIMITER ;

CALL sakila_olap.fill_date_dimension('2000-01-01','2020-12-31');
OPTIMIZE TABLE sakila_olap.time_dimension;

UPDATE sakila_olap.time_dimension SET `week` = '1' WHERE (`time_id` = '20000101');
UPDATE sakila_olap.time_dimension SET `week` = '1' WHERE (`time_id` = '20000102');