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
Facture.hasMany(Colis, { foreignKey: 'invoice_id' }, { as: 'Colis' });

module.exports = { sequelize, Sequelize, User, ColisType, Colis, Facture };
