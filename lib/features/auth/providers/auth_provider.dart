import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:care_shield/services/local_storage_service.dart';

class User {
  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String passwordHash;
  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.passwordHash,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fullName': fullName,
    'phone': phone,
    'email': email,
    'passwordHash': passwordHash,
  };

  static User fromMap(Map map) => User(
    id: map['id'],
    fullName: map['fullName'],
    phone: map['phone'],
    email: map['email'],
    passwordHash: map['passwordHash'],
  );
}

class AuthProvider extends ChangeNotifier {
  static const _usersBox = 'users_box';
  static const _sessionBox = 'session_box';

  User? _currentUser;
  bool _initialized = false;

  User? get currentUser => _currentUser;
  bool get initialized => _initialized;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider();

  /// Call once (used in main) to open boxes and try to restore session
  Future<void> init() async {
    await LocalStorageService.openEncryptedBox(_usersBox);
    await LocalStorageService.openEncryptedBox(_sessionBox);

    final session = Hive.box(_sessionBox);
    final uid = session.get('current_user_id') as String?;
    if (uid != null) {
      final users = Hive.box(_usersBox);
      final userMap = users.get(uid);
      if (userMap != null) {
        _currentUser = User.fromMap(Map<String, dynamic>.from(userMap));
      }
    }

    _initialized = true;
    notifyListeners();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signUp({
    required String fullName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final users = Hive.box(_usersBox);

    // simple uniqueness check
    final exists = users.values.cast<Map>().any(
      (u) => u['phone'] == phone || u['email'] == email,
    );
    if (exists) {
      throw Exception('User with this phone/email already exists');
    }

    final id = const Uuid().v4();
    final hashed = _hashPassword(password);
    final user = User(
      id: id,
      fullName: fullName,
      phone: phone,
      email: email,
      passwordHash: hashed,
    );

    await users.put(id, user.toMap());
    final session = Hive.box(_sessionBox);
    await session.put('current_user_id', id);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> login({required String phone, required String password}) async {
    final users = Hive.box(_usersBox);
    final hashed = _hashPassword(password);

    final found = users.values.cast<Map>().firstWhere(
      (u) => u['phone'] == phone && u['passwordHash'] == hashed,
      orElse: () => {},
    );

    if (found.isEmpty) {
      throw Exception('Invalid credentials');
    }

    final user = User.fromMap(Map<String, dynamic>.from(found));
    final session = Hive.box(_sessionBox);
    await session.put('current_user_id', user.id);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    final session = Hive.box(_sessionBox);
    await session.delete('current_user_id');
    _currentUser = null;
    notifyListeners();
  }
}
