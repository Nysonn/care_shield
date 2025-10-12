import 'package:flutter/material.dart';
import 'package:care_shield/services/api_client.dart';
import '../models/pharmacy.dart';
import '../models/pharmacy_drug.dart';
import '../models/service.dart';

class PharmacyProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<Pharmacy> _pharmacies = [];
  List<Pharmacy> get pharmacies => List.unmodifiable(_pharmacies);

  Pharmacy? _selectedPharmacy;
  Pharmacy? get selectedPharmacy => _selectedPharmacy;

  List<PharmacyDrug> _pharmacyDrugs = [];
  List<PharmacyDrug> get pharmacyDrugs => List.unmodifiable(_pharmacyDrugs);

  List<PharmacyService> _pharmacyServices = [];
  List<PharmacyService> get pharmacyServices =>
      List.unmodifiable(_pharmacyServices);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMorePages => _currentPage < _totalPages;

  PharmacyProvider({required this.apiClient});

  Future<void> init() async {
    print('PharmacyProvider: init started');
    await fetchPharmacies();
    print('PharmacyProvider: init finished');
  }

  Future<void> fetchPharmacies({String? searchQuery, int page = 1}) async {
    print('PharmacyProvider: fetchPharmacies started - page $page');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{'page': page, 'limit': 10};

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      final response = await apiClient.dio.get(
        '/pharmacies',
        queryParameters: queryParams,
      );

      final data = response.data;
      final newPharmacies = (data['pharmacies'] as List)
          .map((p) => Pharmacy.fromMap(p))
          .toList();

      if (page == 1) {
        _pharmacies = newPharmacies;
      } else {
        _pharmacies.addAll(newPharmacies);
      }

      _currentPage = data['pagination']['page'];
      _totalPages = data['pagination']['totalPages'];

      print(
        'PharmacyProvider: fetchPharmacies success, ${_pharmacies.length} pharmacies loaded',
      );
    } catch (e) {
      print('PharmacyProvider: fetchPharmacies error: $e');
      _error = 'Failed to load pharmacies: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMorePharmacies({String? searchQuery}) async {
    if (!_isLoading && hasMorePages) {
      await fetchPharmacies(searchQuery: searchQuery, page: _currentPage + 1);
    }
  }

  Future<void> fetchPharmacyDrugs(
    String pharmacyId, {
    String? searchQuery,
    String? category,
  }) async {
    print(
      'PharmacyProvider: fetchPharmacyDrugs started for pharmacy $pharmacyId',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, dynamic>{};

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['q'] = searchQuery;
      }

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      final response = await apiClient.dio.get(
        '/pharmacies/$pharmacyId/drugs',
        queryParameters: queryParams,
      );

      final data = response.data;
      _pharmacyDrugs = (data['drugs'] as List)
          .map((d) => PharmacyDrug.fromMap(d))
          .toList();

      print(
        'PharmacyProvider: fetchPharmacyDrugs success, ${_pharmacyDrugs.length} drugs loaded',
      );
    } catch (e) {
      print('PharmacyProvider: fetchPharmacyDrugs error: $e');
      _error = 'Failed to load drugs: $e';
      _pharmacyDrugs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPharmacyServices(String pharmacyId) async {
    print(
      'PharmacyProvider: fetchPharmacyServices started for pharmacy $pharmacyId',
    );
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await apiClient.dio.get(
        '/pharmacies/$pharmacyId/services',
      );

      _pharmacyServices = (response.data as List)
          .map((s) => PharmacyService.fromMap(s))
          .toList();

      print(
        'PharmacyProvider: fetchPharmacyServices success, ${_pharmacyServices.length} services loaded',
      );
    } catch (e) {
      print('PharmacyProvider: fetchPharmacyServices error: $e');
      _error = 'Failed to load services: $e';
      _pharmacyServices = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectPharmacy(Pharmacy pharmacy) {
    _selectedPharmacy = pharmacy;
    notifyListeners();

    // Auto-load drugs and services for the selected pharmacy
    fetchPharmacyDrugs(pharmacy.id);
    fetchPharmacyServices(pharmacy.id);
  }

  void clearSelection() {
    _selectedPharmacy = null;
    _pharmacyDrugs = [];
    _pharmacyServices = [];
    notifyListeners();
  }

  Future<List<Pharmacy>> searchPharmaciesByDrug(String drugName) async {
    try {
      final response = await apiClient.dio.get(
        '/pharmacies/search',
        queryParameters: {'drug': drugName},
      );

      return (response.data as List).map((p) => Pharmacy.fromMap(p)).toList();
    } catch (e) {
      print('PharmacyProvider: searchPharmaciesByDrug error: $e');
      return [];
    }
  }
}
