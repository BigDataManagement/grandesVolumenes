INSERT INTO sakila_olap.film_dimension (film_id,title,rental_rate)
SELECT film_id,title,rental_rate
FROM sakila.film;

INSERT INTO sakila_olap.store_dimension (store_id)
SELECT store_id
FROM sakila.store;

INSERT INTO sakila_olap.customer_dimension (customer_id,first_name, last_name)
SELECT customer_id,first_name, last_name
FROM sakila.customer;

INSERT INTO sakila_olap.location_dimension (location_id, city_name, country_name)
SELECT c.city_id, c.city, co.country 
FROM sakila.city c JOIN sakila.country co ON c.country_id = co.country_id;