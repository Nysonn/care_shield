import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

/**
 * Get all pending orders (orders not yet accepted by any rider)
 */
export const getPendingOrders = async () => {
  return await prisma.medOrder.findMany({
    where: {
      status: 'pending',
    },
    include: {
      user: {
        select: {
          id: true,
          fullName: true,
          phone: true,
        },
      },
      drugs: {
        select: {
          id: true,
          name: true,
          description: true,
          dosage: true,
        },
      },
      pharmacy: {
        select: {
          id: true,
          name: true,
          address: true,
        },
      },
      services: {
        include: {
          service: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });
};

/**
 * Accept an order by a rider
 */
export const acceptOrder = async (riderId: string, orderId: string) => {
  // Check if order exists and is still pending
  const order = await prisma.medOrder.findUnique({
    where: { id: orderId },
  });

  if (!order) {
    throw new Error('Order not found');
  }

  if (order.status !== 'pending') {
    throw new Error('Order has already been accepted by another rider');
  }

  // Verify the user accepting is a rider
  const rider = await prisma.user.findUnique({
    where: { id: riderId },
  });

  if (!rider || rider.role !== 'rider') {
    throw new Error('Only riders can accept orders');
  }

  // Update order to accepted status and assign rider
  return await prisma.medOrder.update({
    where: { id: orderId },
    data: {
      status: 'accepted',
      riderId: riderId,
    },
    include: {
      user: {
        select: {
          id: true,
          fullName: true,
          phone: true,
        },
      },
      drugs: {
        select: {
          id: true,
          name: true,
          description: true,
          dosage: true,
        },
      },
      pharmacy: {
        select: {
          id: true,
          name: true,
          address: true,
        },
      },
      services: {
        include: {
          service: true,
        },
      },
    },
  });
};

/**
 * Get all accepted orders for a specific rider that haven't been delivered yet
 */
export const getMyAcceptedOrders = async (riderId: string) => {
  return await prisma.medOrder.findMany({
    where: {
      riderId: riderId,
      status: 'accepted',
    },
    include: {
      user: {
        select: {
          id: true,
          fullName: true,
          phone: true,
        },
      },
      drugs: {
        select: {
          id: true,
          name: true,
          description: true,
          dosage: true,
        },
      },
      pharmacy: {
        select: {
          id: true,
          name: true,
          address: true,
        },
      },
      services: {
        include: {
          service: true,
        },
      },
    },
    orderBy: { createdAt: 'desc' },
  });
};

/**
 * Mark an order as delivered
 */
export const markAsDelivered = async (riderId: string, orderId: string) => {
  // Check if order exists and belongs to this rider
  const order = await prisma.medOrder.findUnique({
    where: { id: orderId },
  });

  if (!order) {
    throw new Error('Order not found');
  }

  if (order.riderId !== riderId) {
    throw new Error('You can only mark your own orders as delivered');
  }

  if (order.status === 'delivered') {
    throw new Error('Order has already been marked as delivered');
  }

  // Update order status to delivered
  return await prisma.medOrder.update({
    where: { id: orderId },
    data: {
      status: 'delivered',
    },
    include: {
      user: {
        select: {
          id: true,
          fullName: true,
          phone: true,
        },
      },
      drugs: {
        select: {
          id: true,
          name: true,
          description: true,
          dosage: true,
        },
      },
      pharmacy: {
        select: {
          id: true,
          name: true,
          address: true,
        },
      },
      services: {
        include: {
          service: true,
        },
      },
    },
  });
};

/**
 * Get order history for a rider (all delivered orders)
 */
export const getOrderHistory = async (riderId: string) => {
  return await prisma.medOrder.findMany({
    where: {
      riderId: riderId,
      status: 'delivered',
    },
    include: {
      user: {
        select: {
          id: true,
          fullName: true,
          phone: true,
        },
      },
      drugs: {
        select: {
          id: true,
          name: true,
          description: true,
          dosage: true,
        },
      },
      pharmacy: {
        select: {
          id: true,
          name: true,
          address: true,
        },
      },
      services: {
        include: {
          service: true,
        },
      },
    },
    orderBy: { updatedAt: 'desc' },
  });
};
