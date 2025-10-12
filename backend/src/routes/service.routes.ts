import express from 'express';
import * as serviceController from '../controllers/service.controller.js';

const router = express.Router();

// Get all services
router.get('/', serviceController.getServices);

// Get services by category
router.get('/category/:category', serviceController.getServicesByCategory);

// Get specific service details
router.get('/:id', serviceController.getServiceById);

export default router;
