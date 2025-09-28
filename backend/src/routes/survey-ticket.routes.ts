import { Router } from 'express';
import { createSurveyTicket, getSurveyTickets } from '../controllers/survey-ticket.controller.js';
import { authMiddleware } from '../middlewares/auth.middleware.js';

const router = Router();

router.post('/', authMiddleware, createSurveyTicket);
router.get('/', authMiddleware, getSurveyTickets);

export default router;
