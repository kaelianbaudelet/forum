import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../model/forum_model.dart';

class ForumApi {
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  Future<List<ForumModel>> fetchTopLevelForums() async {
    // We can filter by forums that don't have a parent
    // However, API Platform might need a filter or custom endpoint.
    // For now, let's fetch all and filter client-side or use a search filter if available.
    final url = "$baseUrl/forums";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      List<dynamic> members = [];

      if (decoded is List) {
        members = decoded;
      } else if (decoded is Map<String, dynamic>) {
        // Handle Hydra (hydra:member) or custom (member) keys
        members = decoded['hydra:member'] ?? decoded['member'] ?? [];
      }
      
      return members
          .map((item) => ForumModel.fromJson(item as Map<String, dynamic>))
          .where((f) => f.parentId == null) // Only top-level
          .toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }

  Future<List<ForumModel>> fetchAllForums() async {
    final url = "$baseUrl/forums";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      List<dynamic> members = [];

      if (decoded is List) {
        members = decoded;
      } else if (decoded is Map<String, dynamic>) {
        members = decoded['hydra:member'] ?? decoded['member'] ?? [];
      }
      
      return members
          .map((item) => ForumModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }

  Future<ForumModel> fetchForumDetail(int id) async {
    final url = "$baseUrl/forums/$id";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return ForumModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }
}
