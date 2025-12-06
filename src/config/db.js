const { Sequelize } = require('sequelize');
const { getEnv } = require('./env');

const sequelize = new Sequelize(
  getEnv('DB_NAME'),
  getEnv('DB_USER'),
  getEnv('DB_PASSWORD'),
  {
    host: getEnv('DB_HOST'),
    port: getEnv('DB_PORT') || 10398,
    dialect: 'mysql',
    logging: false,
    dialectOptions: {
      connectTimeout: 15000, // éviter ETIMEDOUT
    },
    pool: {
      max: 10,
      min: 0,
      acquire: 30000, // temps max d'attente pour une connexion
      idle: 10000,
    },
  }
);

module.exports = sequelize;