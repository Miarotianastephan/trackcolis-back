const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { requireAdmin } = require('../middleware/authorize.middleware');
const colisController = require('../controllers/colis.controller');

// Créer un nouveau colis (Admin only)
router.post('/', authenticate, colisController.createColis);

// Recherche multi-critères (authentifié)
// Recherche texte simple (authentifié)
router.get('/search', authenticate, colisController.searchColis);

// Filtrage multi-critères (tracking_number, transport_type, status, type_id)
router.get('/filter', authenticate, colisController.filterColis);

// Récupérer tous les colis (authentifié)
router.get('/', authenticate, colisController.getAllColis);

// Récupérer un colis par ID (authentifié)
router.get('/:package_id', authenticate, colisController.getColisByIdWithDetails);

// Récupérer les colis d'un utilisateur (authentifié)
router.get('/user/:user_id', authenticate, colisController.getColisByUserId);

// Mettre à jour le statut d'un colis (Admin only)
router.patch('/:package_id/status', authenticate, requireAdmin, colisController.updateColisStatus);

module.exports = router;
