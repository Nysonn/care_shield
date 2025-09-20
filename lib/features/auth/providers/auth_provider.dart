import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:care_shield/services/local_storage_service.dart';

// PROTOTYPE MODE: This authentication system accepts any credentials
// for demonstration purposes and automatically creates demo users
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
    // For prototype: Accept any credentials and create the user
    // This bypasses validation checks for demonstration purposes

    if (fullName.trim().isEmpty ||
        phone.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      throw Exception('Please fill in all fields');
    }

    final users = Hive.box(_usersBox);
    final id = const Uuid().v4();
    final hashed = _hashPassword(password);
    final user = User(
      id: id,
      fullName: fullName.trim(),
      phone: phone.trim(),
      email: email.trim(),
      passwordHash: hashed,
    );

    await users.put(id, user.toMap());
    final session = Hive.box(_sessionBox);
    await session.put('current_user_id', id);
    _currentUser = user;
    notifyListeners();
  }

  Future<void> login({required String phone, required String password}) async {
    // For prototype: Accept any credentials and create a demo user
    // This bypasses actual authentication for demonstration purposes

    if (phone.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Please enter both phone number and password');
    }

    // Create a demo user for prototype purposes
    final demoUser = User(
      id: 'demo-user-${DateTime.now().millisecondsSinceEpoch}',
      fullName: 'Demo User',
      phone: phone.trim(),
      email: 'demo@careshield.com',
      passwordHash: _hashPassword(password),
    );

    // Store the demo user session
    final session = Hive.box(_sessionBox);
    await session.put('current_user_id', demoUser.id);

    // Store user data
    final users = Hive.box(_usersBox);
    await users.put(demoUser.id, demoUser.toMap());

    _currentUser = demoUser;
    notifyListeners();
  }

  Future<void> logout() async {
    final session = Hive.box(_sessionBox);
    await session.delete('current_user_id');
    _currentUser = null;
    notifyListeners();
  }
}
