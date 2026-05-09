import 'dart:convert';
import 'package:flutter/material.dart';
import '../api/user_api.dart';
import '../utils/secure_storage.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  final SecureStorage _secureStorage = SecureStorage();
  String? _firstName;
  String? _lastName;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get email => _email;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await _secureStorage.readToken();
    if (token != null) {
      final userInfo = await _secureStorage.readUserInfo();
      _firstName = userInfo['firstName'];
      _lastName = userInfo['lastName'];
      _email = userInfo['email'];
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<void> loginUser(String email, String password) async {
    try {
      final response = await login(email, password);
      final responseData = jsonDecode(response.body);

      final token = responseData['token'] ?? '';

      final user = responseData['data'] ?? responseData['user'] ?? {};
      final firstName = user['prenom'] ?? '';
      final lastName = user['nom'] ?? '';

      await _secureStorage.saveToken(token);
      await _secureStorage.saveCredentials(email, password);
      await _secureStorage.saveUserInfo(firstName, lastName);

      _firstName = firstName;
      _lastName = lastName;
      _email = email;
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteCredentials();
    _isLoggedIn = false;
    _firstName = null;
    _lastName = null;
    _email = null;
    notifyListeners();
  }
}
