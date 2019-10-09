-- MariaDB dump 10.17  Distrib 10.4.8-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: kallsonys
-- ------------------------------------------------------
-- Server version	10.4.8-MariaDB-1:10.4.8+maria~bionic

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `kallsonys`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `kallsonys` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `kallsonys`;

--
-- Table structure for table `kallsonys_items`
--

DROP TABLE IF EXISTS `kallsonys_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kallsonys_items` (
  `itemid` varchar(10) NOT NULL,
  `prodid` decimal(2,0) DEFAULT NULL,
  `productname` varchar(50) DEFAULT NULL,
  `partnum` varchar(20) DEFAULT NULL,
  `price` float(9,2) DEFAULT NULL,
  `quantity` decimal(20,0) DEFAULT NULL,
  `orderid` varchar(20) NOT NULL,
  PRIMARY KEY (`orderid`,`itemid`),
  CONSTRAINT `kallsonys_items_FK` FOREIGN KEY (`orderid`) REFERENCES `kallsonys_shipment` (`orderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kallsonys_items`
--

LOCK TABLES `kallsonys_items` WRITE;
/*!40000 ALTER TABLE `kallsonys_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `kallsonys_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kallsonys_shipment`
--

DROP TABLE IF EXISTS `kallsonys_shipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kallsonys_shipment` (
  `orderid` varchar(20) NOT NULL COMMENT 'Id de la orden de Kallsonys',
  `fname` varchar(50) DEFAULT NULL,
  `lname` varchar(50) DEFAULT NULL,
  `street` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `state` varchar(2) DEFAULT NULL,
  `zipcode` varchar(5) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'Recibido',
  PRIMARY KEY (`orderid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kallsonys_shipment`
--

LOCK TABLES `kallsonys_shipment` WRITE;
/*!40000 ALTER TABLE `kallsonys_shipment` DISABLE KEYS */;
/*!40000 ALTER TABLE `kallsonys_shipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'kallsonys'
--
/*!50003 DROP FUNCTION IF EXISTS `crear_orden` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`%` FUNCTION `crear_orden`(params BLOB) RETURNS blob
    READS SQL DATA
    COMMENT '\r\nDevuelve el id ingresado.\r\nLos parámetros deben ser pasados en un arreglo JSON:\r\n\r\n'
BEGIN
	DECLARE v_orderid VARCHAR(20)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.orden'));
    DECLARE v_fname VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.nombre'));
    DECLARE v_lname VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.apellido'));
    DECLARE v_street VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.direccion'));
    DECLARE v_city VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.ciudad'));
    DECLARE v_state VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.departamento'));
    DECLARE v_zipcode VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.codigo_postal'));
	DECLARE v_items BLOB
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.items'));
    DECLARE i INT UNSIGNED
        DEFAULT 0;
    DECLARE v_item BLOB
        DEFAULT NULL;
    DECLARE v_itemid VARCHAR(10)
        DEFAULT NULL;
    DECLARE v_prodid decimal(2,0)
        DEFAULT NULL;
    DECLARE v_pname VARCHAR(50)
        DEFAULT NULL;
    DECLARE v_partnum VARCHAR(20)
        DEFAULT NULL;
    DECLARE v_price FLOAT4
        DEFAULT NULL;
    DECLARE v_quantity decimal(20,0)
        DEFAULT NULL;

       
    IF v_orderid IS NULL OR v_orderid = '' THEN
        RETURN JSON_OBJECT('estado', 'fallo', 'mensaje', 'El campo orden es obligatorio');
    ELSE
	    IF (EXISTS (
            SELECT *
                FROM kallsonys_shipment
                WHERE
                    kallsonys_shipment.orderid = v_orderid
	        ))
	    THEN
	        RETURN JSON_OBJECT('estado', 'fallo', 'mensaje', 'La orden ya fue registrada');
        ELSE    
	        INSERT INTO kallsonys_shipment (orderid, fname, lname, street, city, state, zipcode) VALUES (v_orderid, v_fname, v_lname, v_street, v_city, v_state, v_zipcode);
	       
	       
			WHILE i < JSON_LENGTH(v_items) DO
				-- get the current item and build an SQL statement
				-- to pass it to a callback procedure
				SET v_item := JSON_EXTRACT(v_items, CONCAT('$[', i, ']'));
				SET v_itemid   := JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.item_id'));
				SET v_prodid   := JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.producto_id'));
				SET v_pname    := JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.nombre_producto'));
				SET v_partnum  := JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.part_num'));
				SET v_price    := JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.precio'));
				SET v_quantity := JSON_UNQUOTE(JSON_EXTRACT(v_item, '$.cantidad'));
			    
				INSERT INTO kallsonys_items (itemid, orderid, prodid, productname, partnum, price, quantity)
			          VALUES (v_itemid, v_orderid, v_prodid, v_pname, v_partnum, v_price, v_quantity);
				SET i := i + 1;
			END WHILE;
	       
	       
	        
            RETURN JSON_OBJECT('estado', 'ok', 'mensaje', 'Se ha registrado la orden exitosamente');
        END IF;
    END IF;
END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `actualizar_orden`()
BEGIN
	UPDATE kallsonys.kallsonys_shipment
		SET status = 'Entregado' 
	WHERE status = 'En Proceso'
	ORDER BY RAND()
	LIMIT 3;
	
	UPDATE kallsonys.kallsonys_shipment
		SET status = 'Devuelto' 
	WHERE status = 'En Proceso'
	ORDER BY RAND()
	LIMIT 1;
	
	UPDATE kallsonys.kallsonys_shipment
		SET status = 'En Proceso' 
	WHERE status = 'Recibido'
	ORDER BY RAND()
	LIMIT 5;
	
END ;;
DELIMITER ;

DELIMITER ;;
CREATE DEFINER=`root`@`%` PROCEDURE `kallsonys`.`listar_ordenes`(params BLOB)
BEGIN
	DECLARE v_orderid VARCHAR(20)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.orden'));
    DECLARE v_fname VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.nombre'));
    DECLARE v_lname VARCHAR(50)
        DEFAULT JSON_UNQUOTE(JSON_EXTRACT(params, '$.apellido'));
       
    IF v_orderid IS NULL OR v_orderid = '' THEN
    	select *
	    from kallsonys_shipment
	    ORDER BY 1 desc
	    limit 100;
    ELSE
    	select *
	    from kallsonys_shipment
	    where orderid = v_orderid;
    END IF;
END ;;
DELIMITER ;

CREATE USER 'user'@'%';
ALTER USER 'user'@'%'
IDENTIFIED BY '123456' ;
GRANT Usage ON *.* TO 'user'@'%';
FLUSH PRIVILEGES;

ALTER USER 'root'@'%'
IDENTIFIED BY 'abc123' ;

GRANT Execute ON kallsonys.* TO 'user'@'%';
FLUSH PRIVILEGES;

/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-09-26  0:32:49
