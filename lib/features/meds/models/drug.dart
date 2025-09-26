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
}
