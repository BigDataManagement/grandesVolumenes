INSERT INTO sakila_olap.rental_fact (rental_id,film_id,customer_id,store_id,time_id,location_id,cantidad_rentas_dia,cantidad_rentas_dia_usuario,cantidad_rentas_mes_usuario,cantidad_rentas_pelicula_year,cantidad_rentas_pelicula_pais_mes)
SELECT basic.rental_id, basic.film_id, basic.customer_id, basic.store_id, basic.time_id, basic.city_id, cant_dia.cantidad_rentas_dia, cant_dia_usuario.cantidad_rentas_dia_usuario, cant_mes_usuario.cantidad_rentas_mes_usuario, cant_ano_pelicula.cantidad_rentas_peliculas_ano, cant_mes_pelicula_pais.cantidad_rentas_peliculas_mes_pais
FROM (
-- rental basic DF
	SELECT r.rental_id, f.film_id, r.customer_id, s.store_id, city.city_id, t.time_id, co.country
	FROM sakila.rental r 
	JOIN sakila.inventory i on r.inventory_id = i. inventory_id 
	JOIN sakila.film f ON i.film_id = f.film_id 
	JOIN sakila.store s ON i.store_id = s.store_id 
	JOIN sakila.address ON s.address_id = address.address_id 
	JOIN sakila.city ON address.city_id = city.city_id 
    JOIN sakila.country co ON city.country_id = co.country_id
	JOIN sakila_olap.time_dimension t ON date(r.rental_date) = t.db_date ) basic
JOIN (
-- cantidad_rentas_dia
	SELECT t.time_id, COUNT(*) AS cantidad_rentas_dia
	FROM sakila.rental r 
	JOIN sakila_olap.time_dimension t ON DATE(r.rental_date) = t.db_date
	GROUP BY t.time_id
) cant_dia ON basic.time_id = cant_dia.time_id
JOIN (
-- cantidad_rentas_dia_usuario
	SELECT DATE_FORMAT(DATE(t.db_date),'%Y%m%d') AS date1, COUNT(*) AS cantidad_rentas_dia_usuario, r.customer_id
	FROM sakila.rental r
	JOIN sakila_olap.time_dimension t ON DATE(r.rental_date) = t.db_date
	GROUP BY t.time_id, r.customer_id
) cant_dia_usuario ON DATE_FORMAT(basic.time_id,'%Y%m%d') = cant_dia_usuario.date1 AND basic.customer_id = cant_dia_usuario.customer_id
JOIN (
-- cantidad_rentas_mes_usuario
	SELECT SUBSTRING(r.time_id, -8, 6) AS time_ids, SUM(cantidad_rentas_dia) AS cantidad_rentas_mes_usuario, customer_id customer_ids 
	FROM (SELECT t.time_id, COUNT(*) AS cantidad_rentas_dia, r.customer_id
			FROM sakila.rental r
			JOIN sakila_olap.time_dimension t ON DATE(r.rental_date) = t.db_date
			GROUP BY t.time_id, r.customer_id) r 
	GROUP BY time_ids, customer_ids
) cant_mes_usuario ON DATE_FORMAT(basic.time_id,'%Y%m') = cant_mes_usuario.time_ids AND basic.customer_id = cant_mes_usuario.customer_ids
JOIN (
-- cantidad_rentas_peliculas_año
    SELECT SUBSTRING(r.time_id, -8, 4) AS time_ids, SUM(cantidad_rentas_dia) AS cantidad_rentas_peliculas_ano, film_id film_ids 
	FROM (SELECT t.time_id, COUNT(*) AS cantidad_rentas_dia, f.film_id
	FROM sakila.rental r
	JOIN sakila_olap.time_dimension t ON DATE(r.rental_date) = t.db_date
	JOIN sakila.inventory i ON  r.inventory_id = i.inventory_id 
	JOIN sakila.film f ON i.film_id = f.film_id
	GROUP BY t.time_id, f.film_id) r
	GROUP BY time_ids, film_ids
) cant_ano_pelicula ON DATE_FORMAT(basic.time_id,'%Y') = cant_ano_pelicula.time_ids AND basic.film_id = cant_ano_pelicula.film_ids
JOIN ( 
-- cantidad_peliculas_mes_pais
    SELECT SUBSTRING(r.time_id, -8, 6) AS time_ids, SUM(r.cantidad_rentas_dia) AS cantidad_rentas_peliculas_mes_pais, r.film_id film_ids, r.country_name
	FROM (SELECT t.time_id, COUNT(*) AS cantidad_rentas_dia, f.film_id, loc.country_name
	FROM sakila.rental r
	JOIN sakila_olap.time_dimension t ON DATE(r.rental_date) = t.db_date
	JOIN sakila.inventory i ON  r.inventory_id = i.inventory_id 
	JOIN sakila.store s ON  i.store_id = s.store_id 
	JOIN sakila.address  ON  s.address_id = address.address_id 
    JOIN sakila.city ON address.city_id = city.city_id
	JOIN sakila.film f ON i.film_id = f.film_id
    JOIN sakila_olap.location_dimension loc ON city.city_id = loc.location_id
	GROUP BY t.time_id, f.film_id, loc.country_name) r
	GROUP BY time_ids, film_ids, country_name
) cant_mes_pelicula_pais ON DATE_FORMAT(basic.time_id,'%Y%m') = cant_mes_pelicula_pais.time_ids AND basic.film_id = cant_mes_pelicula_pais.film_ids AND basic.country = cant_mes_pelicula_pais.country_name;

INSERT INTO sakila_olap.payment_fact (payment_id, time_id, cantidad_pagos_dia)
SELECT basic.payment_id, basic.time_id, calculated.cantidad_pagos_dia
FROM (
-- payment basic DF 
	SELECT p.payment_id , t.time_id
	FROM sakila.payment p
	JOIN sakila_olap.time_dimension t ON date(p.payment_date) = t.db_date 
    ) basic
JOIN (
-- cantidad pagos dia
	SELECT t.time_id, COUNT(*) AS cantidad_pagos_dia
	FROM sakila.payment p 
	JOIN sakila_olap.time_dimension t ON DATE(p.payment_date) = t.db_date
	GROUP BY t.time_id
	) calculated
ON basic.time_id = calculated.time_id;