-- MySQL dump 10.13  Distrib 9.4.0, for macos26.0 (arm64)
--
-- Host: 127.0.0.1    Database: trackcolis
-- ------------------------------------------------------
-- Server version	8.4.6












--
-- Table structure for table `trc_colis`
--

DROP TABLE IF EXISTS `trc_colis`;


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


--
-- Dumping data for table `trc_colis`
--


INSERT INTO `trc_colis` VALUES (1,'Colis Express 1','TRC001234567',1,2.50,25.50,'shipped',2),(2,'Colis Standard 1','TRC001234568',2,1.20,15.00,'delivered',3),(3,'Colis Fragile','TRC001234569',3,0.80,35.75,'pending',2),(4,'Colis International','TRC001234570',4,5.00,85.00,'shipped',4),(5,'Colis Test','TRC999999999',1,2.50,50.00,'pending',5),(6,'Colis Test','TRC999999998',2,2.50,50.00,'pending',5),(7,'Bread','TRB123',3,10.00,900000.00,'pending',3);


--
-- Table structure for table `trc_colis_type`
--

DROP TABLE IF EXISTS `trc_colis_type`;


CREATE TABLE `trc_colis_type` (
  `type_id` int NOT NULL AUTO_INCREMENT,
  `type_key` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type_label` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`type_id`),
  UNIQUE KEY `uk_trc_colis_type_key` (`type_key`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TrackColis - Table des types de colis';


--
-- Dumping data for table `trc_colis_type`
--


INSERT INTO `trc_colis_type` VALUES (1,'express','Express','Colis livré en express'),(2,'standard','Standard','Colis standard'),(3,'fragile','Fragile','Colis marqué fragile'),(4,'international','International','Colis à destination internationale');


--
-- Table structure for table `trc_facture`
--

DROP TABLE IF EXISTS `trc_facture`;


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


--
-- Dumping data for table `trc_facture`
--


INSERT INTO `trc_facture` VALUES (1,'Proforma',25.50,1,'2025-01-15'),(2,'Final',25.50,1,'2025-01-16'),(3,'Proforma',15.00,2,'2025-01-14'),(4,'Final',15.00,2,'2025-01-15'),(5,'Proforma',35.75,3,'2025-01-18');

;
DELIMITER ;


CREATE TABLE `trc_role` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `uk_trc_role_name` (`role_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='TrackColis - Table des rôles utilisateurs';


--
-- Dumping data for table `trc_role`
--


INSERT INTO `trc_role` VALUES (1,'Admin','Administrateur du système TrackColis avec tous les privilèges'),(2,'Manager','Gestionnaire de colis et factures TrackColis'),(3,'Client','Utilisateur standard TrackColis'),(4,'Guest','Invité avec accès limité');


--
-- Table structure for table `trc_user`
--

DROP TABLE IF EXISTS `trc_user`;


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


--
-- Dumping data for table `trc_user`
--


INSERT INTO `trc_user` VALUES (1,'Jean Dupont','jean.dupont@trackcolis.com','0612345678',1,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(2,'Marie Martin','marie.martin@trackcolis.com','0698765432',2,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(3,'Pierre Durand','pierre.durand@trackcolis.com','0623456789',3,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(4,'Sophie Bernard','sophie.bernard@trackcolis.com','0687654321',3,'$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),(5,'Bonny','bo@gmail.com','0612345678',3,'$2b$10$nlogeUMLQWNLsJJ8F4bVNemTNyRkwuLeNq9gP5ZzP0SFyN.hy8uDS'),(6,'Bonny Clide','bobo@gmail.com','0612345678',1,'$2b$10$z73kALxsxbedrmM0udDLOOg/peiVYp2n4qakM.HkHiHjhIRPksavW'),(7,'Bobogo','bogo@gmail.com','',3,'$2b$10$glyF/BwPQXYSbSzKVcqQeeF80O2Ug4CIGqsUDUH1c.HwNbzntwqLe');


--
-- Temporary view structure for view `v_trc_colis_details`
--

DROP TABLE IF EXISTS `v_trc_colis_details`;

SET @saved_cs_client     = @@character_set_client;


SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_trc_factures_details`
--

DROP TABLE IF EXISTS `v_trc_factures_details`;

SET @saved_cs_client     = @@character_set_client;


SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_trc_user_statistics`
--

DROP TABLE IF EXISTS `v_trc_user_statistics`;

SET @saved_cs_client     = @@character_set_client;


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














--
-- Final view structure for view `v_trc_factures_details`
--













--
-- Final view structure for view `v_trc_user_statistics`
--






















-- Dump completed on 2025-12-05 15:54:36
