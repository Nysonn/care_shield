class Drug {
  final String id;
  final String name;
  final String description;
  final String dosage; // e.g., '50mg daily'
  final double price;
  final String currency;
  final String category;
  final bool requiresPrescription;

  Drug({
    required this.id,
    required this.name,
    required this.description,
    required this.dosage,
    required this.price,
    this.currency = 'UGX',
    required this.category,
    this.requiresPrescription = false,
  });

  factory Drug.fromMap(Map<String, dynamic> map) {
    return Drug(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      dosage: map['dosage'],
      price: map['price'].toDouble(),
      currency: map['currency'] ?? 'UGX',
      category: map['category'],
      requiresPrescription: map['requiresPrescription'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dosage': dosage,
      'price': price,
      'currency': currency,
      'category': category,
      'requiresPrescription': requiresPrescription,
    };
  }
}
