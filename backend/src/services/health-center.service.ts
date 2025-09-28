import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getHealthCenters = async () => {
  return await prisma.healthCenter.findMany();
};
