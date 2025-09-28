import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const getDrugs = async () => {
  return await prisma.drug.findMany();
};

export const getDrugById = async (id: string) => {
  return await prisma.drug.findUnique({
    where: { id },
  });
};
