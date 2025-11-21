const { Sequelize } = require('sequelize');
// Utiliser le système centralisé de gestion des environnements
const { getEnv } = require('./env');

const sequelize = new Sequelize(
  getEnv('DB_NAME'),
  getEnv('DB_USER'),
  getEnv('DB_PASSWORD'),
  {
    host: getEnv('DB_HOST'),
    dialect: 'mysql',
    logging: false,
  }
);

module.exports = sequelize;
