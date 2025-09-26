import 'package:flutter/material.dart';
import '../models/drug.dart';
import '../models/payment_models.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import 'package:care_shield/services/local_storage_service.dart';

class MedOrder {
  final String id;
  final String stage;
  final List<Drug> drugs;
  final String location;
  final DateTime createdAt;
  final String eta;
  final DeliveryOption? deliveryOption;
  final PaymentInfo? paymentInfo;
  final double totalAmount;
  final double deliveryFee;

  MedOrder({
    required this.id,
    required this.stage,
    required this.drugs,
    required this.location,
    required this.createdAt,
    required this.eta,
    this.deliveryOption,
    this.paymentInfo,
    required this.totalAmount,
    required this.deliveryFee,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'stage': stage,
    'drugs': drugs
        .map(
          (d) => {
            'id': d.id,
            'name': d.name,
            'dosage': d.dosage,
            'price': d.price,
            'category': d.category,
          },
        )
        .toList(),
    'location': location,
    'createdAt': createdAt.toIso8601String(),
    'eta': eta,
    'deliveryOption': deliveryOption?.id,
    'paymentInfo': paymentInfo?.toMap(),
    'totalAmount': totalAmount,
    'deliveryFee': deliveryFee,
  };

  static MedOrder fromMap(Map map) {
    final drugsList = (map['drugs'] as List)
        .map(
          (d) => Drug(
            id: d['id'],
            name: d['name'],
            description: '',
            dosage: d['dosage'],
            price: d['price']?.toDouble() ?? 0.0,
            category: d['category'] ?? 'Unknown',
          ),
        )
        .toList();

    DeliveryOption? deliveryOption;
    if (map['deliveryOption'] != null) {
      deliveryOption = DeliveryOption.getDeliveryOptions().firstWhere(
        (option) => option.id == map['deliveryOption'],
        orElse: () => DeliveryOption.getDeliveryOptions().first,
      );
    }

    PaymentInfo? paymentInfo;
    if (map['paymentInfo'] != null) {
      paymentInfo = PaymentInfo.fromMap(
        Map<String, dynamic>.from(map['paymentInfo']),
      );
    }

    return MedOrder(
      id: map['id'],
      stage: map['stage'],
      drugs: drugsList,
      location: map['location'],
      createdAt: DateTime.parse(map['createdAt']),
      eta: map['eta'],
      deliveryOption: deliveryOption,
      paymentInfo: paymentInfo,
      totalAmount: map['totalAmount']?.toDouble() ?? 0.0,
      deliveryFee: map['deliveryFee']?.toDouble() ?? 0.0,
    );
  }
}

class MedsProvider extends ChangeNotifier {
  final List<Drug> _drugs = [
    // HIV Medications (existing)
    Drug(
      id: 'd1',
      name: 'Tenofovir/Lamivudine/Efavirenz (TLE)',
      description: 'Common first-line regimen',
      dosage: '1 tablet daily',
      price: 50000,
      category: 'HIV Medications',
      requiresPrescription: true,
    ),
    Drug(
      id: 'd2',
      name: 'Tenofovir/Lamivudine/Dolutegravir (TLD)',
      description: 'Preferred regimen',
      dosage: '1 tablet daily',
      price: 55000,
      category: 'HIV Medications',
      requiresPrescription: true,
    ),
    Drug(
      id: 'd3',
      name: 'Abacavir/Lamivudine (ABC/3TC)',
      description: 'Alternative backbone',
      dosage: '1 tablet daily',
      price: 48000,
      category: 'HIV Medications',
      requiresPrescription: true,
    ),
    Drug(
      id: 'd4',
      name: 'AZT/3TC/NVP',
      description: 'Older regimen',
      dosage: 'As prescribed',
      price: 42000,
      category: 'HIV Medications',
      requiresPrescription: true,
    ),

    // Sexual Health & Contraceptives
    Drug(
      id: 'p1',
      name: 'Durex Condoms (12 pack)',
      description: 'Premium latex condoms for safe sex.',
      dosage: 'Use as needed',
      price: 12000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: false,
    ),
    Drug(
      id: 'p2',
      name: 'Trojan Condoms (12 pack)',
      description: 'Trusted protection, lubricated.',
      dosage: 'Use as needed',
      price: 11000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: false,
    ),
    Drug(
      id: 'p3',
      name: 'Lifestyle Condoms (12 pack)',
      description: 'Affordable, reliable condoms.',
      dosage: 'Use as needed',
      price: 9000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: false,
    ),
    Drug(
      id: 'p4',
      name: 'Birth Control Pills (Monthly)',
      description: 'Oral contraceptive, various types available.',
      dosage: '1 tablet daily',
      price: 20000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: true,
    ),
    Drug(
      id: 'p5',
      name: 'Emergency Contraceptive Pills',
      description: 'Take within 72 hours after unprotected sex.',
      dosage: 'As prescribed',
      price: 15000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: false,
    ),
    Drug(
      id: 'p6',
      name: 'Female Condoms (3 pack)',
      description: 'Internal barrier protection for women.',
      dosage: 'Use as needed',
      price: 8000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: false,
    ),
    Drug(
      id: 'p7',
      name: 'Contraceptive Injections',
      description: 'Long-acting birth control, administered monthly.',
      dosage: 'Monthly injection',
      price: 25000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: true,
    ),
    Drug(
      id: 'p8',
      name: 'IUDs (Consultation Required)',
      description: 'Long-term birth control, requires medical consultation.',
      dosage: 'As prescribed',
      price: 120000,
      category: 'Sexual Health & Contraceptives',
      requiresPrescription: true,
    ),

    // HIV Testing & Prevention
    Drug(
      id: 'h1',
      name: 'HIV Self-Test Kit',
      description: 'Easy-to-use kit for home HIV testing.',
      dosage: 'Single use',
      price: 25000,
      category: 'HIV Testing & Prevention',
      requiresPrescription: false,
    ),
    Drug(
      id: 'h2',
      name: 'Rapid HIV Test Strips',
      description: 'Quick results for HIV screening.',
      dosage: 'Single use',
      price: 18000,
      category: 'HIV Testing & Prevention',
      requiresPrescription: false,
    ),
    Drug(
      id: 'h3',
      name: 'PrEP Medication (Monthly)',
      description: 'Pre-exposure prophylaxis for HIV prevention.',
      dosage: '1 tablet daily',
      price: 35000,
      category: 'HIV Testing & Prevention',
      requiresPrescription: true,
    ),
    Drug(
      id: 'h4',
      name: 'PEP Medication (Emergency)',
      description: 'Post-exposure prophylaxis, start within 72 hours.',
      dosage: 'As prescribed',
      price: 40000,
      category: 'HIV Testing & Prevention',
      requiresPrescription: true,
    ),

    // General Health Products
    Drug(
      id: 'g1',
      name: 'Pregnancy Test Kit',
      description: 'Accurate home pregnancy test.',
      dosage: 'Single use',
      price: 12000,
      category: 'General Health Products',
      requiresPrescription: false,
    ),
    Drug(
      id: 'g2',
      name: 'Blood Pressure Monitor',
      description: 'Digital device for home blood pressure checks.',
      dosage: 'Use as needed',
      price: 85000,
      category: 'General Health Products',
      requiresPrescription: false,
    ),
    Drug(
      id: 'g3',
      name: 'Thermometer',
      description: 'Digital thermometer for fever monitoring.',
      dosage: 'Use as needed',
      price: 18000,
      category: 'General Health Products',
      requiresPrescription: false,
    ),
    Drug(
      id: 'g4',
      name: 'First Aid Kit',
      description: 'Comprehensive kit for minor injuries.',
      dosage: 'Use as needed',
      price: 65000,
      category: 'General Health Products',
      requiresPrescription: false,
    ),
    Drug(
      id: 'g5',
      name: 'Vitamins & Supplements',
      description: 'Daily multivitamins and supplements.',
      dosage: 'As prescribed',
      price: 22000,
      category: 'General Health Products',
      requiresPrescription: false,
    ),
  ];

