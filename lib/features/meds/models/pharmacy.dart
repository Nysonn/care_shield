class Pharmacy {
  final String id;
  final String name;
  final String address;
  final String district;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    this.district = 'Mbarara',
  });

  factory Pharmacy.fromMap(Map<String, dynamic> map) {
    return Pharmacy(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      district: map['district'] as String? ?? 'Mbarara',
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'address': address, 'district': district};
  }
}
