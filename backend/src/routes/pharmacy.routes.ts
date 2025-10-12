import express from 'express';
import * as pharmacyController from '../controllers/pharmacy.controller.js';

const router = express.Router();

// Get all pharmacies with pagination and search
router.get('/', pharmacyController.getPharmacies);

// Search pharmacies by drug name
router.get('/search', pharmacyController.searchPharmacies);

// Search drugs across all pharmacies
router.get('/drugs/search', pharmacyController.searchDrugs);

// Get specific pharmacy details
router.get('/:id', pharmacyController.getPharmacyById);

// Get drugs available at a specific pharmacy
router.get('/:id/drugs', pharmacyController.getPharmacyDrugs);

// Get services offered by a specific pharmacy
router.get('/:id/services', pharmacyController.getPharmacyServices);

export default router;
