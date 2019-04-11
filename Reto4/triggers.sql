delimiter |
CREATE TRIGGER sakila.customer_email BEFORE UPDATE ON sakila.customer
  FOR EACH ROW BEGIN
  SET @email=NEW.email;
  UPDATE sakila_olap.customer_dimension SET email =  IF(email NOT LIKE CONCAT('%',@email,'%'), CONCAT(email,',', NEW.email), email) WHERE sakila_olap.customer_dimension.customer_id = NEW.customer_id;
  END
  |