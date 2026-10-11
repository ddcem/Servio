import 'json.dart';

class User {
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.roleId,
    required this.role,
    required this.isActive,
    required this.hasProfileImage,
    this.preferredLanguage = 'en',
    required this.createdAt,
    this.lastLoginAt,
    this.hasActivity = false,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    firstName: json['firstName'] as String,
    lastName: json['lastName'] as String,
    username: json['username'] as String,
    email: json['email'] as String,
    phoneNumber: json['phoneNumber'] as String?,
    roleId: json['roleId'] as int,
    role: json['role'] as String,
    isActive: json['isActive'] as bool,
    hasProfileImage: json['hasProfileImage'] as bool,
    preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    createdAt: toLocalDate(json['createdAt']),
    lastLoginAt: toLocalDateOrNull(json['lastLoginAt']),
    hasActivity: json['hasActivity'] as bool? ?? false,
  );

  final int id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String? phoneNumber;
  final int roleId;
  final String role;
  final bool isActive;
  final bool hasProfileImage;

  /// The app language the user chose: "en" or "bs".
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool hasActivity;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName.isEmpty ? '' : firstName[0]}${lastName.isEmpty ? '' : lastName[0]}'.toUpperCase();
}
