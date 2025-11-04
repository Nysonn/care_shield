import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface CreateOrderData {
  pharmacyId: string;
  stage: string;
  location: string;
  eta: string;
  totalAmount: number;
  deliveryFee: number;
  drugs: Array<{ drugId: string; pharmacyDrugId?: string }>;
  services: Array<{ serviceId: string; pharmacyServiceId: string; quantity?: number }>;
  paymentId?: string;
}

export const createMedOrder = async (userId: string, data: CreateOrderData) => {
  const { pharmacyId, stage, location, eta, totalAmount, deliveryFee, drugs, services, paymentId } = data;

  // Validate that all drugs belong to the selected pharmacy
  if (drugs && drugs.length > 0) {
    const drugIds = drugs.map((d) => d.drugId);
    const pharmacyDrugs = await prisma.pharmacyDrug.findMany({
      where: {
        pharmacyId,
        drugId: { in: drugIds },
        isAvailable: true,
      },
    });

    if (pharmacyDrugs.length !== drugIds.length) {
      throw new Error('Some drugs are not available at the selected pharmacy');
    }
  }

  // Validate that all services belong to the selected pharmacy
  if (services && services.length > 0) {
    const serviceIds = services.map((s) => s.serviceId);
    const pharmacyServices = await prisma.pharmacyService.findMany({
      where: {
        pharmacyId,
        serviceId: { in: serviceIds },
        isAvailable: true,
      },
    });

    if (pharmacyServices.length !== serviceIds.length) {
      throw new Error('Some services are not available at the selected pharmacy');
    }
  }

  // Create the order with pharmacy, drugs, and services
  const order = await prisma.medOrder.create({
    data: {
      stage,
      location,
      eta,
      totalAmount,
      deliveryFee,
      status: 'pending', // Default status for new orders
      userId,
      pharmacyId,
      drugs: {
        connect: drugs.map((d) => ({ id: d.drugId })),
      },
      services: {
        create: services.map((s) => ({
          serviceId: s.serviceId,
          quantity: s.quantity || 1,
          price: 0, // Price will be fetched from pharmacyService
        })),
      },
      paymentId,
    },
    include: {
      drugs: true,
      services: {
        include: {
          service: true,
        },
      },
      pharmacy: true,
    },
  });

  // Update service prices from pharmacy services
  for (const orderService of order.services) {
    const pharmacyService = await prisma.pharmacyService.findFirst({
      where: {
        pharmacyId,
        serviceId: orderService.serviceId,
      },
    });

    if (pharmacyService) {
      await prisma.orderService.update({
        where: { id: orderService.id },
        data: { price: pharmacyService.price },
      });
    }
  }

  return order;
};

export const getMedOrders = async (userId: string) => {
  return await prisma.medOrder.findMany({
    where: { userId },
    include: {
      drugs: true,
      payment: true,
      pharmacy: true,
      services: {
        include: {
          service: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });
};
