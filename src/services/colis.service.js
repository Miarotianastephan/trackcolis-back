const { Colis, ColisType, User } = require('../models');
const { Op } = require('sequelize');

/**
 * Crée un nouveau colis
 * @param {Object} coliData - {name, tracking_number, type_id/type_label, transport_type, user_id}
 * @returns {Promise<Object>} Colis créé
 */
async function createColis(coliData) {
  const { name, tracking_number, transport_type, user_id } = coliData;

  // Validation basique
  if (!name || !tracking_number || !user_id || !transport_type) {
    throw new Error('Missing required fields: name, tracking_number, transport_type, user_id');
  }

  // Vérifier que l'utilisateur existe
  const userExists = await User.findByPk(user_id);
  if (!userExists) throw new Error(`User with id ${user_id} not found`);

  // Vérifier l'unicité du tracking_number
  const existingTracking = await Colis.findOne({ where: { tracking_number } });
  if (existingTracking) throw new Error(`Tracking number "${tracking_number}" already exists`);
  let colis = null;
  // Créer le colis
  try {
    colis = await Colis.create({
      name,
      tracking_number,
      // type_id: resolvedTypeId,
      transport_type,
      status: 'en attente',
      user_id,
    });
  } catch (error) {
    throw new Error(error.message);
  }
  return colis.get({ plain: true });
}

async function updateColis(package_id, updateData) {
  try {

    if (!package_id) {
      throw new Error('package_id est requis');
    }

    const colis = await Colis.findByPk(package_id, {
      include: [
        { model: ColisType, attributes: ['type_id', 'type_key', 'type_label'] },
        { model: User, attributes: ['user_id', 'name', 'email'] }
      ]
    });

    if (!colis) {
      throw new Error(`Colis avec l'ID ${package_id} non trouvé`);
    }

    if (updateData.tracking_number && updateData.tracking_number !== colis.tracking_number) {
      const existingColis = await Colis.findOne({
        where: { tracking_number: updateData.tracking_number }
      });

      if (existingColis) {
        throw new Error(`Le numéro de suivi ${updateData.tracking_number} est déjà utilisé`);
      }
    }

    if (updateData.type_id) {
      const typeExists = await ColisType.findByPk(updateData.type_id);
      if (!typeExists) {
        throw new Error(`Type de colis avec l'ID ${updateData.type_id} non trouvé`);
      }
    }

    if (updateData.user_id) {
      const userExists = await User.findByPk(updateData.user_id);
      if (!userExists) {
        throw new Error(`Utilisateur avec l'ID ${updateData.user_id} non trouvé`);
      }
    }

    const validTransportTypes = ['maritime', 'aerien'];
    if (updateData.transport_type && !validTransportTypes.includes(updateData.transport_type)) {
      throw new Error(`transport_type doit être ${validTransportTypes.join(' ou ')}`);
    }

    const validStatuses = ['en attente', 'livrer en chine', 'en transite', 'livrer a mada'];
    if (updateData.status && !validStatuses.includes(updateData.status)) {
      throw new Error(`status doit être ${validStatuses.join(', ')}`);
    }

    await colis.update(updateData);

    await colis.reload({
      include: [
        { model: ColisType, attributes: ['type_id', 'type_key', 'type_label'] },
        { model: User, attributes: ['user_id', 'name', 'email'] }
      ]
    });

    return {
      success: true,
      message: 'Colis mis à jour avec succès',
      data: colis.get({ plain: true })
    };

  } catch (error) {
    console.error('❌ Erreur dans updateColis:', error);
    throw error;
  }
}


async function colisRecievedInChina(colisToUpdate) {
  const { package_id, type_id, _masse, placement } = colisToUpdate;

  if (!package_id) {
    throw new Error(`Package id: ${package_id} provided`)
  }

  const existingColis = await Colis.findOne({ where: { package_id } });
  if (!existingColis) throw new Error(`Colis with the id: ${package_id} not found`);

  let resolvedTypeId = type_id;
  let colisType = null;
  if (resolvedTypeId) {
    colisType = await ColisType.findOne({ where: { type_id } });
    if (!colisType) throw new Error(`Colis type with id "${resolvedTypeId}" not found`);
  }

  if (!resolvedTypeId) {
    throw new Error('Either type_id or type_label must be provided');
  }

  const typeExists = await ColisType.findByPk(resolvedTypeId);
  if (!typeExists) throw new Error(`Colis type with id ${resolvedTypeId} not found`);

  await existingColis.update({
    type_id: resolvedTypeId,
    status: 'livrer en chine',
    masse: _masse,
    placement,
    price: colisType.price * _masse
  });

  return existingColis.reload();
}

/**
 * Récupère tous les colis avec détails (type, utilisateur)
 */
async function getAllColis() {
  const colis = await Colis.findAll({
    include: [
      { model: ColisType, attributes: ['type_key', 'type_label', 'description'] },
      { model: User, attributes: ['user_id', 'name', 'email','phone' ] },
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
      { model: User, attributes: ['user_id', 'name', 'email', 'role', 'phone'] },
    ],
  });
  return colis ? colis.get({ plain: true }) : null;
}

async function getColisByUserId(user_id, options = {}) {
  const { page = 1, limit = 10, order = 'DESC' } = options;

  const offset = (page - 1) * limit;

  const { count, rows } = await Colis.findAndCountAll({
    where: { user_id },
    include: [
      { model: ColisType, attributes: ['type_key', 'type_label', 'description'] },
    ],
    order: [['created_at', order]],
    limit,
    offset,
    distinct: true
  });

  return {
    totalItems: count,
    totalPages: Math.ceil(count / limit),
    currentPage: page,
    itemsPerPage: limit,
    items: rows.map(c => c.get({ plain: true }))
  };
}

