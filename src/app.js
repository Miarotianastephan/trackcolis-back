const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const app = express();

// Middlewares de sécurité et utilitaires
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
const authRoutes = require('./routes/auth.routes');
const colisRoutes = require('./routes/colis.routes');

app.use('/api/auth', authRoutes);
app.use('/api/colis', colisRoutes);

// Route de test
app.get('/', (req, res) => {
  res.json({ message: 'TrackColis Express Is Ready!' });
});

// Gestion des routes 404
app.use((req, res) => {
  res.status(404).json({ error: 'Route non trouvée' });
});

// Gestion globale des erreurs
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Erreur serveur' });
});


const colisTypeRoutes = require('./routes/colisType');
app.use('/colis-types', colisTypeRoutes);

module.exports = app;