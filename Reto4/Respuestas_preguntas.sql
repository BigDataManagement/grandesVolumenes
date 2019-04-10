-- 1 
SELECT a.time_ids, a.cantidad_rentas, r.customer_id
FROM
	(SELECT DATE_FORMAT(DATE(r.time_id),'%Y%m') AS time_ids,MAX(r.cantidad_rentas_mes_usuario) AS cantidad_rentas
	FROM sakila_olap.rental_fact r
	GROUP BY time_ids) a
JOIN sakila_olap.rental_fact r ON r.cantidad_rentas_mes_usuario = a.cantidad_rentas AND a.time_ids = DATE_FORMAT(DATE(r.time_id),'%Y%m')
GROUP BY time_ids, cantidad_rentas, customer_id;

-- 2
SELECT f.category_name ,COUNT(f.category_id), DATE_FORMAT(DATE(r.time_id),'%Y') as year, DATE_FORMAT(DATE(r.time_id),'%m') AS month
FROM sakila_olap.rental_fact r
JOIN sakila_olap.film_dimension f ON f.film_id = r.film_id
GROUP BY f.category_name, year, month
HAVING month = '06';
-- 3
SELECT a.film_id, a.rental_rate,SUM(a.cantidad_rentas_pelicula_year) AS total_sales
FROM
 (SELECT r.film_id, f.rental_rate, r.cantidad_rentas_pelicula_year
 FROM sakila_olap.rental_fact r
 JOIN sakila_olap.film_dimension f ON f.film_id = r.film_id
 GROUP BY  r.film_id, f.rental_rate, r.cantidad_rentas_pelicula_year) a
GROUP BY film_id, rental_rate
ORDER BY total_sales DESC
LIMIT 10;

-- 4
SELECT a.film_id, a.rental_rate,SUM(a.cantidad_rentas_pelicula_year) AS total_sales
FROM
 (SELECT r.film_id, f.rental_rate, r.cantidad_rentas_pelicula_year
 FROM sakila_olap.rental_fact r
 JOIN sakila_olap.film_dimension f ON f.film_id = r.film_id
 GROUP BY  r.film_id, f.rental_rate, r.cantidad_rentas_pelicula_year) a
GROUP BY film_id, rental_rate
ORDER BY total_sales ASC
LIMIT 10;

 -- 5
SELECT DATE_FORMAT(DATE(r.time_id),'%Y%m%d'), a.cantidad_dia
FROM
	(SELECT DATE_FORMAT(DATE(r.time_id),'%Y%m'), MIN(r.cantidad_rentas_dia) AS cantidad_dia
	FROM sakila_olap.rental_fact r
	GROUP BY DATE_FORMAT(DATE(time_id),'%Y%m'))a
JOIN sakila_olap.rental_fact r ON r.cantidad_rentas_dia = a.cantidad_dia
GROUP BY DATE_FORMAT(DATE(r.time_id),'%Y%m%d'), a.cantidad_dia;

-- 6
SELECT  r.film_id, a.peliculas_mes, a.pais
FROM
	(SELECT MAX(r.cantidad_rentas_pelicula_pais_mes) AS peliculas_mes, l.country_name AS pais
	FROM sakila_olap.rental_fact r
	JOIN sakila_olap.location_dimension l ON r.location_id = l.location_id
	WHERE DATE_FORMAT(DATE(r.time_id),'%Y%m') = "200506"
	GROUP BY country_name) a
LEFT JOIN sakila_olap.rental_fact r ON r.cantidad_rentas_pelicula_pais_mes = a.peliculas_mes
GROUP BY peliculas_mes, film_id, pais
ORDER BY pais;

-- 7

-- 8
SELECT DISTINCT c.customer_i, c.rentas_mes, DATE_FORMAT(DATE(r.time_id),'%Y%m') AS fecha
FROM
    (SELECT r.customer_id customer_i, MIN(r.cantidad_rentas_mes_usuario) AS rentas_mes
	FROM
		(SELECT r.customer_id customer_ids, a.cantidad_rentas AS rentas
		FROM
			(SELECT MAX(r.cantidad_rentas_mes_usuario) AS cantidad_rentas, DATE_FORMAT(DATE(r.time_id),'%Y%m')
			FROM sakila_olap.rental_fact r
			GROUP BY DATE_FORMAT(DATE(r.time_id),'%Y%m')) a
		JOIN sakila_olap.rental_fact r ON a.cantidad_rentas = r.cantidad_rentas_mes_usuario
		GROUP BY customer_id, cantidad_rentas
		ORDER BY cantidad_rentas DESC
		LIMIT 10) top_10
	JOIN sakila_olap.rental_fact r ON top_10.customer_ids = r.customer_id
	GROUP BY r.customer_id) c
