import { Request, Response } from 'express';
import * as pharmacyService from '../services/pharmacy.service.js';

export const getPharmacies = async (req: Request, res: Response) => {
  try {
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 10;
    const searchQuery = req.query.q as string;

    const result = await pharmacyService.getPharmacies({ page, limit, searchQuery });
    res.status(200).json(result);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const getPharmacyById = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const pharmacy = await pharmacyService.getPharmacyById(id);
    
    if (!pharmacy) {
      return res.status(404).json({ message: 'Pharmacy not found' });
    }
    
    res.status(200).json(pharmacy);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const getPharmacyDrugs = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const page = parseInt(req.query.page as string) || 1;
    const limit = parseInt(req.query.limit as string) || 20;
    const searchQuery = req.query.q as string;
    const category = req.query.category as string;

    const result = await pharmacyService.getPharmacyDrugs({
      pharmacyId: id,
      page,
      limit,
      searchQuery,
      category,
    });

    res.status(200).json(result);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const getPharmacyServices = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const services = await pharmacyService.getPharmacyServices(id);
    res.status(200).json(services);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const searchPharmacies = async (req: Request, res: Response) => {
  try {
    const drugName = req.query.drug as string;
    
    if (!drugName) {
      return res.status(400).json({ message: 'Drug name is required' });
    }

    const pharmacies = await pharmacyService.searchPharmaciesByDrug(drugName);
    res.status(200).json(pharmacies);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};

export const searchDrugs = async (req: Request, res: Response) => {
  try {
    const drugName = req.query.q as string;
    
    if (!drugName) {
      return res.status(400).json({ message: 'Search query is required' });
    }

    const drugs = await pharmacyService.searchDrugsAcrossPharmacies(drugName);
    res.status(200).json(drugs);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};
