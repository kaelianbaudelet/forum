import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final _storage = const FlutterSecureStorage();

  static const _keyEmail = 'email';
  static const _keyPassword = 'password';
  static const _keyToken = 'token';
  static const _keyFirstName = 'firstName';
  static const _keyLastName = 'lastName';

  Future<void> saveCredentials(String email, String password) async {
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }

  Future<void> saveUserInfo(String firstName, String lastName) async {
    await _storage.write(key: _keyFirstName, value: firstName);
    await _storage.write(key: _keyLastName, value: lastName);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  Future<String?> readToken() async {
    return await _storage.read(key: _keyToken);
  }

  Future<Map<String, String?>> readUserInfo() async {
    String? firstName = await _storage.read(key: _keyFirstName);
    String? lastName = await _storage.read(key: _keyLastName);
    String? email = await _storage.read(key: _keyEmail);
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }

  Future<Map<String, String?>> readCredentials() async {
    String? email = await _storage.read(key: _keyEmail);
    String? password = await _storage.read(key: _keyPassword);
    return {
      'email': email,
      'password': password,
    };
  }

  Future<void> deleteCredentials() async {
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
    await _storage.delete(key: _keyToken);
  }
}
