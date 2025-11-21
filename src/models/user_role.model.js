const sequelize = require('../config/db');
const { DataTypes } = require('sequelize');

const UserRole = sequelize.define('UserRole', {
  role_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  role_name: { type: DataTypes.STRING(50), allowNull: false, unique: true },
  description: { type: DataTypes.STRING(255), allowNull: false },
}, { tableName: 'trc_role', timestamps: false });

module.exports =  UserRole ;