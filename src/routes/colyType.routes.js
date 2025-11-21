const express = require('express');
const router = express.Router();
const { ColisType } = require('../models');

router.post('/', async (req, res) => {
    try {
        const colisType = await ColisType.create(req.body);
        res.status(201).json(colisType);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.get('/', async (req, res) => {
    try {
        const colisTypes = await ColisType.findAll();
        res.json(colisTypes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    try {
        const colisType = await ColisType.findByPk(req.params.id);
        if (!colisType) return res.status(404).json({ error: 'ColisType not found' });
        res.json(colisType);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

router.put('/:id', async (req, res) => {
    try {
        const colisType = await ColisType.findByPk(req.params.id);
        if (!colisType) return res.status(404).json({ error: 'ColisType not found' });
        await colisType.update(req.body);
        res.json(colisType);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        const colisType = await ColisType.findByPk(req.params.id);
        if (!colisType) return res.status(404).json({ error: 'ColisType not found' });
        await colisType.destroy();
        res.json({ message: 'ColisType deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;
