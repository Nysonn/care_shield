import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:care_shield/services/api_client.dart';

class User {
  final String id;
  final String fullName;
  final String phone;
  final String? email;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullName: map['fullName'],
      phone: map['phone'],
      email: map['email'],
    );
  }
}

class AuthProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;

  User? _currentUser;
  bool _initialized = false;

  User? get currentUser => _currentUser;
  bool get initialized => _initialized;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({required this.apiClient, required this.secureStorage});

  Future<void> init() async {
    print('AuthProvider: init started');
    final token = await secureStorage.read(key: 'token');
    print('AuthProvider: token: $token');
    if (token != null) {
      try {
        print('AuthProvider: token found, trying to get user profile');
        final response = await apiClient.dio.get('/auth/me');
        print('AuthProvider: user profile response: ${response.data}');
        _currentUser = User.fromMap(response.data);
        print('AuthProvider: user profile parsed');
      } catch (e) {
        print('AuthProvider: error getting user profile: $e');
        // Token is invalid, clear it
        await secureStorage.delete(key: 'token');
        _currentUser = null;
      }
    }
    _initialized = true;
    print('AuthProvider: init finished');
    notifyListeners();
  }

  Future<void> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/signup',
        data: {
          'fullName': fullName,
          'phone': phone,
          'email': email,
          'password': password,
        },
      );
      // If backend returns token+user, persist and set session
      final data = response.data;
      if (data is Map && data['token'] != null && data['user'] != null) {
        await secureStorage.write(key: 'token', value: data['token']);
        _currentUser = User.fromMap(data['user']);
        notifyListeners();
      }
    } on DioError catch (e) {
      throw e.response?.data['message'] ?? 'Signup failed';
    }
  }

  Future<void> login({required String phone, required String password}) async {
    try {
      final response = await apiClient.dio.post(
        '/auth/login',
        data: {'phone': phone, 'password': password},
      );

      final token = response.data['token'];
      await secureStorage.write(key: 'token', value: token);

      _currentUser = User.fromMap(response.data['user']);
      notifyListeners();
    } on DioError catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    }
  }

  Future<void> logout() async {
    await secureStorage.delete(key: 'token');
    _currentUser = null;
    notifyListeners();
  }
}
