import { Router } from 'express';
import { createMedOrder, getMedOrders } from '../controllers/med-order.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

const router = Router();

router.post('/', authMiddleware, createMedOrder);
router.get('/', authMiddleware, getMedOrders);

export default router;
