const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');
const colisController = require('../controllers/colis.controller');
const factureController = require('../controllers/facture.controller');
// Créer un nouveau colis (Admin only)
router.post('/', authenticate, colisController.createColis);

// Recherche multi-critères (authentifié)
// Recherche texte simple (authentifié)
router.get('/search', authenticate, colisController.searchColis);

router.post('/recieved', authenticate, colisController.colisRecievedInChina);

// Filtrage multi-critères (tracking_number, transport_type, status, type_id)
router.post('/filter', colisController.filterColisController);

router.delete('/:id',authenticate, colisController.deleteColis);

// Récupérer tous les colis (authentifié)
router.get('/',authenticate, colisController.getAllColis);

// Récupérer un colis par ID (authentifié)
router.get('/byPackageId/:package_id', authenticate, colisController.getColisByIdWithDetails);

// Récupérer les colis d'un utilisateur (authentifié)
router.get('/user/:user_id', authenticate, colisController.getColisByUserId);

router.put('/:package_id', 
  authenticate, 
  colisController.updateColisController
);

// Gestion d'une facture
router.post('/invoice', authenticate, factureController.createInvoiceForColis);

router.get('/invoice/:invoice_id', authenticate, factureController.getInvoiceById);

router.get('/invoices', authenticate, factureController.getAllInvoices);

router.get('/invoices/user/:user_id', authenticate, factureController.getInvoiceByUserId);

// Mettre à jour le statut d'un colis (Admin only)
router.post('/status', authenticate, colisController.updateColisStatus);

module.exports = router;
