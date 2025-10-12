import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getServices = async () => {
  return await prisma.service.findMany({
    orderBy: { name: 'asc' },
  });
};

export const getServiceById = async (id: string) => {
  return await prisma.service.findUnique({
    where: { id },
  });
};

export const getServicesByCategory = async (category: string) => {
  return await prisma.service.findMany({
    where: { category },
    orderBy: { name: 'asc' },
  });
};
