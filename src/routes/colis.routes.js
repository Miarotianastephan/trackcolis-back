const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const { requireAdmin } = require('../middleware/authorize.middleware');
const colisController = require('../controllers/colis.controller');

// Créer un nouveau colis (Admin only)
router.post('/', authenticate, requireAdmin, colisController.createColis);

// Récupérer tous les colis (authentifié)
router.get('/', authenticate, colisController.getAllColis);

// Récupérer un colis par ID (authentifié)
router.get('/:package_id', authenticate, colisController.getColisByIdWithDetails);

// Récupérer les colis d'un utilisateur (authentifié)
router.get('/user/:user_id', authenticate, colisController.getColisByUserId);

module.exports = router;
