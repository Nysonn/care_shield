import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const createSurveyTicket = async (userId: string, data: any) => {
  const { symptoms, severity, notes } = data;

  const ticket = await prisma.surveyTicket.create({
    data: {
      symptoms,
      severity,
      notes,
      user: {
        connect: { id: userId }
      }
    },
  });

  return ticket;
};

export const getSurveyTickets = async (userId: string) => {
  return await prisma.surveyTicket.findMany({ where: { userId } });
};
