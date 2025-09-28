import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:care_shield/app.dart';
import 'package:care_shield/services/local_storage_service.dart';
import 'package:care_shield/features/auth/providers/auth_provider.dart';
import 'package:care_shield/features/meds/providers/meds_provider.dart';
import 'package:care_shield/features/survey/providers/survey_provider.dart';
import 'package:care_shield/core/theme.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:care_shield/services/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure system UI overlay style globally
  SystemChrome.setSystemUIOverlayStyle(getSystemUiOverlayStyle());

  // Init Hive + secure key
  await LocalStorageService.init();

  // Create ApiClient
  final dio = Dio();
  final secureStorage = FlutterSecureStorage();
  final apiClient = ApiClient(dio: dio, secureStorage: secureStorage);

  // Create providers and initialize their boxes / state BEFORE runApp
  final authProvider = AuthProvider(apiClient: apiClient, secureStorage: secureStorage);
  final medsProvider = MedsProvider(apiClient: apiClient);
  final surveyProvider = SurveyProvider(apiClient: apiClient);

  // Run initialization routines (open encrypted boxes, load session, etc.)
  await Future.wait([
    authProvider.init(),
    medsProvider.init(),
    surveyProvider.init(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<MedsProvider>.value(value: medsProvider),
        ChangeNotifierProvider<SurveyProvider>.value(value: surveyProvider),
      ],
      child: const MyApp(),
    ),
  );
}
