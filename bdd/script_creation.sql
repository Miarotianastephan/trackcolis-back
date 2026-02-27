CREATE DATABASE trackcolis;

USE trackcolis;

-- Table des utilisateurs
CREATE TABLE trc_user (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    role ENUM('agent', 'admin', 'user') NOT NULL DEFAULT 'user',
    password_hash VARCHAR(255)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des types de colis
CREATE TABLE trc_colis_type (
    type_id INT PRIMARY KEY AUTO_INCREMENT,
    type_key VARCHAR(50) NOT NULL UNIQUE,
    type_label VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    weight_min DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    weight_max DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des colis
CREATE TABLE trc_colis (
    package_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    tracking_number VARCHAR(50) NOT NULL UNIQUE,
    type_id INT,
    transport_type ENUM('maritime', 'aerien') NOT NULL DEFAULT 'maritime',
    status ENUM('en attente', 'livrer en chine', 'en transite', 'livrer a mada') NOT NULL DEFAULT 'en attente',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_date DATE DEFAULT NULL,
    user_id INT NOT NULL,
    FOREIGN KEY (type_id) REFERENCES trc_colis_type(type_id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES trc_user(user_id) ON DELETE CASCADE,
    INDEX idx_tracking_number (tracking_number),
    INDEX idx_status (status),
    INDEX idx_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des factures
CREATE TABLE trc_facture (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    invoice_type VARCHAR(20) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    package_id INT NOT NULL,
    generation_date DATE NOT NULL,
    FOREIGN KEY (package_id) REFERENCES trc_colis(package_id) ON DELETE CASCADE,
    INDEX idx_package_id (package_id),
    INDEX idx_generation_date (generation_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- INSERT INTO trc_colis_type (type_key, type_label, description, weight_min, weight_max, price) VALUES
-- ('DOCUMENT', 'Document administratif', 'Passeports, diplômes, contrats', 0.00, 0.30, 30000.50),
-- ('ELECTRONIQUE', 'Appareil électronique', 'Téléphones, tablettes, ordinateurs', 0.50, 3.00, 30000.00),
-- ('VETEMENT', 'Vêtements', 'Habits, chaussures, accessoires', 0.30, 2.00, 12000.00),
-- ('CADEAU', 'Cadeau', 'Coffrets, jouets, articles cadeaux', 0.20, 1.50, 10000.00),
-- ('ALIMENTAIRE', 'Produits alimentaires', 'Denrées non périssables', 0.50, 5.00, 20000.00);

ALTER TABLE trc_colis 
ADD COLUMN masse DOUBLE DEFAULT NULL,
ADD COLUMN price DOUBLE DEFAULT NULL;