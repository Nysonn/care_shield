import 'package:hive/hive.dart';

part 'users.g.dart'; // optional if using codegen

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String email;

  // store hashed password only
  @HiveField(4)
  final String passwordHash;

  User({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.passwordHash,
  });
}
