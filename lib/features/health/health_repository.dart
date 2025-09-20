import 'models/health_center.dart';

class HealthRepository {
  static List<HealthCenter> getHealthCenters() {
    return [
      HealthCenter(
        id: 'hc_1',
        name: 'Mulago HIV Clinic',
        address: 'Mulago Hill, Kampala',
        distanceKm: 1.2,
        openHours: 'Mon-Fri 08:00-17:00',
        phone: '+256700000001',
      ),
      HealthCenter(
        id: 'hc_2',
        name: 'Kisenyi Health Centre',
        address: 'Kisenyi, Kampala',
        distanceKm: 2.1,
        openHours: 'Mon-Sat 09:00-16:00',
        phone: '+256700000002',
      ),
      HealthCenter(
        id: 'hc_3',
        name: 'Kampala Central Health Clinic',
        address: 'Central Kampala',
        distanceKm: 3.5,
        openHours: 'Mon-Fri 08:00-17:00',
        phone: '+256700000003',
      ),
      HealthCenter(
        id: 'hc_4',
        name: 'Nakuru Community Health',
        address: 'Nakuru Lane',
        distanceKm: 4.0,
        openHours: 'Tue-Sun 09:00-15:00',
        phone: '+256700000004',
      ),
    ];
  }
}
