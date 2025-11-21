const colisService = require('../services/colis.service');

/**
 * Créer un nouveau colis (Admin only)
 */
async function createColis(req, res, next) {
  try {
    const { name, tracking_number, type_id, type_label, weight, price, user_id } = req.body;

    const colis = await colisService.createColis({
      name,
      tracking_number,
      type_id,
      type_label,
      weight,
      price,
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
    const { package_id } = req.params;
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

module.exports = {
  createColis,
  getAllColis,
  getColisByIdWithDetails,
  getColisByUserId,
  updateColisStatus,
  searchColis,
};
