-- MySQL dump 10.13  Distrib 9.4.0, for macos26.0 (arm64)
--
-- Host: localhost    Database: trackcolis
-- ------------------------------------------------------
-- Server version	8.4.6

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `trc_colis`
--

DROP TABLE IF EXISTS `trc_colis`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trc_colis` (
  `package_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tracking_number` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_id` int NOT NULL,
  `weight` decimal(10,2) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `status` enum('pending','shipped','delivered','cancelled') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `user_id` int NOT NULL,
  PRIMARY KEY (`package_id`),
  UNIQUE KEY `uk_trc_tracking_number` (`tracking_number`),
  KEY `fk_trc_colis_type` (`type_id`),
  KEY `idx_trc_colis_user` (`user_id`),
  KEY `idx_trc_colis_status` (`status`),
  KEY `idx_trc_colis_tracking` (`tracking_number`),
  CONSTRAINT `fk_trc_colis_type` FOREIGN KEY (`type_id`) REFERENCES `trc_colis_type` (`type_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_trc_colis_user` FOREIGN KEY (`user_id`) REFERENCES `trc_user` (`user_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_trc_price_positive` CHECK ((`price` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TrackColis - Table des colis/packages';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trc_colis`
--

LOCK TABLES `trc_colis` WRITE;
/*!40000 ALTER TABLE `trc_colis` DISABLE KEYS */;
INSERT INTO `trc_colis` VALUES (1,'Colis Express 1','TRC001234567',1,2.50,25.50,'shipped',2),(2,'Colis Standard 1','TRC001234568',2,1.20,15.00,'delivered',3),(3,'Colis Fragile','TRC001234569',3,0.80,35.75,'pending',2),(4,'Colis International','TRC001234570',4,5.00,85.00,'shipped',4),(5,'Colis Test','TRC999999999',1,2.50,50.00,'pending',5),(6,'Colis Test','TRC999999998',2,2.50,50.00,'pending',5),(7,'Bread','TRB123',3,10.00,900000.00,'pending',3);
/*!40000 ALTER TABLE `trc_colis` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trc_colis_type`
--

DROP TABLE IF EXISTS `trc_colis_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trc_colis_type` (
  `type_id` int NOT NULL AUTO_INCREMENT,
  `type_key` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uk_trc_colis_type_key` (`type_key`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TrackColis - Table des types de colis';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trc_colis_type`
--

LOCK TABLES `trc_colis_type` WRITE;
/*!40000 ALTER TABLE `trc_colis_type` DISABLE KEYS */;
INSERT INTO `trc_colis_type` VALUES (1,'express','Express','Colis livré en express'),(2,'standard','Standard','Colis standard'),(3,'fragile','Fragile','Colis marqué fragile'),(4,'international','International','Colis à destination internationale');
/*!40000 ALTER TABLE `trc_colis_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trc_facture`
--

DROP TABLE IF EXISTS `trc_facture`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trc_facture` (
  `invoice_id` int NOT NULL AUTO_INCREMENT,
  `invoice_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `package_id` int NOT NULL,
  `generation_date` date NOT NULL,
  PRIMARY KEY (`invoice_id`),
  KEY `idx_trc_facture_package` (`package_id`),
  KEY `idx_trc_facture_date` (`generation_date`),
  KEY `idx_trc_facture_type` (`invoice_type`),
  CONSTRAINT `fk_trc_facture_colis` FOREIGN KEY (`package_id`) REFERENCES `trc_colis` (`package_id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `chk_trc_amount_positive` CHECK ((`amount` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TrackColis - Table des factures';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trc_facture`
--

LOCK TABLES `trc_facture` WRITE;
/*!40000 ALTER TABLE `trc_facture` DISABLE KEYS */;
INSERT INTO `trc_facture` VALUES (1,'Proforma',25.50,1,'2025-01-15'),(2,'Final',25.50,1,'2025-01-16'),(3,'Proforma',15.00,2,'2025-01-14'),(4,'Final',15.00,2,'2025-01-15'),(5,'Proforma',35.75,3,'2025-01-18');
/*!40000 ALTER TABLE `trc_facture` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 */ /*!50003 TRIGGER `trg_trc_before_insert_facture` BEFORE INSERT ON `trc_facture` FOR EACH ROW BEGIN
    DECLARE v_status VARCHAR(50);
    
    SELECT status INTO v_status 
    FROM trc_colis 
    WHERE package_id = NEW.package_id;
    
    IF v_status = 'cancelled' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'TrackColis: Impossible de créer une facture pour un colis annulé';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `trc_role`
--

DROP TABLE IF EXISTS `trc_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trc_role` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_trc_role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TrackColis - Table des rôles utilisateurs';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trc_role`
--

LOCK TABLES `trc_role` WRITE;
/*!40000 ALTER TABLE `trc_role` DISABLE KEYS */;
INSERT INTO `trc_role` VALUES (1,'Admin','Administrateur du système TrackColis avec tous les privilèges'),(2,'Manager','Gestionnaire de colis et factures TrackColis'),(3,'Client','Utilisateur standard TrackColis'),(4,'Guest','Invité avec accès limité');
/*!40000 ALTER TABLE `trc_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trc_user`
--

DROP TABLE IF EXISTS `trc_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trc_user` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` int NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uk_trc_user_email` (`email`),
  KEY `idx_trc_user_role` (`role_id`),
  KEY `idx_trc_user_email` (`email`),
  KEY `idx_trc_user_name` (`name`),
  CONSTRAINT `fk_trc_user_role` FOREIGN KEY (`role_id`) REFERENCES `trc_role` (`role_id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TrackColis - Table des utilisateurs';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trc_user`
--

LOCK TABLES `trc_user` WRITE;
/*!40000 ALTER TABLE `trc_user` DISABLE KEYS */;
INSERT INTO `trc_user` VALUES (1,'Jean Dupont','jean.dupont@trackcolis.com','0612345678',1,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(2,'Marie Martin','marie.martin@trackcolis.com','0698765432',2,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(3,'Pierre Durand','pierre.durand@trackcolis.com','0623456789',3,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(4,'Sophie Bernard','sophie.bernard@trackcolis.com','0687654321',3,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(5,'Bonny','bo@gmail.com','0612345678',3,'$2b$10$nlogeUMLQWNLsJJ8F4bVNemTNyRkwuLeNq9gP5ZzP0SFyN.hy8uDS'),(6,'Bonny Clide','bobo@gmail.com','0612345678',1,'$2b$10$z73kALxsxbedrmM0udDLOOg/peiVYp2n4qakM.HkHiHjhIRPksavW'),(7,'Bobogo','bogo@gmail.com','',3,'$2b$10$glyF/BwPQXYSbSzKVcqQeeF80O2Ug4CIGqsUDUH1c.HwNbzntwqLe');
/*!40000 ALTER TABLE `trc_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_trc_colis_details`
--

DROP TABLE IF EXISTS `v_trc_colis_details`;
/*!50001 DROP VIEW IF EXISTS `v_trc_colis_details`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_trc_colis_details` AS SELECT 
 1 AS `package_id`,
 1 AS `colis_name`,
 1 AS `tracking_number`,
 1 AS `type`,
 1 AS `weight`,
 1 AS `price`,
 1 AS `status`,
 1 AS `user_id`,
 1 AS `user_name`,
 1 AS `user_email`,
 1 AS `role_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_trc_factures_details`
--

DROP TABLE IF EXISTS `v_trc_factures_details`;
/*!50001 DROP VIEW IF EXISTS `v_trc_factures_details`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_trc_factures_details` AS SELECT 
 1 AS `invoice_id`,
 1 AS `invoice_type`,
 1 AS `amount`,
 1 AS `generation_date`,
 1 AS `package_id`,
 1 AS `colis_name`,
 1 AS `tracking_number`,
 1 AS `user_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_trc_user_statistics`
--

DROP TABLE IF EXISTS `v_trc_user_statistics`;
/*!50001 DROP VIEW IF EXISTS `v_trc_user_statistics`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_trc_user_statistics` AS SELECT 
 1 AS `user_id`,
 1 AS `name`,
 1 AS `email`,
 1 AS `total_colis`,
 1 AS `total_factures`,
 1 AS `total_amount`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping routines for database 'trackcolis'
--
--
-- WARNING: can't read the INFORMATION_SCHEMA.libraries table. It's most probably an old server 8.4.6.
--
--
-- WARNING: can't read the INFORMATION_SCHEMA.libraries table. It's most probably an old server 8.4.6.
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_trc_create_colis` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_trc_create_colis`(
    IN p_name VARCHAR(100),
    IN p_tracking_number VARCHAR(50),
    IN p_type VARCHAR(50),
    IN p_weight DECIMAL(10,2),
    IN p_price DECIMAL(10,2),
    IN p_user_id INT
)
BEGIN
    DECLARE v_user_exists INT;
    DECLARE v_type_id INT;
    
    -- Vérifier si l'utilisateur existe dans TrackColis
    SELECT COUNT(*) INTO v_user_exists FROM trc_user WHERE user_id = p_user_id;
    
    IF v_user_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'TrackColis: L\'utilisateur spécifié n\'existe pas';
    END IF;

    -- Résoudre le type texte en type_id (recherche par clé ou label)
    SELECT type_id INTO v_type_id
    FROM trc_colis_type
    WHERE type_key = p_type OR type_label = p_type
    LIMIT 1;

    IF v_type_id IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'TrackColis: Le type de colis spécifié n\'existe pas';
    END IF;
    
    -- Insérer le colis dans TrackColis en utilisant type_id et weight
    INSERT INTO trc_colis (name, tracking_number, type_id, weight, price, status, user_id)
    VALUES (p_name, p_tracking_number, v_type_id, p_weight, p_price, 'pending', p_user_id);

    SELECT LAST_INSERT_ID() AS package_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
--
-- WARNING: can't read the INFORMATION_SCHEMA.libraries table. It's most probably an old server 8.4.6.
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_trc_generate_facture` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb3 */ ;
/*!50003 SET character_set_results = utf8mb3 */ ;
/*!50003 SET collation_connection  = utf8mb3_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE  PROCEDURE `sp_trc_generate_facture`(
    IN p_package_id INT,
    IN p_invoice_type VARCHAR(20)
)
BEGIN
    DECLARE v_package_exists INT;
    DECLARE v_price DECIMAL(10,2);
    
    -- Vérifier si le colis existe dans TrackColis
    SELECT COUNT(*), MAX(price) 
    INTO v_package_exists, v_price 
    FROM trc_colis 
    WHERE package_id = p_package_id;
    
    IF v_package_exists = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'TrackColis: Le colis spécifié n\'existe pas';
    END IF;
    
    -- Créer la facture TrackColis
    INSERT INTO trc_facture (invoice_type, amount, package_id, generation_date)
    VALUES (p_invoice_type, v_price, p_package_id, CURDATE());
    
    SELECT LAST_INSERT_ID() AS invoice_id;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `v_trc_colis_details`
--

/*!50001 DROP VIEW IF EXISTS `v_trc_colis_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_trc_colis_details` AS select `c`.`package_id` AS `package_id`,`c`.`name` AS `colis_name`,`c`.`tracking_number` AS `tracking_number`,`ct`.`type_label` AS `type`,`c`.`weight` AS `weight`,`c`.`price` AS `price`,`c`.`status` AS `status`,`u`.`user_id` AS `user_id`,`u`.`name` AS `user_name`,`u`.`email` AS `user_email`,`r`.`role_name` AS `role_name` from (((`trc_colis` `c` join `trc_colis_type` `ct` on((`c`.`type_id` = `ct`.`type_id`))) join `trc_user` `u` on((`c`.`user_id` = `u`.`user_id`))) join `trc_role` `r` on((`u`.`role_id` = `r`.`role_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_trc_factures_details`
--

/*!50001 DROP VIEW IF EXISTS `v_trc_factures_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_trc_factures_details` AS select `f`.`invoice_id` AS `invoice_id`,`f`.`invoice_type` AS `invoice_type`,`f`.`amount` AS `amount`,`f`.`generation_date` AS `generation_date`,`c`.`package_id` AS `package_id`,`c`.`name` AS `colis_name`,`c`.`tracking_number` AS `tracking_number`,`u`.`name` AS `user_name` from ((`trc_facture` `f` join `trc_colis` `c` on((`f`.`package_id` = `c`.`package_id`))) join `trc_user` `u` on((`c`.`user_id` = `u`.`user_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_trc_user_statistics`
--

/*!50001 DROP VIEW IF EXISTS `v_trc_user_statistics`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb3 */;
/*!50001 SET character_set_results     = utf8mb3 */;
/*!50001 SET collation_connection      = utf8mb3_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013  SQL SECURITY DEFINER */
/*!50001 VIEW `v_trc_user_statistics` AS select `u`.`user_id` AS `user_id`,`u`.`name` AS `name`,`u`.`email` AS `email`,count(distinct `c`.`package_id`) AS `total_colis`,count(distinct `f`.`invoice_id`) AS `total_factures`,sum(`f`.`amount`) AS `total_amount` from ((`trc_user` `u` left join `trc_colis` `c` on((`u`.`user_id` = `c`.`user_id`))) left join `trc_facture` `f` on((`c`.`package_id` = `f`.`package_id`))) group by `u`.`user_id`,`u`.`name`,`u`.`email` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-06 11:08:01
