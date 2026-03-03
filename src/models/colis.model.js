const sequelize = require('../config/db');
const { DataTypes } = require('sequelize');

const Colis = sequelize.define('Colis', {
  package_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  tracking_number: { type: DataTypes.STRING(50), allowNull: false, unique: true },
  type_id: { type: DataTypes.INTEGER, allowNull: true },
  masse: { type: DataTypes.DOUBLE, allowNull:true },
  price: { type: DataTypes.DOUBLE, allowNull:true },
  transport_type: { type: DataTypes.ENUM('maritime','aerien'), allowNull: false, defaultValue: 'maritime' },
  status: { type: DataTypes.ENUM('en attente','livrer en chine','en transite','livrer a mada', 'livrer'), allowNull: false, defaultValue: 'en attente' },
  created_at: { type: DataTypes.DATE, allowNull: false, defaultValue: DataTypes.NOW },
  delivery_date: { type: DataTypes.DATE, allowNull: true, defaultValue: null },
  user_id: { type: DataTypes.INTEGER, allowNull: false },
}, { tableName: 'trc_colis', timestamps: false });

module.exports = Colis