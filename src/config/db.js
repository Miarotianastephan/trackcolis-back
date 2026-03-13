const { Sequelize } = require('sequelize');

const sequelize = new Sequelize(
  process.env.DB_NAME || 'trackcolis',
  process.env.DB_USER || 'root',
  process.env.DB_PASSWORD || 'ZbuYwplRSfGqUdLxKBgnnoIBYuKyIXyI',
  {
    host: process.env.DB_HOST || 'switchback.proxy.rlwy.net',
    port: process.env.DB_PORT || 51784,
    dialect: 'mysql',
    logging: console.log,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

module.exports = sequelize;