import 'drug.dart';

class PharmacyDrug {
  final String id;
  final String pharmacyId;
  final Drug drug;
  final double price;
  final bool isAvailable;

  PharmacyDrug({
    required this.id,
    required this.pharmacyId,
    required this.drug,
    required this.price,
    required this.isAvailable,
  });

  factory PharmacyDrug.fromMap(Map<String, dynamic> map) {
    return PharmacyDrug(
      id: map['id'] as String,
      pharmacyId: map['pharmacyId'] as String,
      drug: Drug.fromMap(map['drug'] as Map<String, dynamic>),
      price: (map['price'] as num).toDouble(),
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'drug': drug.toMap(),
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}
