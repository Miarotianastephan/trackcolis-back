const sequelize = require('../config/db');
const { DataTypes } = require('sequelize');

const Colis = sequelize.define('Colis', {
  package_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  tracking_number: { type: DataTypes.STRING(50), allowNull: false, unique: true },
  type_id: { type: DataTypes.INTEGER, allowNull: false },
  status: { type: DataTypes.ENUM('pending','shipped','delivered','cancelled'), allowNull: false },
  user_id: { type: DataTypes.INTEGER, allowNull: false },
}, { tableName: 'trc_colis', timestamps: false });

module.exports = Colis