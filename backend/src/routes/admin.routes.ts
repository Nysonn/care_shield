import { Router, Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const router = Router();
const prisma = new PrismaClient();

// Middleware to check for admin secret
const adminAuth = (req: Request, res: Response, next: Function) => {
  const adminSecret = req.headers['x-admin-secret'];
  
  if (!adminSecret || adminSecret !== process.env.ADMIN_SECRET) {
    return res.status(403).json({ error: 'Unauthorized' });
  }
  
  next();
};

// Seed drugs and health centers
router.post('/seed-base', adminAuth, async (req: Request, res: Response) => {
  try {
    // Seed drugs
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

    // Seed health centers
    await prisma.healthCenter.createMany({
      data: [
        {
          name: 'Mulago HIV Clinic',
          address: 'Mulago Hill, Mbarara',
          distanceKm: 1.2,
          openHours: 'Mon-Fri 08:00-17:00',
          phone: '+256700000001',
        },
        {
          name: 'Kisenyi Health Centre',
          address: 'Kisenyi, Mbarara',
          distanceKm: 2.1,
          openHours: 'Mon-Sat 09:00-16:00',
          phone: '+256700000002',
        },
        {
          name: 'Mbarara Central Health Clinic',
          address: 'Central Mbarara',
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

    const drugCount = await prisma.drug.count();
    const healthCenterCount = await prisma.healthCenter.count();

    res.json({
      success: true,
      message: 'Base data seeded successfully',
      data: {
        drugs: drugCount,
        healthCenters: healthCenterCount,
      },
    });
  } catch (error: any) {
    console.error('Seed error:', error);
    res.status(500).json({ error: error.message });
  }
});

// Seed pharmacies and their relationships
router.post('/seed-pharmacies', adminAuth, async (req: Request, res: Response) => {
  try {
    // Create pharmacies
    const pharmacyNames = [
      { name: 'ABC Pharmacy', address: 'Plot 14, High Street, Mbarara City', district: 'Mbarara' },
      { name: 'Health First Pharmacy', address: 'Katete Road, Near Mbarara Regional Referral Hospital', district: 'Mbarara' },
      { name: 'MedPlus Pharmacy', address: 'Mbaguta Way, Opposite Bank of Africa', district: 'Mbarara' },
      { name: 'Care & Cure Pharmacy', address: 'Nkore Place, Ground Floor', district: 'Mbarara' },
      { name: 'City Pharmacy Mbarara', address: 'Stanley Road, Mbarara Central Market Area', district: 'Mbarara' },
      { name: 'Wellness Pharmacy', address: 'Bananuka Drive, Near Mbarara University', district: 'Mbarara' },
      { name: 'LifeCare Pharmacy', address: 'Kamukuzi Hill, Mbarara Municipality', district: 'Mbarara' },
      { name: 'Trusted Meds Pharmacy', address: 'Ruharo Road, Next to Agip Petrol Station', district: 'Mbarara' },
      { name: 'Guardian Pharmacy', address: 'Rwampara Avenue, Opposite Mbarara Bus Park', district: 'Mbarara' },
      { name: 'Premier Health Pharmacy', address: 'Kabale Road, Near Mbarara Town Hall', district: 'Mbarara' },
    ];

    const pharmacies = await Promise.all(
      pharmacyNames.map(p => prisma.pharmacy.create({ data: p }))
    );

    // Create services
    const serviceData = [
      { name: 'HIV Testing', description: 'Confidential HIV screening and testing service', category: 'Testing' },
      { name: 'Counseling', description: 'Professional health counseling and support', category: 'Counseling' },
      { name: 'Blood Pressure Check', description: 'Blood pressure measurement and monitoring', category: 'Health Check' },
      { name: 'Blood Sugar Testing', description: 'Blood glucose level testing and monitoring', category: 'Testing' },
      { name: 'Vaccinations', description: 'Immunization and vaccination services', category: 'Immunization' },
      { name: 'Prescription Consultation', description: 'Professional prescription review and consultation', category: 'Consultation' },
      { name: 'Home Delivery', description: 'Medication delivery to your doorstep', category: 'Delivery' },
      { name: '24/7 Emergency Service', description: 'Round-the-clock emergency pharmaceutical service', category: 'Emergency' },
    ];

    const services = await Promise.all(
      serviceData.map(s => prisma.service.create({ data: s }))
    );

    // Get all drugs
    const drugs = await prisma.drug.findMany();

    // Link drugs to pharmacies
    let pharmacyDrugCount = 0;
    for (const pharmacy of pharmacies) {
      for (const drug of drugs) {
        const priceVariance = 0.9 + Math.random() * 0.2;
        const pharmacyPrice = Math.round(drug.price * priceVariance);

        await prisma.pharmacyDrug.create({
          data: {
            pharmacyId: pharmacy.id,
            drugId: drug.id,
            price: pharmacyPrice,
            isAvailable: true,
          },
        });
        pharmacyDrugCount++;
      }
    }

    // Link services to pharmacies
    const servicePricing: { [key: string]: number } = {
      'HIV Testing': 15000,
      'Counseling': 20000,
      'Blood Pressure Check': 5000,
      'Blood Sugar Testing': 8000,
      'Vaccinations': 25000,
      'Prescription Consultation': 10000,
      'Home Delivery': 5000,
      '24/7 Emergency Service': 0,
    };

    let pharmacyServiceCount = 0;
    for (const pharmacy of pharmacies) {
      for (const service of services) {
        const isAvailable = Math.random() > 0.2;
        const basePrice = servicePricing[service.name] || 10000;
        const priceVariance = 0.95 + Math.random() * 0.1;
        const pharmacyPrice = Math.round(basePrice * priceVariance);

        await prisma.pharmacyService.create({
          data: {
            pharmacyId: pharmacy.id,
            serviceId: service.id,
            price: pharmacyPrice,
            isAvailable,
          },
        });
        pharmacyServiceCount++;
      }
    }

    res.json({
      success: true,
      message: 'Pharmacy system seeded successfully',
      data: {
        pharmacies: pharmacies.length,
        services: services.length,
        drugs: drugs.length,
        pharmacyDrugLinks: pharmacyDrugCount,
        pharmacyServiceLinks: pharmacyServiceCount,
      },
    });
  } catch (error: any) {
    console.error('Seed error:', error);
    res.status(500).json({ error: error.message });
  }
});

export default router;
