
delimiter |
CREATE TRIGGER sakila.customer_email BEFORE UPDATE ON sakila.customer
  FOR EACH ROW BEGIN
    UPDATE sakila_olap.customer_dimension SET email = CONCAT(email,',', NEW.email) WHERE sakila_olap.customer_dimension.customer_id = NEW.customer_id;
  END
  |
CREATE TRIGGER sakila.cantidad_rentas_dia AFTER INSERT ON sakila.rental
FOR EACH ROW BEGIN
UPDATE sakila_olap.rental_fact SET cantidad_rentas_dia = cantidad_rentas_dia + 1 WHERE DATE_FORMAT(DATE(sakila_olap.rental_fact.time_id),'%Y%m%d') = DATE_FORMAT(DATE(NEW.rental_date),'%Y%m%d');
END
|