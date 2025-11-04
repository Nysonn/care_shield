import { Router } from 'express';
import { 
  getPendingOrders, 
  acceptOrder, 
  getMyAcceptedOrders, 
  markAsDelivered, 
  getOrderHistory 
} from '../controllers/rider.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

const router = Router();

// All rider routes require authentication
router.use(authMiddleware);

// Get all pending orders (pool of available orders)
router.get('/pending-orders', getPendingOrders);

// Accept an order
router.post('/orders/:orderId/accept', acceptOrder);

// Get my accepted orders (not yet delivered)
router.get('/accepted-orders', getMyAcceptedOrders);

// Mark an order as delivered
router.patch('/orders/:orderId/deliver', markAsDelivered);

// Get order history (all delivered orders by this rider)
router.get('/order-history', getOrderHistory);

export default router;
