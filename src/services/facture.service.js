const { Op } = require('sequelize');
const { Facture, Colis } = require('../models');

async function createInvoiceForColis(invoiceData) {
    try {
        const { colis_ids_array, invoice_type, amount, user_id } = invoiceData;

        if (!colis_ids_array || !Array.isArray(colis_ids_array) || colis_ids_array.length === 0) {
            throw new Error('colis_ids_array is required and must be a non-empty array');
        }
        if (!invoice_type || typeof invoice_type !== 'string') {
            throw new Error('invoice_type is required and must be a string');
        }
        if (amount === undefined || isNaN(amount)) {
            throw new Error('amount is required and must be a valid number');
        }

        const colisList = await Colis.findAll({
            where: { package_id: { [Op.in]: colis_ids_array } }
        });

        if (colisList.length !== colis_ids_array.length) {
            const foundIds = colisList.map(c => c.package_id);
            const missingIds = colis_ids_array.filter(id => !foundIds.includes(id));
            throw new Error(`Colis with the following IDs not found: ${missingIds.join(', ')}`);
        }

        const facture = await Facture.create({
            invoice_type,
            amount,
            generation_date: new Date(),
            user_id
        });

        await Colis.update(
            { invoice_id: facture.invoice_id, status: 'livrer', delivery_date: new Date() },
            { where: { package_id: { [Op.in]: colis_ids_array } } }
        );
    
        return facture.get({ plain: true });
    } catch (error) {
        throw new Error(error.message);
    }
}

async function getInvoiceByUserId(user_id) {
    try {
        if (!user_id || isNaN(user_id)) {
            throw new Error('user_id is required and must be a valid number');
        }
        const factures = await Facture.findAll({
            where: { user_id },
            order: [['generation_date', 'DESC']]
        });
        return factures.map(facture => facture.get({ plain: true }));
    } catch (error) {
        throw new Error(error.message);
    }
}

// Modifier la fonction pour inclure les colis associés à la facture    
async function getInvoiceById(invoice_id) {
    try {
        if (!invoice_id || isNaN(invoice_id)) {
            throw new Error('invoice_id is required and must be a valid number');
        }

        const facture = await Facture.findByPk(invoice_id, {
            include: [{
                model: Colis,
                as: 'Colis' // Assuming default alias
            }]
        });
        if (!facture) {
            throw new Error('Invoice not found');
        }
        return facture.get({ plain: true });
    } catch (error) {
        throw new Error(error.message);
    }
}

async function getAllInvoices(){
    try {
        const factures = await Facture.findAll({
            order: [['generation_date', 'DESC']]
        });
        return factures.map(facture => facture.get({ plain: true }));
    } catch (error) {
        throw new Error(error.message);
    }
}

async function fixFactureData() {
    try {
        const factures = await Facture.findAll({
            include: [{
                model: Colis,
                as: 'Colis'
            }],
            order: [[{ model: Colis, as: 'Colis' }, 'package_id', 'ASC']]
        });

        const updatedFactures = await Promise.all(factures.map(async (facture) => {
            const firstColis = facture.Colis?.[0];

            if (!firstColis) {
                const deletedFacture = facture.get({ plain: true });
                await facture.destroy();

                return {
                    ...deletedFacture,
                    deleted: true
                };
            }

            // facture.user_id = firstColis.user_id;
            // await facture.save();

            return {
                ...facture.get({ plain: true }),
                deleted: false
            };
        }));

        return updatedFactures;
    } catch (error) {
        throw new Error(error.message);
    }
}
module.exports = {
    createInvoiceForColis,
    getInvoiceById,
    getAllInvoices,
    getInvoiceByUserId,
    fixFactureData
}
