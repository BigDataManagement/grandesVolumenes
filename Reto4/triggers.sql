delimiter |
DROP TRIGGER IF EXISTS sakila.customer_email
  |
CREATE TRIGGER sakila.customer_email BEFORE UPDATE ON sakila.customer
  FOR EACH ROW BEGIN
  SET @email=NEW.email;
  UPDATE sakila_olap.customer_dimension SET email =  IF(email NOT LIKE CONCAT('%',@email,'%'), CONCAT(email,',', NEW.email), email) WHERE sakila_olap.customer_dimension.customer_id = NEW.customer_id;
  END
  |
  DROP TRIGGER IF EXISTS sakila_olap.cantidad_rentas_dia
  |
CREATE TRIGGER sakila_olap.cantidad_rentas_dia BEFORE INSERT ON sakila_olap.rental_fact
  FOR EACH ROW BEGIN
  SET @old_rents = (SELECT cantidad_rentas_dia FROM sakila_olap.rental_fact WHERE DATE_FORMAT(DATE(sakila_olap.rental_fact.time_id),'%Y%m%d') = DATE_FORMAT(DATE(NEW.time_id),'%Y%m%d') limit 1);
  IF @old_rents >=1 THEN
	 SET NEW.cantidad_rentas_dia = @old_rents;
  ELSE
	 SET NEW.cantidad_rentas_dia = 1;
  END IF;
END
