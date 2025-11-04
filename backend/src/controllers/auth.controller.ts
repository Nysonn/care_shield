import { Request, Response } from 'express';
import * as authService from '../services/auth.service.js';
import Joi from 'joi';

const signupSchema = Joi.object({
  fullName: Joi.string().required(),
  phone: Joi.string().required(),
  email: Joi.string().email().optional(),
  password: Joi.string().min(6).required(),
  role: Joi.string().valid('customer', 'rider').optional().default('customer'),
  vehicleType: Joi.string().valid('Boda', 'My Car').when('role', {
    is: 'rider',
    then: Joi.required(),
    otherwise: Joi.optional(),
  }),
  licenseNumber: Joi.string().when('role', {
    is: 'rider',
    then: Joi.required(),
    otherwise: Joi.optional(),
  }),
});

const loginSchema = Joi.object({
  phone: Joi.string().required(),
  password: Joi.string().required(),
});

export const signup = async (req: Request, res: Response) => {
  try {
    const { error, value } = signupSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ message: error.details[0].message });
    }

    const user = await authService.signup(value);
    res.status(201).json(user);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

export const login = async (req: Request, res: Response) => {
  try {
    const { error, value } = loginSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ message: error.details[0].message });
    }

    const result = await authService.login(value);
    res.status(200).json(result);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

export const getProfile = async (req: Request, res: Response) => {
  try {
    const user = await authService.getUserProfile((req as any).user.userId);
    res.status(200).json(user);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};
