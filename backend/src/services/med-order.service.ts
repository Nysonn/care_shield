import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export const createMedOrder = async (userId: string, data: any) => {
  const { stage, location, eta, totalAmount, deliveryFee, drugs, paymentId } = data;

  const order = await prisma.medOrder.create({
    data: {
      stage,
      location,
      eta,
      totalAmount,
      deliveryFee,
      userId,
      drugs: {
        connect: drugs.map((id: string) => ({ id }))
      },
      paymentId,
    },
  });

  return order;
};

export const getMedOrders = async (userId: string) => {
  return await prisma.medOrder.findMany({
    where: { userId },
    include: { drugs: true, payment: true },
  });
};
