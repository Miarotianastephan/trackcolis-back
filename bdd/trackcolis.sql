-- ============================================================================
-- Script SQL - Système TrackColis (TRC)
-- Projet: TrackColis - Système de Gestion des Colis et Factures
-- SGBD: MySQL
-- Préfixe: trc_ (TrackColis)
-- Description: Création de la base de données avec tables, contraintes et index
-- ============================================================================

-- Suppression de la base si elle existe déjà (optionnel - décommenter si nécessaire)
DROP DATABASE IF EXISTS trackcolis;

-- Création de la base de données TrackColis
CREATE DATABASE IF NOT EXISTS trackcolis 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE trackcolis;

-- ============================================================================
-- TABLE: trc_role
-- Description: Stocke les différents rôles utilisateurs du système TrackColis
-- Préfixe: trc_ = TrackColis
-- ============================================================================
CREATE TABLE trc_role (
    role_id INT AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL,
    description VARCHAR(255) NOT NULL,
    
    -- Contraintes
    CONSTRAINT pk_trc_role PRIMARY KEY (role_id),
    CONSTRAINT uk_trc_role_name UNIQUE (role_name)
) ENGINE=InnoDB COMMENT='TrackColis - Table des rôles utilisateurs';

-- ============================================================================
-- TABLE: trc_user
-- Description: Stocke les informations des utilisateurs du système TrackColis
-- Préfixe: trc_ = TrackColis
-- ============================================================================
CREATE TABLE trc_user (
    user_id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL,
    role_id INT NOT NULL,
    password_hash VARCHAR(255),
    
    -- Contraintes
    CONSTRAINT pk_trc_user PRIMARY KEY (user_id),
    CONSTRAINT uk_trc_user_email UNIQUE (email),
    CONSTRAINT fk_trc_user_role FOREIGN KEY (role_id) 
        REFERENCES trc_role(role_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='TrackColis - Table des utilisateurs';

-- ============================================================================
-- TABLE: trc_colis
-- Description: Stocke les informations des colis/packages TrackColis
-- Préfixe: trc_ = TrackColis
-- ============================================================================
-- Table de référence des types de colis
CREATE TABLE trc_colis_type (
    type_id INT AUTO_INCREMENT,
    type_key VARCHAR(50) NOT NULL,       -- clé technique ex: 'express', 'standard' pour avoir plus de filtre au futur
    type_label VARCHAR(100) NOT NULL,    -- libellé lisible
    description VARCHAR(255) DEFAULT NULL,
    CONSTRAINT pk_trc_colis_type PRIMARY KEY (type_id),
    CONSTRAINT uk_trc_colis_type_key UNIQUE (type_key)
) ENGINE=InnoDB COMMENT='TrackColis - Table des types de colis';

-- Insertion des types de colis de référence
INSERT INTO trc_colis_type (type_key, type_label, description) VALUES
    ('express', 'Express', 'Colis livré en express'),
    ('standard', 'Standard', 'Colis standard'),
    ('fragile', 'Fragile', 'Colis marqué fragile'),
    ('international', 'International', 'Colis à destination internationale');

-- Table trc_colis modifiée pour référencer trc_colis_type
CREATE TABLE trc_colis (
    package_id INT AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(50) NOT NULL,
    type_id INT NOT NULL,                -- FK vers trc_colis_type
    weight DECIMAL(10,2) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'shipped', 'delivered', 'cancelled') NOT NULL DEFAULT 'pending',
    user_id INT NOT NULL,
    
    -- Contraintes
    CONSTRAINT pk_trc_colis PRIMARY KEY (package_id),
    CONSTRAINT uk_trc_tracking_number UNIQUE (tracking_number),
    CONSTRAINT fk_trc_colis_user FOREIGN KEY (user_id) 
        REFERENCES trc_user(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_trc_colis_type FOREIGN KEY (type_id)
        REFERENCES trc_colis_type(type_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_trc_price_positive CHECK (price >= 0)
) ENGINE=InnoDB COMMENT='TrackColis - Table des colis/packages';

-- ============================================================================
-- TABLE: trc_facture
-- Description: Stocke les factures générées pour les colis TrackColis
-- Relation: Un colis peut générer plusieurs factures
-- Préfixe: trc_ = TrackColis
-- ============================================================================
CREATE TABLE trc_facture (
    invoice_id INT AUTO_INCREMENT,
    invoice_type VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    package_id INT NOT NULL,
    generation_date DATE NOT NULL,
    
    -- Contraintes
    CONSTRAINT pk_trc_facture PRIMARY KEY (invoice_id),
    CONSTRAINT fk_trc_facture_colis FOREIGN KEY (package_id) 
        REFERENCES trc_colis(package_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_trc_amount_positive CHECK (amount >= 0)
) ENGINE=InnoDB COMMENT='TrackColis - Table des factures';

-- ============================================================================
-- CRÉATION DES INDEX pour optimiser les performances TrackColis
-- Préfixe: idx_trc_ = Index TrackColis
-- ============================================================================

-- Index sur trc_user
CREATE INDEX idx_trc_user_role ON trc_user(role_id);
CREATE INDEX idx_trc_user_email ON trc_user(email);
CREATE INDEX idx_trc_user_name ON trc_user(name);

-- Index sur trc_colis
CREATE INDEX idx_trc_colis_user ON trc_colis(user_id);
CREATE INDEX idx_trc_colis_status ON trc_colis(status);
CREATE INDEX idx_trc_colis_tracking ON trc_colis(tracking_number);

-- Index sur trc_facture
CREATE INDEX idx_trc_facture_package ON trc_facture(package_id);
CREATE INDEX idx_trc_facture_date ON trc_facture(generation_date);
CREATE INDEX idx_trc_facture_type ON trc_facture(invoice_type);

-- ============================================================================
-- INSERTION DE DONNÉES DE TEST - Projet TrackColis
-- ============================================================================

-- Insertion des rôles par défaut TrackColis 
INSERT INTO trc_role (role_name, description) VALUES
    ('Admin', 'Administrateur du système TrackColis avec tous les privilèges'),
    ('Manager', 'Gestionnaire de colis et factures TrackColis'),
    ('Client', 'Utilisateur standard TrackColis'), 
    ('Guest', 'Invité avec accès limité');

-- Insertion d'utilisateurs de test TrackColis avec hashes de mots de passe
-- Les hashes sont générés avec bcrypt (coût 10): password pour tous les utilisateurs
INSERT INTO trc_user (name, email, phone, role_id, password_hash) VALUES
    ('Jean Dupont', 'jean.dupont@trackcolis.com', '0612345678', 1, '$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),
    ('Marie Martin', 'marie.martin@trackcolis.com', '0698765432', 2, '$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),
    ('Pierre Durand', 'pierre.durand@trackcolis.com', '0623456789', 3, '$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c'),
    ('Sophie Bernard', 'sophie.bernard@trackcolis.com', '0687654321', 3, '$2b$10$Lz.KzF9Z4nVqYb8gC1l8G.9Ky2M5xN7pQ3r2sT1uV6wX9yZ0aB2c');

-- Insertion de colis de test TrackColis (référence via type_id)
INSERT INTO trc_colis (name, tracking_number, type_id, weight, price, status, user_id) VALUES
    ('Colis Express 1', 'TRC001234567', (SELECT type_id FROM trc_colis_type WHERE type_key = 'express' LIMIT 1), 2.50, 25.50, 'shipped', 2),
    ('Colis Standard 1', 'TRC001234568', (SELECT type_id FROM trc_colis_type WHERE type_key = 'standard' LIMIT 1), 1.20, 15.00, 'delivered', 3),
    ('Colis Fragile', 'TRC001234569', (SELECT type_id FROM trc_colis_type WHERE type_key = 'fragile' LIMIT 1), 0.80, 35.75, 'pending', 2),
    ('Colis International', 'TRC001234570', (SELECT type_id FROM trc_colis_type WHERE type_key = 'international' LIMIT 1), 5.00, 85.00, 'shipped', 4);

-- Insertion de factures de test TrackColis
INSERT INTO trc_facture (invoice_type, amount, package_id, generation_date) VALUES
    ('Proforma', 25.50, 1, '2025-01-15'),
    ('Final', 25.50, 1, '2025-01-16'),
    ('Proforma', 15.00, 2, '2025-01-14'),
    ('Final', 15.00, 2, '2025-01-15'),
    ('Proforma', 35.75, 3, '2025-01-18');

-- ============================================================================
-- VUES UTILES - Projet TrackColis
-- Préfixe: v_trc_ = Vues TrackColis
-- ============================================================================

-- Vue: Colis avec informations utilisateur TrackColis
CREATE OR REPLACE VIEW v_trc_colis_details AS
SELECT 
    c.package_id,
    c.name AS colis_name,
    c.tracking_number,
    ct.type_label AS type,
    c.weight AS weight,
    c.price,
    c.status,
    u.user_id,
    u.name AS user_name,
    u.email AS user_email,
    r.role_name
FROM trc_colis c
JOIN trc_colis_type ct ON c.type_id = ct.type_id
JOIN trc_user u ON c.user_id = u.user_id
JOIN trc_role r ON u.role_id = r.role_id;

-- Vue: Factures avec détails des colis TrackColis
CREATE OR REPLACE VIEW v_trc_factures_details AS
SELECT 
    f.invoice_id,
    f.invoice_type,
    f.amount,
    f.generation_date,
    c.package_id,
    c.name AS colis_name,
    c.tracking_number,
    u.name AS user_name
FROM trc_facture f
JOIN trc_colis c ON f.package_id = c.package_id
JOIN trc_user u ON c.user_id = u.user_id;

-- Vue: Statistiques par utilisateur TrackColis
CREATE OR REPLACE VIEW v_trc_user_statistics AS
SELECT 
    u.user_id,
    u.name,
    u.email,
    COUNT(DISTINCT c.package_id) AS total_colis,
    COUNT(DISTINCT f.invoice_id) AS total_factures,
    SUM(f.amount) AS total_amount
FROM trc_user u
LEFT JOIN trc_colis c ON u.user_id = c.user_id
LEFT JOIN trc_facture f ON c.package_id = f.package_id
GROUP BY u.user_id, u.name, u.email;

-- ============================================================================
-- PROCÉDURES STOCKÉES - Projet TrackColis
-- Préfixe: sp_trc_ = Stored Procedures TrackColis
-- ============================================================================

DELIMITER //

-- Procédure: Créer un nouveau colis TrackColis avec validation
CREATE PROCEDURE sp_trc_create_colis(
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
END //

-- Procédure: Générer une facture TrackColis pour un colis
CREATE PROCEDURE sp_trc_generate_facture(
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
END //

DELIMITER ;

-- ============================================================================
-- TRIGGERS - Projet TrackColis
-- Préfixe: trg_trc_ = Triggers TrackColis
-- ============================================================================

DELIMITER //

-- Trigger: Vérifier le statut avant insertion de facture TrackColis
CREATE TRIGGER trg_trc_before_insert_facture
BEFORE INSERT ON trc_facture
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(50);
    
    SELECT status INTO v_status 
    FROM trc_colis 
    WHERE package_id = NEW.package_id;
    
    IF v_status = 'cancelled' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'TrackColis: Impossible de créer une facture pour un colis annulé';
    END IF;
END //

DELIMITER ;

-- ============================================================================
-- FIN DU SCRIPT - Projet TrackColis
-- ============================================================================

-- Affichage des tables créées TrackColis
SHOW TABLES;

-- Affichage de la structure des tables TrackColis
DESCRIBE trc_role;
DESCRIBE trc_user;
DESCRIBE trc_colis;
DESCRIBE trc_facture;