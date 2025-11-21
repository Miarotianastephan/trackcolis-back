const sequelize = require('../config/db');
const { DataTypes } = require('sequelize');

const User = sequelize.define('User', {
  user_id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
  name: { type: DataTypes.STRING(100), allowNull: false },
  email: { type: DataTypes.STRING(100), allowNull: false, unique: true },
  phone: { type: DataTypes.STRING(15), allowNull: false },
  role_id: { type: DataTypes.INTEGER, allowNull: false },
  password_hash: { type: DataTypes.STRING(255) },
}, { tableName: 'trc_user', timestamps: false });

module.exports =  User ;