JOIN sakila_olap.rental_fact r ON c.customer_i = r.customer_id
WHERE c.rentas_mes = r.cantidad_rentas_mes_usuario;

-- 9
SELECT category_ids, customer_ids FROM (
SELECT c.customer_ids AS usuario, MAX(c.contador_category) as maximo
FROM 
	(SELECT b.customer_id customer_ids, COUNT(f.category_id) AS contador_category, f.category_id category_ids
	FROM 
		(SELECT *
		FROM sakila_olap.rental_fact r 
		WHERE r.customer_id IN (
			SELECT a.customer_id FROM (
				SELECT r.customer_id, COUNT(r.customer_id) AS total_ventas_usuario
				FROM sakila_olap.rental_fact r
				GROUP BY r.customer_id
				ORDER BY total_ventas_usuario DESC
				LIMIT 10) a
			)
		) b
	JOIN sakila_olap.film_dimension f ON b.film_id = f.film_id
	GROUP BY b.customer_id, f.category_id
    ORDER BY contador_category desc) c
GROUP BY usuario ) a 
JOIN (SELECT b.customer_id customer_ids, COUNT(f.category_id) AS contador_category, f.category_id category_ids
	FROM 
		(SELECT *
		FROM sakila_olap.rental_fact r 
		WHERE r.customer_id IN (
			SELECT a.customer_id FROM (
				SELECT r.customer_id, COUNT(r.customer_id) AS total_ventas_usuario
				FROM sakila_olap.rental_fact r
				GROUP BY r.customer_id
				ORDER BY total_ventas_usuario DESC
				LIMIT 10) a
			)
		) b
	JOIN sakila_olap.film_dimension f ON b.film_id = f.film_id
	GROUP BY b.customer_id, f.category_id
    ORDER BY contador_category desc) b
ON a.usuario = b.customer_ids 
WHERE maximo = contador_category;

	

-- 10
SELECT COUNT(r.rental_id) AS total_ventas, r.store_id
FROM sakila_olap.rental_fact r
JOIN sakila_olap.store_dimension s ON r.store_id = s.store_id
WHERE DATE_FORMAT(DATE(r.time_id),'%Y') = "2006"
GROUP BY r.store_id
ORDER BY total_ventas DESC
LIMIT 1;

-- 11a
SELECT r.customer_id, avg(r.cantidad_rentas_mes_usuario)
FROM sakila_olap.rental_fact r
GROUP BY r.customer_id;

-- 11b
SELECT DISTINCT c.customer_i, c.rentas_mes, DATE_FORMAT(DATE(r.time_id),'%Y%m') AS fecha
FROM
    (SELECT r.customer_id customer_i, MAX(r.cantidad_rentas_mes_usuario) AS rentas_mes
	FROM
		(SELECT r.customer_id customer_ids, a.cantidad_rentas AS rentas
			FROM
				(SELECT MAX(r.cantidad_rentas_mes_usuario) AS cantidad_rentas, DATE_FORMAT(DATE(r.time_id),'%Y%m')
				FROM sakila_olap.rental_fact r
				GROUP BY DATE_FORMAT(DATE(r.time_id),'%Y%m')) a
			JOIN sakila_olap.rental_fact r ON a.cantidad_rentas = r.cantidad_rentas_mes_usuario
			GROUP BY customer_id, cantidad_rentas
			ORDER BY cantidad_rentas DESC
			LIMIT 10) top_10
	JOIN sakila_olap.rental_fact r ON top_10.customer_ids = r.customer_id
	GROUP BY r.customer_id) c
JOIN sakila_olap.rental_fact r ON c.customer_i = r.customer_id
WHERE c.rentas_mes = r.cantidad_rentas_mes_usuario;
