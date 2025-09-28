import { Router } from 'express';
import { getHealthCenters } from '../controllers/health-center.controller.js';

const router = Router();

router.get('/', getHealthCenters);

export default router;
