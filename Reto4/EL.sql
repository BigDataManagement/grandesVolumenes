INSERT INTO sakila_olap.film_dimension (film_id,category_id,title,category_name,rental_rate)
SELECT f.film_id,c.category_id,f.title,c.name,f.rental_rate
FROM sakila.film f
JOIN sakila.film_category fc ON f.film_id = fc.film_id
JOIN sakila.category c ON fc.category_id = c.category_id;

INSERT INTO sakila_olap.store_dimension (store_id)
SELECT store_id
FROM sakila.store;

INSERT INTO sakila_olap.customer_dimension (customer_id,first_name, last_name, email)
SELECT customer_id,first_name, last_name, email
FROM sakila.customer;

INSERT INTO sakila_olap.location_dimension (location_id, city_name, country_name)
SELECT c.city_id, c.city, co.country 
FROM sakila.city c JOIN sakila.country co ON c.country_id = co.country_id;