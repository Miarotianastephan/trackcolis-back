const colisService = require('../services/colis.service');

/**
 * Créer un nouveau colis (Admin only)
 */
async function createColis(req, res, next) {
  try {
    const { name, tracking_number, transport_type, user_id } = req.body;

    console.log(req.body)


    const colis = await colisService.createColis({
      name,
      tracking_number,
      transport_type,
      user_id,
    });

    res.status(201).json({
      message: 'Colis created successfully',
      colis,
    });
  } catch (err) {
    if (err.message && (err.message.includes('not found') || err.message.includes('already exists') || err.message.includes('Missing'))) {
      return res.status(400).json({ error: err.message });
    }
    next(err);
  }
}

async function colisRecievedInChina(req, res, next) {
  try {
    const { package_id, type_id, _masse, placement } = req.body;


    const colis = await colisService.colisRecievedInChina({
      package_id,
      type_id,
      _masse,
      placement
    });

    res.status(201).json({
      message: 'Colis updated successfully',
      colis,
    });
  } catch (err) {
    if (err.message && (err.message.includes('not found'))) {
      return res.status(400).json({ error: err.message });
    }
    next(err);
  }
}

/**
 * Récupérer tous les colis
 */
async function getAllColis(req, res, next) {
  try {
    const colis = await colisService.getAllColis();
    res.json({ colis });
  } catch (err) {
    next(err);
  }
}

/**
 * Récupérer un colis par ID
 */
async function getColisByIdWithDetails(req, res, next) {
  try {
    const { package_id } = req.params;
    const colis = await colisService.getColisByIdWithDetails(package_id);
    if (!colis) return res.status(404).json({ error: 'Colis not found' });
    res.json({ colis });
  } catch (err) {
    next(err);
  }
}

/**
 * Récupérer les colis d'un utilisateur
 */
async function getColisByUserId(req, res, next) {
  try {
    const { user_id } = req.params;
    const colis = await colisService.getColisByUserId(user_id);
    res.json({ colis });
  } catch (err) {
    next(err);
  }
}

/**
 * Mettre à jour le statut d'un colis (Admin only)
 */
async function updateColisStatus(req, res, next) {
  try {
    console.log(req.body, 'Bodyyyy')
    const { package_id } = req.body;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ error: 'Status is required' });
    }

    const colis = await colisService.updateColisStatus(package_id, status);
    res.json({
      message: 'Colis status updated successfully',
      colis,
    });
  } catch (err) {
    if (err.message && (err.message.includes('not found') || err.message.includes('Invalid status'))) {
      return res.status(400).json({ error: err.message });
    }
    next(err);
  }
}

/**
 * Recherche multi-critères dans les colis
 */
async function searchColis(req, res, next) {
  try {
    const { searchCriteria } = req.query;

    if (!searchCriteria || searchCriteria.trim() === '') {
      return res.status(400).json({ error: 'Search criteria is required' });
    }

    const results = await colisService.searchColis(searchCriteria);
    res.json({
      count: results.length,
      results,
    });
  } catch (err) {
    if (err.message && err.message.includes('required')) {
      return res.status(400).json({ error: err.message });
    }
    next(err);
  }
}

async function filterColisController(req, res) {
  try {
    // Vérifier que req.body existe
    if (!req.body) {
      return res.status(400).json({
        success: false,
        message: 'Le corps de la requête est vide'
      });
    }

    // Solution temporaire pour le test - utiliser req.query si req.body est vide
    const body = req.body || {};
    const query = req.query || {};

    const filters = {
      user_id: body.user_id || query.user_id || null, // Plus de valeur par défaut '1'
      tracking_number: body.tracking_number || query.tracking_number || null,
      transport_type: body.transport_type || query.transport_type || null,
      status: body.status || query.status || null,
      type_id: body.type_id || query.type_id || null
    };

    const options = {
      page: parseInt(body.page || query.page || 1),
      limit: parseInt(body.limit || query.limit || 10),
      order: body.order || query.order || 'DESC'
    };

    console.log('📦 Filtres reçus:', filters);
    console.log('⚙️ Options reçues:', options);

    // Appel de la fonction service
    const result = await colisService.filterColis(filters, options);

    return res.status(200).json({
      success: true,
      data: result
    });

  } catch (error) {
    console.error('❌ Erreur dans filterColisController:', error);

    return res.status(500).json({
      success: false,
      message: 'Erreur lors du filtrage des colis',
      error: error.message
    });
  }
}

async function updateColisController(req, res) {
  try {
    const { package_id } = req.params;
    const updateData = req.body;

    const result = await colisService.updateColis(package_id, updateData);

    return res.status(200).json(result);

  } catch (error) {
    console.error('❌ Erreur updateColisController:', error);

    if (error.message.includes('non trouvé')) {
      return res.status(404).json({
        success: false,
        message: error.message
      });
    }

    return res.status(500).json({
      success: false,
      message: 'Erreur lors de la mise à jour du colis',
      error: error.message
    });
  }
}

module.exports = {
  createColis,
  getAllColis,
  updateColisController,
  getColisByIdWithDetails,
  getColisByUserId,
  updateColisStatus,
  searchColis,
  filterColisController,
  colisRecievedInChina
};
