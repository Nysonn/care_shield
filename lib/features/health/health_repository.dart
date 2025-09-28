import 'package:dio/dio.dart';
import 'models/health_center.dart';
import 'package:care_shield/services/api_client.dart';

class HealthRepository {
  final ApiClient apiClient;

  HealthRepository({required this.apiClient});

  Future<List<HealthCenter>> getHealthCenters() async {
    try {
      final response = await apiClient.dio.get('/health-centers');
      return (response.data as List).map((hc) => HealthCenter.fromMap(hc)).toList();
    } catch (e) {
      return [];
    }
  }
}
