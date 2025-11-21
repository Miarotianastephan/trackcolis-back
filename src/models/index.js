const { Sequelize } = require("sequelize");
const sequelize = require("../config/db");


// Models importation 
const Colis = require("./colis.model");
const  ColisType  = require("./colis_type.model");
const Facture = require("./facture.model");
const  User  = require("./user.model");
const UserRole = require("./user_role.model");


// Associations
User.belongsTo(UserRole, { foreignKey: 'role_id' });
Colis.belongsTo(User, { foreignKey: 'user_id' });
Colis.belongsTo(ColisType, { foreignKey: 'type_id' });
Facture.belongsTo(Colis, { foreignKey: 'package_id' });

module.exports = { sequelize, Sequelize, UserRole, User, ColisType, Colis, Facture };
