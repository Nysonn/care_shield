// import { Router } from 'express';
// import { signup, login, getProfile } from '../controllers/auth.controller.js';
// import { authMiddleware } from '../middlewares/auth.middleware.js';
// import { getDrugs, getDrugById } from '../controllers/drug.controller.js';
// import { getHealthCenters } from '../controllers/health-center.controller.js';
// import { createMedOrder, getMedOrders } from '../controllers/med-order.controller.js';

// const router = Router();

// // Auth Routes
// router.post('/signup', signup);
// router.post('/login', login);
// router.get('/me', authMiddleware, getProfile);

// // Drug Routes
// router.get('/', getDrugs);
// router.get('/:id', getDrugById);

// // Health 
// router.get('/', getHealthCenters);

// // Med Orders
// router.post('/', authMiddleware, createMedOrder);
// router.get('/', authMiddleware, getMedOrders);

// export default router;

// Proposed routes file