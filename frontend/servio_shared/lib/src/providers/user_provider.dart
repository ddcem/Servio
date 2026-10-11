import '../api/api_client.dart';

import 'dart:typed_data';

import '../models/user.dart';
import 'base_provider.dart';

/// Employee management (admin).
class UserProvider extends CrudProvider<User> {
  UserProvider(ApiClient api) : super(api, 'users');

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  String imageUrl(int id) => api.uri('$endpoint/$id/image').toString();
}

/// The logged-in user's own profile.
class ProfileProvider {
  ProfileProvider(this.api);

  final ApiClient api;

  Future<User> get() async => User.fromJson(await api.get('profile') as Map<String, dynamic>);

  Future<User> update(Map<String, dynamic> request) async =>
      User.fromJson(await api.put('profile', request) as Map<String, dynamic>);

  Future<User> setLanguage(String language) async =>
      User.fromJson(await api.put('profile/language', {'language': language}) as Map<String, dynamic>);

  Future<void> changePassword(String currentPassword, String newPassword, String confirmation) => api.put('profile/password', {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
    'newPasswordConfirmation': confirmation,
  });

  String imageUrl() => api.uri('profile/image').toString();

  Future<void> uploadImage(Uint8List bytes, String fileName) => api.putFile('profile/image', bytes, fileName);

  Future<void> deleteImage() => api.delete('profile/image');
}
