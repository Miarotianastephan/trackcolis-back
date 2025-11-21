const express = require('express');
const router = express.Router();
const { authenticate } = require('../middleware/auth.middleware');

// Placeholder handlers: implement controllers later
router.get('/', authenticate, async (req, res) => {
  res.json({ message: 'List colis - to be implemented', user: req.user });
});

router.post('/', authenticate, async (req, res) => {
  res.status(201).json({ message: 'Create colis - to be implemented', user: req.user, body: req.body });
});

module.exports = router;
