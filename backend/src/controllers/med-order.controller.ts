import { Request, Response } from 'express';
import * as medOrderService from '../services/med-order.service.js';
import Joi from 'joi';

const createMedOrderSchema = Joi.object({
  stage: Joi.string().required(),
  location: Joi.string().required(),
  eta: Joi.string().required(),
  totalAmount: Joi.number().required(),
  deliveryFee: Joi.number().required(),
  drugs: Joi.array().items(Joi.string()).required(),
  paymentId: Joi.string().optional(),
});

export const createMedOrder = async (req: any, res: Response) => {
  try {
    const { error, value } = createMedOrderSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ message: error.details[0].message });
    }

    const order = await medOrderService.createMedOrder(req.user.userId, value);
    res.status(201).json(order);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

export const getMedOrders = async (req: any, res: Response) => {
  try {
    const orders = await medOrderService.getMedOrders(req.user.userId);
    res.status(200).json(orders);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};
