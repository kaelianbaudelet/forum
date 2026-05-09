import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/message_model.dart';
import '../utils/secure_storage.dart';

class MessageApi {
  // Récupère l'URL de base depuis le fichier .env.local
  // Le "!" signifie que la valeur ne peut pas être nulle.
  final String baseUrl = dotenv.env['API_BASE_URL']!;
  final SecureStorage _secureStorage = SecureStorage();

  // Récupère uniquement les messages racines d'un forum (sans parent)
  Future<List<MessageModel>> fetchRootMessagesByForum(int forumId) async {
    final url = "$baseUrl/messages?forum=$forumId&exists[parent]=false";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> members = data['hydra:member'] ?? data['member'] ?? [];
      return members.map((item) => MessageModel.fromJson(item)).toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }

  // Récupère les réponses directes d'un message
  Future<List<MessageModel>> fetchReplies(int messageId) async {
    final url = "$baseUrl/messages?parent=/api/messages/$messageId";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> members = data['hydra:member'] ?? data['member'] ?? [];
      return members.map((item) => MessageModel.fromJson(item)).toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }

  // Méthode asynchrone qui renvoie une liste d'objets MessageModel
  Future<List<MessageModel>> fetchMessages() async {
    // Construit l'URL complète vers l'endpoint (la route) /messages
    final url = "$baseUrl/messages";

    // Envoie une requête HTTP GET vers l'API et attend la réponse
    final response = await http.get(Uri.parse(url));

    // Vérifie si la réponse HTTP est correcte (code 200)
    if (response.statusCode == 200) {
      // Convertit le JSON brut (string) en Map (objet clé/valeur)
      final Map<String, dynamic> data = json.decode(response.body);

      // Récupère le tableau de messages dans la clé "member"
      // Si "member" n'existe pas, retourne une liste vide
      final List<dynamic> members = data['member'] ?? [];

      // Transforme chaque élément JSON en un objet MessageModel
      // puis renvoie la liste complète
      return members.map((item) => MessageModel.fromJson(item)).toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }

  Future<void> postMessage(String title, String content, int forumId, {int? parentId}) async {
    final token = await _secureStorage.readToken();
    final url = "$baseUrl/messages?bearer=$token";

    if (token == null || token.isEmpty) {
      throw Exception('Aucun token trouvé. Veuillez vous reconnecter.');
    }
    
    // Debug: voir si le token est présent
    print("DEBUG JWT: ${token.substring(0, 10)}...");

    final Map<String, dynamic> body = {
      "titre": title,
      "contenu": content,
      "forum": "/api/forums/$forumId",
      "datePoste": DateTime.now().toIso8601String(),
    };

    if (parentId != null) {
      body["parent"] = "/api/messages/$parentId";
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "content-type": "application/ld+json",
        "accept": "application/ld+json",
        "authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      // On décode le corps de la réponse pour voir le message d'erreur de Symfony
      String errorMsg = 'Erreur HTTP ${response.statusCode}';
      try {
        final data = jsonDecode(response.body);
        if (data['hydra:description'] != null) {
          errorMsg = data['hydra:description'];
        } else if (data['message'] != null) {
          errorMsg = data['message'];
        }
      } catch (_) {
        errorMsg += " : ${response.body}";
      }
      throw Exception(errorMsg);
    }
  }
}
