const { Colis, ColisType, User } = require('../models');
const { Op } = require('sequelize');

/**
 * Crée un nouveau colis
 * @param {Object} coliData - {name, tracking_number, type_id/type_label, weight, price, user_id}
 * @returns {Promise<Object>} Colis créé
 */
async function createColis(coliData) {
  const { name, tracking_number, type_id, type_label, weight, price, user_id } = coliData;

  // Validation basique
  if (!name || !tracking_number || !weight || !price || !user_id) {
    throw new Error('Missing required fields: name, tracking_number, weight, price, user_id');
  }

  // Résoudre type_id: soit directement fourni, soit par type_label
  let resolvedTypeId = type_id;
  if (!resolvedTypeId && type_label) {
    const colisType = await ColisType.findOne({ where: { type_label } });
    if (!colisType) throw new Error(`Colis type with label "${type_label}" not found`);
    resolvedTypeId = colisType.type_id;
  }

  if (!resolvedTypeId) {
    throw new Error('Either type_id or type_label must be provided');
  }

  // Vérifier que le type existe
  const typeExists = await ColisType.findByPk(resolvedTypeId);
  if (!typeExists) throw new Error(`Colis type with id ${resolvedTypeId} not found`);

  // Vérifier que l'utilisateur existe
  const userExists = await User.findByPk(user_id);
  if (!userExists) throw new Error(`User with id ${user_id} not found`);

  // Vérifier l'unicité du tracking_number
  const existingTracking = await Colis.findOne({ where: { tracking_number } });
  if (existingTracking) throw new Error(`Tracking number "${tracking_number}" already exists`);

  // Créer le colis
  const colis = await Colis.create({
    name,
    tracking_number,
    type_id: resolvedTypeId,
    weight: parseFloat(weight),
    price: parseFloat(price),
    status: 'pending',
    user_id,
  });

  return colis.get({ plain: true });
}

/**
 * Récupère tous les colis avec détails (type, utilisateur)
 */
async function getAllColis() {
  const colis = await Colis.findAll({
    include: [
      { model: ColisType, attributes: ['type_key', 'type_label', 'description'] },
      { model: User, attributes: ['user_id', 'name', 'email'] },
    ],
  });
  return colis.map(c => c.get({ plain: true }));
}

/**
 * Récupère un colis par ID
 */
async function getColisByIdWithDetails(package_id) {
  const colis = await Colis.findByPk(package_id, {
    include: [
      { model: ColisType, attributes: ['type_key', 'type_label', 'description'] },
      { model: User, attributes: ['user_id', 'name', 'email'] },
    ],
  });
  return colis ? colis.get({ plain: true }) : null;
}

/**
 * Récupère les colis d'un utilisateur
 */
async function getColisByUserId(user_id) {
  const colis = await Colis.findAll({
    where: { user_id },
    include: [
      { model: ColisType, attributes: ['type_key', 'type_label', 'description'] },
    ],
  });
  return colis.map(c => c.get({ plain: true }));
}

module.exports = {
  createColis,
  getAllColis,
  getColisByIdWithDetails,
  getColisByUserId,
};
