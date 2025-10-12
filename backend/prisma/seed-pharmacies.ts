import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting pharmacy system seed...');

  // Step 1: Archive existing orders
  console.log('📦 Archiving existing orders...');
  const existingOrders = await prisma.medOrder.findMany({
    include: {
      drugs: true,
      payment: true,
      user: true,
    },
  });

  for (const order of existingOrders) {
    await prisma.archivedOrder.create({
      data: {
        originalId: order.id,
        stage: order.stage,
        location: order.location,
        createdAt: order.createdAt,
        eta: order.eta,
        totalAmount: order.totalAmount,
        deliveryFee: order.deliveryFee,
        userId: order.userId,
        orderData: JSON.parse(JSON.stringify(order)),
      },
    });
  }

  // Delete existing orders (they're now archived)
  await prisma.medOrder.deleteMany({});
  console.log(`✅ Archived ${existingOrders.length} orders`);

  // Step 2: Create Mbarara pharmacies
  console.log('🏥 Creating Mbarara pharmacies...');
  const pharmacies = await Promise.all([
    prisma.pharmacy.create({
      data: {
        name: 'ABC Pharmacy',
        address: 'Plot 14, High Street, Mbarara City',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'Health First Pharmacy',
        address: 'Katete Road, Near Mbarara Regional Referral Hospital',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'MedPlus Pharmacy',
        address: 'Mbaguta Way, Opposite Bank of Africa',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'Care & Cure Pharmacy',
        address: 'Nkore Place, Ground Floor',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'City Pharmacy Mbarara',
        address: 'Stanley Road, Mbarara Central Market Area',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'Wellness Pharmacy',
        address: 'Bananuka Drive, Near Mbarara University',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'LifeCare Pharmacy',
        address: 'Kamukuzi Hill, Mbarara Municipality',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'Trusted Meds Pharmacy',
        address: 'Ruharo Road, Next to Agip Petrol Station',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'Guardian Pharmacy',
        address: 'Rwampara Avenue, Opposite Mbarara Bus Park',
        district: 'Mbarara',
      },
    }),
    prisma.pharmacy.create({
      data: {
        name: 'Premier Health Pharmacy',
        address: 'Kabale Road, Near Mbarara Town Hall',
        district: 'Mbarara',
      },
    }),
  ]);

  console.log(`✅ Created ${pharmacies.length} pharmacies`);

  // Step 3: Create services catalog
  console.log('💉 Creating services catalog...');
  const services = await Promise.all([
    prisma.service.create({
      data: {
        name: 'HIV Testing',
        description: 'Confidential HIV screening and testing service',
        category: 'Testing',
      },
    }),
    prisma.service.create({
      data: {
        name: 'Counseling',
        description: 'Professional health counseling and support',
        category: 'Counseling',
      },
    }),
    prisma.service.create({
      data: {
        name: 'Blood Pressure Check',
        description: 'Blood pressure measurement and monitoring',
        category: 'Health Check',
      },
    }),
    prisma.service.create({
      data: {
        name: 'Blood Sugar Testing',
        description: 'Blood glucose level testing and monitoring',
        category: 'Testing',
      },
    }),
    prisma.service.create({
      data: {
        name: 'Vaccinations',
        description: 'Immunization and vaccination services',
        category: 'Immunization',
      },
    }),
    prisma.service.create({
      data: {
        name: 'Prescription Consultation',
        description: 'Professional prescription review and consultation',
        category: 'Consultation',
      },
    }),
    prisma.service.create({
      data: {
        name: 'Home Delivery',
        description: 'Medication delivery to your doorstep',
        category: 'Delivery',
      },
    }),
    prisma.service.create({
      data: {
        name: '24/7 Emergency Service',
        description: 'Round-the-clock emergency pharmaceutical service',
        category: 'Emergency',
      },
    }),
  ]);

  console.log(`✅ Created ${services.length} services`);

  // Step 4: Get all existing drugs
  console.log('💊 Fetching existing drugs...');
  const drugs = await prisma.drug.findMany();
  console.log(`📋 Found ${drugs.length} drugs to distribute to pharmacies`);

  // Step 5: Link drugs to all pharmacies with varying prices
  console.log('🔗 Linking drugs to pharmacies with custom pricing...');
  let pharmacyDrugCount = 0;

  for (const pharmacy of pharmacies) {
    for (const drug of drugs) {
      // Generate slightly different prices for each pharmacy (±10% variance)
      const priceVariance = 0.9 + Math.random() * 0.2; // 0.9 to 1.1
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

  console.log(`✅ Created ${pharmacyDrugCount} pharmacy-drug relationships`);

  // Step 6: Link services to pharmacies with pricing
  console.log('🔗 Linking services to pharmacies...');
  let pharmacyServiceCount = 0;

  // Service pricing (in UGX)
  const servicePricing: { [key: string]: number } = {
    'HIV Testing': 15000,
    'Counseling': 20000,
    'Blood Pressure Check': 5000,
    'Blood Sugar Testing': 8000,
    'Vaccinations': 25000,
    'Prescription Consultation': 10000,
    'Home Delivery': 5000,
    '24/7 Emergency Service': 0, // Free service indicator
  };

  for (const pharmacy of pharmacies) {
    for (const service of services) {
      // Some pharmacies might not offer all services
      // Let's make 80% of services available per pharmacy
      const isAvailable = Math.random() > 0.2;

      const basePrice = servicePricing[service.name] || 10000;
      // Add slight price variance per pharmacy (±5%)
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

  console.log(`✅ Created ${pharmacyServiceCount} pharmacy-service relationships`);

  // Summary
  console.log('\n🎉 Pharmacy system seed completed successfully!');
  console.log('═══════════════════════════════════════════════');
  console.log(`📦 Archived Orders: ${existingOrders.length}`);
  console.log(`🏥 Pharmacies Created: ${pharmacies.length}`);
  console.log(`💉 Services Created: ${services.length}`);
  console.log(`💊 Drugs Available: ${drugs.length}`);
  console.log(`🔗 Pharmacy-Drug Links: ${pharmacyDrugCount}`);
  console.log(`🔗 Pharmacy-Service Links: ${pharmacyServiceCount}`);
  console.log('═══════════════════════════════════════════════');
}

main()
  .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
