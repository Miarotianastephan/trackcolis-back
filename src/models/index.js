const { Sequelize } = require("sequelize");
const sequelize = require("../config/db");


// Models importation 
const Colis = require("./colis.model");
const  ColisType  = require("./colis_type.model");
const Facture = require("./facture.model");
const  User  = require("./user.model");


// Associations
// previously users were linked to a roles table; role is now stored directly on User as an ENUM
Colis.belongsTo(User, { foreignKey: 'user_id' });
Colis.belongsTo(ColisType, { foreignKey: 'type_id' });
Facture.belongsTo(Colis, { foreignKey: 'package_id' });

module.exports = { sequelize, Sequelize, User, ColisType, Colis, Facture };
