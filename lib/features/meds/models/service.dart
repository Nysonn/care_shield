class Service {
  final String id;
  final String name;
  final String description;
  final String category;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
    };
  }
}

class PharmacyService {
  final String id;
  final String pharmacyId;
  final Service service;
  final double price;
  final bool isAvailable;

  PharmacyService({
    required this.id,
    required this.pharmacyId,
    required this.service,
    required this.price,
    required this.isAvailable,
  });

  factory PharmacyService.fromMap(Map<String, dynamic> map) {
    return PharmacyService(
      id: map['id'] as String,
      pharmacyId: map['pharmacyId'] as String,
      service: Service.fromMap(map['service'] as Map<String, dynamic>),
      price: (map['price'] as num).toDouble(),
      isAvailable: map['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pharmacyId': pharmacyId,
      'service': service.toMap(),
      'price': price,
      'isAvailable': isAvailable,
    };
  }
}

class OrderService {
  final Service service;
  final int quantity;
  final double price;

  OrderService({
    required this.service,
    required this.quantity,
    required this.price,
  });

  factory OrderService.fromMap(Map<String, dynamic> map) {
    return OrderService(
      service: Service.fromMap(map['service'] as Map<String, dynamic>),
      quantity: map['quantity'] as int? ?? 1,
      price: (map['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'service': service.toMap(), 'quantity': quantity, 'price': price};
  }
}
