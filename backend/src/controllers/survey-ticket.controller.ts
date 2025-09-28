import { Request, Response } from 'express';
import * as surveyTicketService from '../services/survey-ticket.service.js';
import Joi from 'joi';

const createSurveyTicketSchema = Joi.object({
  symptoms: Joi.array().items(Joi.string()).required(),
  severity: Joi.string().required(),
  notes: Joi.string().optional(),
});

export const createSurveyTicket = async (req: any, res: Response) => {
  try {
    const { error, value } = createSurveyTicketSchema.validate(req.body);
    if (error) {
      return res.status(400).json({ message: error.details[0].message });
    }

  const ticket = await surveyTicketService.createSurveyTicket(req.user.userId, value);
    res.status(201).json(ticket);
  } catch (error: any) {
    res.status(400).json({ message: error.message });
  }
};

export const getSurveyTickets = async (req: any, res: Response) => {
  try {
  const tickets = await surveyTicketService.getSurveyTickets(req.user.userId);
    res.status(200).json(tickets);
  } catch (error: any) {
    res.status(500).json({ message: error.message });
  }
};
