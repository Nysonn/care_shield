import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

class LocalStorageService {
  static const _secureKeyName = 'hive_encryption_key';
  static final _secureStorage = const FlutterSecureStorage();

  /// Call once at app startup.
  static Future<void> init() async {
    // Init hive with default directory
    final appDocDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocDir.path);

    // Ensure an encryption key exists in secure storage
    final key = await _getEncryptionKey();
    // If you plan to register adapters, do so after init
  }

  /// Returns a 32-byte encryption key for Hive; stores it in secure storage if not present.
  static Future<Uint8List> _getEncryptionKey() async {
    final existing = await _secureStorage.read(key: _secureKeyName);
    if (existing != null) {
      return Uint8List.fromList(existing.codeUnits);
    }

    // Generate 32 random bytes
    final rnd = Random.secure();
    final key = List<int>.generate(32, (_) => rnd.nextInt(256));
    final keyStr = String.fromCharCodes(key);
    await _secureStorage.write(key: _secureKeyName, value: keyStr);
    return Uint8List.fromList(key);
  }

  /// Convenience wrapper for opening an encrypted box.
  /// NOTE: caller should await LocalStorageService._getEncryptionKey() before calling.
  static Future<Box<T>> openEncryptedBox<T>(String name) async {
    final key = await _getEncryptionKey();
    return Hive.openBox<T>(name, encryptionCipher: HiveAesCipher(key));
  }
}
