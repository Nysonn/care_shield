import { Router } from 'express';
import { getDrugs, getDrugById } from '../controllers/drug.controller.js';

const router = Router();

router.get('/', getDrugs);
router.get('/:id', getDrugById);

export default router;
