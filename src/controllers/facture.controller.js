const factureService = require('../services/facture.service');

async function createInvoiceForColis(req, res, next) {
    try {
        const { colis_ids_array, invoice_type, amount} = req.body;
        
        const facture = await factureService.createInvoiceForColis({
            colis_ids_array,
            invoice_type,
            amount
        });

        res.status(201).json({
            message: 'Invoice created successfully',
            facture,
        });
    } catch (err) {
        if (err.message && (err.message.includes('not found') || err.message.includes('already exists') || err.message.includes('Missing'))) {
            return res.status(400).json({ error: err.message });
        }
        next(err);
    }
}

async function getInvoiceByUserId(req, res, next){
    try {
        const { user_id } = req.params;
        const factures = await factureService.getInvoiceByUserId(user_id);
        res.status(201).json({ factures });
    } catch (err) {
        next(err);
    }
}

async function getInvoiceById(req, res, next){
    try {
        const { invoice_id } = req.params;
        const facture = await factureService.getInvoiceById(invoice_id);
        if (!facture) return res.status(404).json({ error: 'Invoice not found' });
        res.status(201).json({ facture });
    } catch (err) {
        next(err);
    }
}

async function getAllInvoices(req, res, next){
    try {
        const factures = await factureService.getAllInvoices();
        res.status(201).json({ factures });
    } catch (err) {
        next(err);
    }
}

module.exports={
    createInvoiceForColis,
    getInvoiceById,
    getAllInvoices,
    getInvoiceByUserId
}