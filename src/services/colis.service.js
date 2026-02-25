const { Colis, ColisType, User } = require('../models');
const { Op } = require('sequelize');

/**
 * Crée un nouveau colis
 * @param {Object} coliData - {name, tracking_number, type_id/type_label, transport_type, user_id}
 * @returns {Promise<Object>} Colis créé
 */
async function createColis(coliData) {
  const { name, tracking_number, type_id, type_label, transport_type, user_id } = coliData;

  // Validation basique
  if (!name || !tracking_number || !user_id || !transport_type) {
    throw new Error('Missing required fields: name, tracking_number, transport_type, user_id');
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
    transport_type,
    status: 'en attente',
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
      { model: User, attributes: ['user_id', 'name', 'email', 'role'] },
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

/**
 * Met à jour le statut d'un colis
 * @param {number} package_id - ID du colis
 * @param {string} status - Nouveau statut (pending, shipped, delivered, cancelled)
 * @returns {Promise<Object>} Colis mis à jour
 */
async function updateColisStatus(package_id, status) {
  const validStatuses = ['en attente', 'livrer en chine', 'en transite', 'livrer a mada'];

  if (!status || !validStatuses.includes(status)) {
    throw new Error(`Invalid status. Allowed values: ${validStatuses.join(', ')}`);
  }

  const colis = await Colis.findByPk(package_id);
  if (!colis) throw new Error(`Colis with id ${package_id} not found`);

  await colis.update({ status });
  return colis.get({ plain: true });
}

/**
 * Recherche multi-critères dans les colis
 * @param {string} searchCriteria - Critère de recherche unifié (numéro de suivi ou nom du client)
 * @returns {Promise<Array>} Colis correspondant aux critères
 */
async function searchColis(searchCriteria) {
  if (!searchCriteria || searchCriteria.trim() === '') {
    throw new Error('Search criteria is required');
  }

  const colis = await Colis.findAll({
    include: [
      { model: ColisType, attributes: ['type_key', 'type_label', 'description'] },
      { model: User, attributes: ['user_id', 'name', 'email', 'role'] },
    ],
  });

  // Filtrage par tracking_number ou nom de client (role = 'user')
  const results = colis
    .map(c => c.get({ plain: true }))
    .filter(c => {
      const trackingMatch = c.tracking_number.toLowerCase().includes(searchCriteria.toLowerCase());
      const clientMatch = c.User && c.User.role === 'user' && c.User.name.toLowerCase().includes(searchCriteria.toLowerCase());
      return trackingMatch || clientMatch;
    });

  return results;
}

module.exports = {
  createColis,
  getAllColis,
  getColisByIdWithDetails,
  getColisByUserId,
  updateColisStatus,
  searchColis,
  filterColis,
};

/**
 * Recherche multi-critères (AND) par tracking_number, transport_type, status, type_id
 * @param {Object} filters - {tracking_number, transport_type, status, type_id}
 * @returns {Promise<Array>} matching colis
 */
async function filterColis(filters) {
  const { tracking_number, transport_type, status, type_id } = filters || {};

  const whereClauses = [];
  if (tracking_number) {
    whereClauses.push({ tracking_number: { [Op.like]: `%${tracking_number}%` } });
  }
  if (transport_type) {
    whereClauses.push({ transport_type });
  }
  if (status) {
    whereClauses.push({ status });
  }
  if (type_id) {
    const id = Number(type_id);
    if (!Number.isNaN(id)) whereClauses.push({ type_id: id });
  }

  const where = whereClauses.length ? { [Op.and]: whereClauses } : {};

  const colis = await Colis.findAll({
    where,
    include: [
      { model: ColisType, attributes: ['type_key', 'type_label', 'description'] },
      { model: User, attributes: ['user_id', 'name', 'email', 'role'] },
    ],
  });

  return colis.map(c => c.get({ plain: true }));
}
