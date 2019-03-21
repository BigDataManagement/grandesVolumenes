/*  
FUNCIONES DE AGREGACIÓN Y AGRUPACIÓN
Las funciones de agregación son COUNT, MAX, MIN, SUM y AVG. 
Estas funciones a excepción del count solo aplican para campos númericos.
Por esto todos los ejemplos de agregación a continuación son usando el campo gini y population.
La función de agrupación es GROUP BY y la función HAVING es una especie de where. 
A continuación también hay algunos ejemplos de estas
*/
-- Agrupa y cuenta el número de paises agrupados por su indice de desigualdad.
SELECT count(*) countries_number,
 CASE
    WHEN gini >= 24 AND gini<=40 THEN "poca desigualdad"
    WHEN gini >= 40 AND gini<=50 THEN "desigualdad media"
    WHEN gini >= 50 AND gini<=66 THEN "mucha desigualdad"
    ELSE "no tienen indice gini"
END AS gini_group FROM SAKILA.COUNTRY_EXT2 GROUP BY gini_group;
-- Promedio de desigualdad en todos los paises.
SELECT AVG(gini) average_gini FROM sakila.country_ext2;
-- Paises de habla hispana.
SELECT name FROM sakila.country_ext2 WHERE languages LIKE "%spa%";
-- Promedio de desigualdad en paises con habla hispana
SELECT AVG(gini) average_gini FROM sakila.country_ext2 WHERE languages LIKE "%spa%";
-- Pais con menor indice de desigualdad
SELECT name, MIN(gini) FROM sakila.country_ext2;
-- Pais con mayor indice de desigualdad
SELECT name, MAX(gini) FROM sakila.country_ext2;
-- Población en america del sur
SELECT SUM(population) population_in_SA FROM sakila.country_ext2 WHERE subregion IN ('South America');
-- Población por sub región del mundo
SELECT SUM(population) population, subregion FROM sakila.country_ext2 GROUP BY subregion;
-- Sub regiones del mundo con más de 500 millones de habitantes.
SELECT subregion FROM sakila.country_ext2 GROUP BY subregion having SUM(population) > 500000000;

/*  
 VISTAS
las funciones de agregación son COUNT, MAX, MIN, SUM y AVG. 
Estas funciones a excepción del count solo aplican para campos númericos.
Por esto todos los ejemplos a continuación son usando el campo gini y population.
*/

-- Ventas por región.
CREATE VIEW SAKILA.V_REGION_SALES
AS SELECT country_ext2.region REGION, SUM(payment.amount) SALES
FROM sakila.country_ext2 
JOIN sakila.city ON city.country_id = country_ext2.country_id
JOIN sakila.address ON address.city_id = city.city_id
JOIN sakila.customer ON customer.address_id = address.address_id
JOIN sakila.payment ON payment.customer_id = customer.customer_id
GROUP BY country_ext2.name 
ORDER BY sales desc;

-- Ventas por país.
CREATE VIEW SAKILA.V_COUNTRY_SALES
AS SELECT country_ext2.name , SUM(payment.amount) SALES
FROM sakila.country_ext2 
JOIN sakila.city ON city.country_id = country_ext2.country_id
JOIN sakila.address ON address.city_id = city.city_id
JOIN sakila.customer ON customer.address_id = address.address_id
JOIN sakila.payment ON payment.customer_id = customer.customer_id
GROUP BY country_ext2.name 
ORDER BY sales desc;

-- Ventas por ciudad.
CREATE VIEW SAKILA.V_SALES_PER_CITY_AND_COUNTRY AS 
SELECT   name as country
		,  city.city
		, SUM(payment.amount) sales 
FROM sakila.country_ext2 
JOIN sakila.city ON city.country_id = country_ext2.country_id
JOIN sakila.address ON address.city_id = city.city_id
JOIN sakila.customer ON customer.address_id = address.address_id
JOIN sakila.payment ON payment.customer_id = customer.customer_id
GROUP BY country_ext2.name , city.city;

-- Ciudades que venden más que el promedio con cantidad de ventas.
CREATE VIEW SAKILA.V_CITY_GT_AVERAGE AS SELECT   name as country
		,  city.city
		, SUM(payment.amount) sales 
FROM sakila.country_ext2 
JOIN sakila.city ON city.country_id = country_ext2.country_id
JOIN sakila.address ON address.city_id = city.city_id
JOIN sakila.customer ON customer.address_id = address.address_id
JOIN sakila.payment ON payment.customer_id = customer.customer_id
GROUP BY country_ext2.name , city.city
HAVING sales > (SELECT AVG(a.sales) FROM (SELECT   name as pais
		,  city.city
		, SUM(payment.amount) sales 
FROM sakila.country_ext2 
JOIN sakila.city ON city.country_id = country_ext2.country_id
JOIN sakila.address ON address.city_id = city.city_id
JOIN sakila.customer ON customer.address_id = address.address_id
JOIN sakila.payment ON payment.customer_id = customer.customer_id
GROUP BY country_ext2.name , city.city) a)
ORDER BY country, sales desc;

-- Ciudades agrupadas por país que venden más que el promedio.
CREATE VIEW SAKILA.V_CITY_SALES_GT_AVERAGE_GROUPED
AS 
SELECT sales_per_city_and_country_more_than_average.country, GROUP_CONCAT(sales_per_city_and_country_more_than_average.city) 
FROM (SELECT   name as country
		,  city.city
		, SUM(payment.amount) sales 
FROM sakila.country_ext2 
JOIN sakila.city ON city.country_id = country_ext2.country_id
JOIN sakila.address ON address.city_id = city.city_id
JOIN sakila.customer ON customer.address_id = address.address_id
JOIN sakila.payment ON payment.customer_id = customer.customer_id
GROUP BY country_ext2.name , city.city
HAVING sales > (SELECT AVG(a.sales) FROM (SELECT   name as pais
		,  city.city
		, SUM(payment.amount) sales 
FROM sakila.country_ext2 
JOIN sakila.city ON city.country_id = country_ext2.country_id
JOIN sakila.address ON address.city_id = city.city_id
JOIN sakila.customer ON customer.address_id = address.address_id
JOIN sakila.payment ON payment.customer_id = customer.customer_id
GROUP BY country_ext2.name , city.city) a)
ORDER BY country, sales desc) sales_per_city_and_country_more_than_average
GROUP BY country;



