import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient({required this.dio, required this.secureStorage}) {
    // Allow overriding base URL via --dart-define=API_BASE_URL=http://host:3000/api
    const envBase = String.fromEnvironment('API_BASE_URL');
    // Use your LAN IP by default for local dev. For Android emulator, you can also use http://10.0.2.2:3000/api
    final defaultBase = Platform.isAndroid
        ? 'https://care-shield.onrender.com/api'
        : 'http://192.168.70.23:3000/api';
    dio.options.baseUrl = envBase.isNotEmpty ? envBase : defaultBase;
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    // Debug which base URL is in use
    // ignore: avoid_print
    print('[ApiClient] Base URL: ' + dio.options.baseUrl);
  }
}