  List<Drug> get drugs => List.unmodifiable(_drugs);

  static const _ordersBox = 'med_orders_box';

  MedsProvider();

  Future<void> init() async {
    await LocalStorageService.openEncryptedBox(_ordersBox);
  }

  Future<void> placeOrder({
    required String stage,
    required List<Drug> drugs,
    required String location,
    DeliveryOption? deliveryOption,
    PaymentMethod? paymentMethod,
  }) async {
    final id = const Uuid().v4();
    final createdAt = DateTime.now();
    final eta = deliveryOption?.eta ?? '2-4 days';

    // Calculate total amount
    final productsTotal = drugs.fold<double>(
      0,
      (sum, drug) => sum + drug.price,
    );
    final deliveryFee = deliveryOption?.price ?? 0.0;
    final totalAmount = productsTotal + deliveryFee;

    // Create payment info (dummy payment for now)
    PaymentInfo? paymentInfo;
    if (paymentMethod != null) {
      paymentInfo = PaymentInfo(
        method: paymentMethod,
        status: PaymentStatus.completed, // Simulate successful payment
        amount: totalAmount,
        referenceCode: 'REF-${id.substring(0, 8).toUpperCase()}',
        processedAt: DateTime.now(),
      );
    }

    final order = MedOrder(
      id: id,
      stage: stage,
      drugs: drugs,
      location: location,
      createdAt: createdAt,
      eta: eta,
      deliveryOption: deliveryOption,
      paymentInfo: paymentInfo,
      totalAmount: totalAmount,
      deliveryFee: deliveryFee,
    );
    final box = Hive.box(_ordersBox);
    await box.put(id, order.toMap());
    notifyListeners();
  }

  Future<List<MedOrder>> fetchOrders() async {
    final box = Hive.box(_ordersBox);
    final out = <MedOrder>[];
    for (final val in box.values) {
      out.add(MedOrder.fromMap(Map<String, dynamic>.from(val)));
    }
    return out;
  }
}
