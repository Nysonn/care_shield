import { Request, Response } from 'express';
import * as drugService from '../services/drug.service.js';

export const getDrugs = async (req: Request, res: Response) => {
  try {
    const drugs = await drugService.getDrugs();
    res.status(200).json(drugs);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const getDrugById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const drug = await drugService.getDrugById(id);
    if (!drug) {
      return res.status(404).json({ message: 'Drug not found' });
    }
    res.status(200).json(drug);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};
