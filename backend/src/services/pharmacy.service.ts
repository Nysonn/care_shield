import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

interface GetPharmaciesOptions {
  page?: number;
  limit?: number;
  searchQuery?: string;
}

export const getPharmacies = async (options: GetPharmaciesOptions = {}) => {
  const { page = 1, limit = 10, searchQuery } = options;
  const skip = (page - 1) * limit;

  const where = searchQuery
    ? {
        OR: [
          { name: { contains: searchQuery, mode: 'insensitive' as any } },
          { address: { contains: searchQuery, mode: 'insensitive' as any } },
        ],
      }
    : {};

  const [pharmacies, total] = await Promise.all([
    prisma.pharmacy.findMany({
      where,
      skip,
      take: limit,
      orderBy: { name: 'asc' },
    }),
    prisma.pharmacy.count({ where }),
  ]);

  return {
    pharmacies,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

export const getPharmacyById = async (id: string) => {
  return await prisma.pharmacy.findUnique({
    where: { id },
  });
};

interface GetPharmacyDrugsOptions {
  pharmacyId: string;
  page?: number;
  limit?: number;
  searchQuery?: string;
  category?: string;
}

export const getPharmacyDrugs = async (options: GetPharmacyDrugsOptions) => {
  const { pharmacyId, page = 1, limit = 20, searchQuery, category } = options;
  const skip = (page - 1) * limit;

  const drugWhere: any = {};
  if (searchQuery) {
    drugWhere.OR = [
      { name: { contains: searchQuery, mode: 'insensitive' as any } },
      { description: { contains: searchQuery, mode: 'insensitive' as any } },
    ];
  }
  if (category) {
    drugWhere.category = category;
  }

  const where: any = {
    pharmacyId,
    isAvailable: true,
  };

  if (Object.keys(drugWhere).length > 0) {
    where.drug = drugWhere;
  }

  const [pharmacyDrugs, total] = await Promise.all([
    prisma.pharmacyDrug.findMany({
      where,
      include: {
        drug: true,
      },
      skip,
      take: limit,
      orderBy: { drug: { name: 'asc' } },
    }),
    prisma.pharmacyDrug.count({ where }),
  ]);

  return {
    drugs: pharmacyDrugs,
    pagination: {
      page,
      limit,
      total,
      totalPages: Math.ceil(total / limit),
    },
  };
};

export const getPharmacyServices = async (pharmacyId: string) => {
  return await prisma.pharmacyService.findMany({
    where: {
      pharmacyId,
      isAvailable: true,
    },
    include: {
      service: true,
    },
    orderBy: {
      service: { name: 'asc' },
    },
  });
};

export const searchPharmaciesByDrug = async (drugName: string) => {
  return await prisma.pharmacy.findMany({
    where: {
      pharmacyDrugs: {
        some: {
          isAvailable: true,
          drug: {
            name: {
              contains: drugName,
              mode: 'insensitive' as any,
            },
          },
        },
      },
    },
    include: {
      pharmacyDrugs: {
        where: {
          isAvailable: true,
          drug: {
            name: {
              contains: drugName,
              mode: 'insensitive' as any,
            },
          },
        },
        include: {
          drug: true,
        },
      },
    },
  });
};

export const searchDrugsAcrossPharmacies = async (drugName: string) => {
  return await prisma.pharmacyDrug.findMany({
    where: {
      isAvailable: true,
      drug: {
        name: {
          contains: drugName,
          mode: 'insensitive' as any,
        },
      },
    },
    include: {
      drug: true,
      pharmacy: true,
    },
    orderBy: [
      { drug: { name: 'asc' } },
      { price: 'asc' },
    ],
  });
};