/**
 * Filtre les colis avec pagination et tri par date
 * @param {object} filters - Critères de filtrage
 * @param {string} filters.tracking_number - Numéro de suivi (recherche partielle)
 * @param {string} filters.transport_type - Type de transport ('maritime' ou 'aerien')
 * @param {string} filters.status - Statut du colis
 * @param {number} filters.type_id - ID du type de colis
 * @param {number} filters.user_id - ID de l'utilisateur (OBLIGATOIRE)
 * @param {object} options - Options de pagination et tri
 * @param {number} options.page - Numéro de page (défaut: 1)
 * @param {number} options.limit - Nombre d'éléments par page (défaut: 10)
 * @param {string} options.order - Ordre de tri: 'ASC' ou 'DESC' (défaut: 'DESC')
 */
async function filterColis(filters = {}, options = {}) {
  // Extraction des filtres avec valeurs par défaut
  const {
    tracking_number,
    transport_type,
    status,
    type_id,
    user_id,
    date_debut,    // Optionnel: filtre par date de début
    date_fin       // Optionnel: filtre par date de fin
  } = filters;

  // Extraction des options de pagination
  const {
    page = 1,
    limit = 10,
    order = 'DESC',
    orderBy = 'created_at'  // Optionnel: champ de tri
  } = options;

  // Construction dynamique des clauses WHERE
  const whereClauses = [];

  // Filtre par tracking_number (recherche partielle)
  if (tracking_number && tracking_number.trim() !== '') {
    whereClauses.push({
      tracking_number: {
        [Op.like]: `%${tracking_number.trim()}%`
      }
    });
  }

  // Filtre par transport_type (exact)
  if (transport_type && ['maritime', 'aerien'].includes(transport_type)) {
    whereClauses.push({ transport_type });
  }

  // Filtre par status (exact)
  if (status && ['en attente', 'livrer en chine', 'en transite', 'livrer a mada'].includes(status)) {
    whereClauses.push({ status });
  }

  // Filtre par type_id (exact)
  if (type_id) {
    const id = Number(type_id);
    if (!isNaN(id) && id > 0) {
      whereClauses.push({ type_id: id });
    }
  }

  // Filtre par user_id (exact)
  if (user_id) {
    const id = Number(user_id);
    if (!isNaN(id) && id > 0) {
      whereClauses.push({ user_id: id });
    }
  }

  // Filtre par plage de dates
  if (date_debut || date_fin) {
    const dateFilter = {};

    if (date_debut) {
      dateFilter[Op.gte] = new Date(date_debut);
    }
    if (date_fin) {
      dateFilter[Op.lte] = new Date(date_fin);
    }

    whereClauses.push({ created_at: dateFilter });
  }

  // Construction de l'objet WHERE final
  const where = whereClauses.length > 0
    ? { [Op.and]: whereClauses }
    : {}; // Si pas de filtres, retourne tous les colis

  // Calcul de l'offset pour la pagination
  const offset = (page - 1) * limit;

  try {
    // Exécution de la requête avec pagination
    const { count, rows } = await Colis.findAndCountAll({
      where,
      include: [
        {
          model: ColisType,
          attributes: ['type_id', 'type_key', 'type_label', 'description', 'price'],
          required: false // LEFT JOIN pour inclure même si type_id est NULL
        },
        {
          model: User,
          attributes: ['user_id', 'name', 'email', 'role', 'phone'],
          required: true // INNER JOIN car user_id est toujours présent
        },
      ],
      order: [[orderBy, order]],
      limit,
      offset,
      distinct: true,
      // Ajout d'attributs supplémentaires si besoin
      attributes: [
        'package_id',
        'name',
        'tracking_number',
        'transport_type',
        'status',
        'created_at',
        'delivery_date',
        'user_id',
        'type_id'
      ]
    });

    // Calcul des métadonnées de pagination
    const totalPages = Math.ceil(count / limit);
    const hasNextPage = page < totalPages;
    const hasPrevPage = page > 1;

    // Formatage du résultat
    return {
      success: true,
      data: {
        items: rows.map(colis => colis.get({ plain: true })),
      }
      , pagination: {
        currentPage: page,
        totalItems: count,
        totalPages
      }
    };

  } catch (error) {
    console.error('❌ Erreur dans filterColis service:', error);
    throw new Error(`Erreur lors du filtrage des colis: ${error.message}`);
  }
}

/**
 * Met à jour le statut d'un colis
 * @param {number} package_id - ID du colis
 * @param {string} status - Nouveau statut (pending, shipped, delivered, cancelled)
 * @returns {Promise<Object>} Colis mis à jour
 */
async function updateColisStatus(package_id, status) {
  const validStatuses = ['en attente', 'livrer en chine', 'en transite', 'livrer a mada', 'livrer'];

  if (!status || !validStatuses.includes(status)) {
    throw new Error(`Invalid status. Allowed values: ${validStatuses.join(', ')}`);
  }
  let colis = null;
  for (let i = 0; i < package_id.length; i++) {
    colis = await Colis.findByPk(package_id[i]);
    if (!colis) throw new Error(`Colis with id ${package_id[i]} not found`);
    await colis.update({ status });
  }
  return 'All colis updated succeffully';
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
      { model: User, attributes: ['user_id', 'name', 'email', 'role', 'phone'] },
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
  updateColis,
  getAllColis,
  getColisByIdWithDetails,
  getColisByUserId,
  updateColisStatus,
  searchColis,
  filterColis,
  colisRecievedInChina,
};

