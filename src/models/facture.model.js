const sequelize = require('../config/db');
const { DataTypes } = require('sequelize');

const Facture = sequelize.define('Facture', {
  invoice_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  invoice_type: { type: DataTypes.STRING(20), allowNull: false },
  amount: { type: DataTypes.DECIMAL(10,2), allowNull: false },
  generation_date: { type: DataTypes.DATEONLY, allowNull: false },
}, { tableName: 'trc_facture', timestamps: false });

module.exports = Facture
