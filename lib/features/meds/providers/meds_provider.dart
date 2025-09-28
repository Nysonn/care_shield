import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/drug.dart';
import '../models/payment_models.dart';
import 'package:care_shield/services/api_client.dart';

class MedOrder {
  final String id;
  final String stage;
  final List<Drug> drugs;
  final String location;
  final DateTime createdAt;
  final String eta;
  final double totalAmount;
  final double deliveryFee;

  MedOrder({
    required this.id,
    required this.stage,
    required this.drugs,
    required this.location,
    required this.createdAt,
    required this.eta,
    required this.totalAmount,
    required this.deliveryFee,
  });

  factory MedOrder.fromMap(Map<String, dynamic> map) {
    return MedOrder(
      id: map['id'],
      stage: map['stage'],
      drugs: (map['drugs'] as List).map((d) => Drug.fromMap(d)).toList(),
      location: map['location'],
      createdAt: DateTime.parse(map['createdAt']),
      eta: map['eta'],
      totalAmount: map['totalAmount'].toDouble(),
      deliveryFee: map['deliveryFee'].toDouble(),
    );
  }

  get paymentInfo => null;

  get deliveryOption => null;
}

class MedsProvider extends ChangeNotifier {
  final ApiClient apiClient;
  List<Drug> _drugs = [];

  List<Drug> get drugs => List.unmodifiable(_drugs);

  MedsProvider({required this.apiClient});

  Future<void> init() async {
    print('MedsProvider: init started');
    await fetchDrugs();
    print('MedsProvider: init finished');
  }

  Future<void> fetchDrugs() async {
    print('MedsProvider: fetchDrugs started');
    try {
      final response = await apiClient.dio.get('/drugs');
      _drugs = (response.data as List).map((d) => Drug.fromMap(d)).toList();
      print('MedsProvider: fetchDrugs success, ${_drugs.length} drugs fetched');
      notifyListeners();
    } catch (e) {
      print('MedsProvider: fetchDrugs error: $e');
      // Handle error
    }
  }

  Future<void> placeOrder({
    required String stage,
    required List<Drug> drugs,
    required String location,
    DeliveryOption? deliveryOption,
    PaymentMethod? paymentMethod,
  }) async {
    try {
      final productsTotal = drugs.fold<double>(
        0,
        (sum, drug) => sum + drug.price,
      );
      final deliveryFee = deliveryOption?.price ?? 0.0;
      final totalAmount = productsTotal + deliveryFee;

      final response = await apiClient.dio.post(
        '/med-orders',
        data: {
          'stage': stage,
          'location': location,
          'eta': deliveryOption?.eta ?? '2-4 days',
          'totalAmount': totalAmount,
          'deliveryFee': deliveryFee,
          'drugs': drugs.map((d) => d.id).toList(),
        },
      );

      // Handle successful order placement
      notifyListeners();
    } on DioError catch (e) {
      throw e.response?.data['message'] ?? 'Failed to place order';
    }
  }

  Future<List<MedOrder>> fetchOrders() async {
    try {
      final response = await apiClient.dio.get('/med-orders');
      return (response.data as List).map((o) => MedOrder.fromMap(o)).toList();
    } catch (e) {
      return [];
    }
  }
}
