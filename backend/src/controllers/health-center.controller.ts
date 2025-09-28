import { Request, Response } from 'express';
import * as healthCenterService from '../services/health-center.service.js';

export const getHealthCenters = async (req: Request, res: Response) => {
  try {
    const healthCenters = await healthCenterService.getHealthCenters();
    res.status(200).json(healthCenters);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};
