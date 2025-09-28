import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  await prisma.drug.createMany({
    data: [
      {
        name: 'Tenofovir/Lamivudine/Efavirenz (TLE)',
        description: 'Common first-line regimen',
        dosage: '1 tablet daily',
        price: 50000,
        category: 'HIV Medications',
        requiresPrescription: true,
      },
      {
        name: 'Tenofovir/Lamivudine/Dolutegravir (TLD)',
        description: 'Preferred regimen',
        dosage: '1 tablet daily',
        price: 55000,
        category: 'HIV Medications',
        requiresPrescription: true,
      },
      {
        name: 'Abacavir/Lamivudine (ABC/3TC)',
        description: 'Alternative backbone',
        dosage: '1 tablet daily',
        price: 48000,
        category: 'HIV Medications',
        requiresPrescription: true,
      },
      {
        name: 'AZT/3TC/NVP',
        description: 'Older regimen',
        dosage: 'As prescribed',
        price: 42000,
        category: 'HIV Medications',
        requiresPrescription: true,
      },
      {
        name: 'Durex Condoms (12 pack)',
        description: 'Premium latex condoms for safe sex.',
        dosage: 'Use as needed',
        price: 12000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: false,
      },
      {
        name: 'Trojan Condoms (12 pack)',
        description: 'Trusted protection, lubricated.',
        dosage: 'Use as needed',
        price: 11000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: false,
      },
      {
        name: 'Lifestyle Condoms (12 pack)',
        description: 'Affordable, reliable condoms.',
        dosage: 'Use as needed',
        price: 9000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: false,
      },
      {
        name: 'Birth Control Pills (Monthly)',
        description: 'Oral contraceptive, various types available.',
        dosage: '1 tablet daily',
        price: 20000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: true,
      },
      {
        name: 'Emergency Contraceptive Pills',
        description: 'Take within 72 hours after unprotected sex.',
        dosage: 'As prescribed',
        price: 15000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: false,
      },
      {
        name: 'Female Condoms (3 pack)',
        description: 'Internal barrier protection for women.',
        dosage: 'Use as needed',
        price: 8000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: false,
      },
      {
        name: 'Contraceptive Injections',
        description: 'Long-acting birth control, administered monthly.',
        dosage: 'Monthly injection',
        price: 25000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: true,
      },
      {
        name: 'IUDs (Consultation Required)',
        description: 'Long-term birth control, requires medical consultation.',
        dosage: 'As prescribed',
        price: 120000,
        category: 'Sexual Health & Contraceptives',
        requiresPrescription: true,
      },
      {
        name: 'HIV Self-Test Kit',
        description: 'Easy-to-use kit for home HIV testing.',
        dosage: 'Single use',
        price: 25000,
        category: 'HIV Testing & Prevention',
        requiresPrescription: false,
      },
      {
        name: 'Rapid HIV Test Strips',
        description: 'Quick results for HIV screening.',
        dosage: 'Single use',
        price: 18000,
        category: 'HIV Testing & Prevention',
        requiresPrescription: false,
      },
      {
        name: 'PrEP Medication (Monthly)',
        description: 'Pre-exposure prophylaxis for HIV prevention.',
        dosage: '1 tablet daily',
        price: 35000,
        category: 'HIV Testing & Prevention',
        requiresPrescription: true,
      },
      {
        name: 'PEP Medication (Emergency)',
        description: 'Post-exposure prophylaxis, start within 72 hours.',
        dosage: 'As prescribed',
        price: 40000,
        category: 'HIV Testing & Prevention',
        requiresPrescription: true,
      },
      {
        name: 'Pregnancy Test Kit',
        description: 'Accurate home pregnancy test.',
        dosage: 'Single use',
        price: 12000,
        category: 'General Health Products',
        requiresPrescription: false,
      },
      {
        name: 'Blood Pressure Monitor',
        description: 'Digital device for home blood pressure checks.',
        dosage: 'Use as needed',
        price: 85000,
        category: 'General Health Products',
        requiresPrescription: false,
      },
      {
        name: 'Thermometer',
        description: 'Digital thermometer for fever monitoring.',
        dosage: 'Use as needed',
        price: 18000,
        category: 'General Health Products',
        requiresPrescription: false,
      },
      {
        name: 'First Aid Kit',
        description: 'Comprehensive kit for minor injuries.',
        dosage: 'Use as needed',
        price: 65000,
        category: 'General Health Products',
        requiresPrescription: false,
      },
      {
        name: 'Vitamins & Supplements',
        description: 'Daily multivitamins and supplements.',
        dosage: 'As prescribed',
        price: 22000,
        category: 'General Health Products',
        requiresPrescription: false,
      },
  ],
  skipDuplicates: true,
  });

  await prisma.healthCenter.createMany({
    data: [
      {
        name: 'Mulago HIV Clinic',
        address: 'Mulago Hill, Kampala',
        distanceKm: 1.2,
        openHours: 'Mon-Fri 08:00-17:00',
        phone: '+256700000001',
      },
      {
        name: 'Kisenyi Health Centre',
        address: 'Kisenyi, Kampala',
        distanceKm: 2.1,
        openHours: 'Mon-Sat 09:00-16:00',
        phone: '+256700000002',
      },
      {
        name: 'Kampala Central Health Clinic',
        address: 'Central Kampala',
        distanceKm: 3.5,
        openHours: 'Mon-Fri 08:00-17:00',
        phone: '+256700000003',
      },
      {
        name: 'Nakuru Community Health',
        address: 'Nakuru Lane',
        distanceKm: 4.0,
        openHours: 'Tue-Sun 09:00-15:00',
        phone: '+256700000004',
      },
  ],
  skipDuplicates: true,
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
