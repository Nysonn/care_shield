class HealthCenter {
  final String id;
  final String name;
  final String address;
  final double distanceKm; // dummy distance
  final String openHours;
  final String phone;

  HealthCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.openHours,
    required this.phone,
  });

  factory HealthCenter.fromMap(Map<String, dynamic> map) {
    return HealthCenter(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      distanceKm: map['distanceKm'].toDouble(),
      openHours: map['openHours'],
      phone: map['phone'],
    );
  }
}
