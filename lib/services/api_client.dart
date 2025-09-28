import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;

  ApiClient({required this.dio, required this.secureStorage}) {
    // Allow overriding base URL via --dart-define=API_BASE_URL=http://host:3000/api
    // Base URL resolution order:
    // 1) --dart-define=API_BASE_URL=... (highest priority)
    // 2) Release build default -> Render
    // 3) Debug/dev default -> local emulator/host
    const envBase = String.fromEnvironment('API_BASE_URL');
    final devBase = Platform.isAndroid
        ? 'http://10.0.2.2:3000/api'
        : 'http://localhost:3000/api';
    const prodBase = 'https://care-shield.onrender.com';
    dio.options.baseUrl = envBase.isNotEmpty
        ? envBase
        : (kReleaseMode ? prodBase : devBase);
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
  }
}
