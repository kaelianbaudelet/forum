import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Registers a new user with the provided details.
/// Returns the HTTP status code (201 for success).
Future<int> registerUser(
  String firstName,
  String lastName,
  String email,
  String password,
  String? phone,
) async {
  final String? baseUrl = dotenv.env['API_BASE_URL'];
  if (baseUrl == null) {
    print("Error: API_BASE_URL not found in .env file");
    return 0;
  }

  final uri = Uri.parse("$baseUrl/users");

  final headers = {
    'Content-Type': 'application/ld+json',
    'Accept': 'application/ld+json',
  };

  final body = json.encode({
    'prenom': firstName,
    'nom': lastName,
    'email': email,
    'password': password,
    'phone': phone,
  });

  try {
    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode == 201) {
      return 201;
    } else {
      print("Error: ${response.statusCode}\nResponse: ${response.body}");
      return response.statusCode;
    }
  } catch (e) {
    print("Exception during request: $e");
    return 0;
  }
}

Future<http.Response> login(String email, String password) async {
  final String? baseUrl = dotenv.env['API_BASE_URL'];
  if (baseUrl == null) {
    throw Exception('API_BASE_URL not found in .env file');
  }

  final url = Uri.parse('$baseUrl/authentication_token');

  final headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };

  final body = jsonEncode({'email': email, 'password': password});

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    return response;
  } else {
    // Decoding error body if possible for better message
    String errorMessage = 'Failed to login: ${response.reasonPhrase}';
    try {
      final decodedBody = jsonDecode(response.body);
      if (decodedBody['message'] != null) {
        errorMessage = decodedBody['message'];
      }
    } catch (_) {}
    throw Exception(errorMessage);
  }
}
