import { Request, Response } from 'express';
import * as serviceService from '../services/service.service.js';

export const getServices = async (req: Request, res: Response) => {
  try {
    const services = await serviceService.getServices();
    res.status(200).json(services);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const getServiceById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const service = await serviceService.getServiceById(id);
    
    if (!service) {
      return res.status(404).json({ message: 'Service not found' });
    }
    
    res.status(200).json(service);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const getServicesByCategory = async (req: Request, res: Response) => {
  try {
    const { category } = req.params;
    const services = await serviceService.getServicesByCategory(category);
    res.status(200).json(services);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};
