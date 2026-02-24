const sequelize = require('../config/db');
const { DataTypes } = require('sequelize');

const ColisType = sequelize.define('ColisType', {
  type_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  type_key: { type: DataTypes.STRING(50), allowNull: false, unique: true },
  type_label: { type: DataTypes.STRING(100), allowNull: false },
  description: { type: DataTypes.STRING(255) },
  weight_min: { type: DataTypes.DECIMAL(10,2), allowNull: false, defaultValue: 0.0 },
  weight_max: { type: DataTypes.DECIMAL(10,2), allowNull: false, defaultValue: 0.0 },
  price: { type: DataTypes.DECIMAL(10,2), allowNull: false, defaultValue: 0.0 }
}, { tableName: 'trc_colis_type', timestamps: false });

module.exports = ColisType 