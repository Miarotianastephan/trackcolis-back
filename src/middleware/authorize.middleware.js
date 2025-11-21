/**
 * Middleware pour vérifier que l'utilisateur a le rôle Admin (role_id = 1)
 */
async function requireAdmin(req, res, next) {
  if (!req.user || req.user.role_id !== 1) {
    return res.status(403).json({ error: 'Forbidden: Admin access required' });
  }
  next();
}

module.exports = { requireAdmin };
