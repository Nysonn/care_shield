import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';
import * as riderService from '../services/rider.service.js';

const prisma = new PrismaClient();

/**
 * Get all pending orders available for riders to accept
 */
export const getPendingOrders = async (req: any, res: Response) => {
  try {
    // Verify the user is a rider
    const user = await prisma.user.findUnique({
      where: { id: req.user.userId },
    });

    if (!user || user.role !== 'rider') {
      return res.status(403).json({ message: 'Access denied. Only riders can view pending orders.' });
    }

    const orders = await riderService.getPendingOrders();
    res.status(200).json(orders);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

/**
 * Accept an order
 */
export const acceptOrder = async (req: any, res: Response) => {
  try {
    const { orderId } = req.params;
    const riderId = req.user.userId;

    const order = await riderService.acceptOrder(riderId, orderId);
    res.status(200).json(order);
  } catch (error: any) {
    const statusCode = error.message.includes('not found') ? 404 : 400;
    res.status(statusCode).json({ message: error.message });
  }
};

/**
 * Get all accepted orders for the current rider
 */
export const getMyAcceptedOrders = async (req: any, res: Response) => {
  try {
    const riderId = req.user.userId;
    const orders = await riderService.getMyAcceptedOrders(riderId);
    res.status(200).json(orders);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

/**
 * Mark an order as delivered
 */
export const markAsDelivered = async (req: any, res: Response) => {
  try {
    const { orderId } = req.params;
    const riderId = req.user.userId;

    const order = await riderService.markAsDelivered(riderId, orderId);
    res.status(200).json(order);
  } catch (error: any) {
    const statusCode = error.message.includes('not found') ? 404 : 400;
    res.status(statusCode).json({ message: error.message });
  }
};

/**
 * Get order history for the current rider (all delivered orders)
 */
export const getOrderHistory = async (req: any, res: Response) => {
  try {
    const riderId = req.user.userId;
    const orders = await riderService.getOrderHistory(riderId);
    res.status(200).json(orders);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};
