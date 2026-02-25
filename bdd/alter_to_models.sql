-- Migration / patch script to bring existing database tables in line with
-- the current Sequelize model definitions. This file should be run
-- AFTER the initial trackcolis.sql schema has been imported.
-- It does not modify the original trackcolis.sql; it simply alters the
-- existing tables so that their structures match the models shown in
-- /src/models/*.js.

-- 1. Users table: replace numeric role_id with ENUM role
ALTER TABLE trc_user
  DROP FOREIGN KEY IF EXISTS fk_trc_user_role;
-- drop index on role_id if present
DROP INDEX IF EXISTS idx_trc_user_role ON trc_user;
ALTER TABLE trc_user
  ADD COLUMN role ENUM('agent','admin','user') NOT NULL
        DEFAULT 'user' AFTER phone;
ALTER TABLE trc_user
  DROP COLUMN role_id;

-- 2. Colis type table: add weight range and price columns
ALTER TABLE trc_colis_type
  ADD COLUMN weight_min DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN weight_max DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN price      DECIMAL(10,2) NOT NULL DEFAULT 0.00;

-- 3. Colis table: ensure columns and constraints match model
ALTER TABLE trc_colis
  -- drop obsolete check on price (column may already be gone)
  DROP CHECK IF EXISTS chk_trc_price_positive;

-- remove legacy columns if still present
ALTER TABLE trc_colis
  DROP COLUMN IF EXISTS weight,
  DROP COLUMN IF EXISTS price;

ALTER TABLE trc_colis
  ADD COLUMN IF NOT EXISTS transport_type ENUM('maritime','aerien')
         NOT NULL DEFAULT 'maritime' AFTER type_id,
  MODIFY COLUMN status ENUM('en attente','livrer en chine','en transite','livrer a mada')
         NOT NULL DEFAULT 'en attente',
  ADD COLUMN IF NOT EXISTS created_at DATETIME NOT NULL
         DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS delivery_date DATETIME DEFAULT NULL;

-- 4. (Optional) Update views and procedures if they exist
-- See pgm earlier migration for full redefinition, but we can
-- simply replace them here.

CREATE OR REPLACE VIEW v_trc_colis_details AS
SELECT 
    c.package_id,
    c.name AS colis_name,
    c.tracking_number,
    ct.type_label AS type,
    c.transport_type,
    c.status,
    c.created_at,
    c.delivery_date,
    u.user_id,
    u.name AS user_name,
    u.email AS user_email,
    u.role
FROM trc_colis c
JOIN trc_colis_type ct ON c.type_id = ct.type_id
JOIN trc_user u ON c.user_id = u.user_id;

-- users wishing to enforce the same stored procedures should rerun
-- the definitions provided earlier in the project documentation.

-- End of patch
