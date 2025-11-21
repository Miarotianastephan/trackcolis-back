function getEnv(key, defaultValue = undefined) {
  return process.env[key] || defaultValue;
}

module.exports = { getEnv }