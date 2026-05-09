import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/user_model.dart';

class UserListApi {
  // Récupère l'URL de base depuis le fichier .env.local
  // Le "!" signifie que la valeur ne peut pas être nulle.
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  // Méthode asynchrone qui renvoie une liste d'objets UserModel
  Future<List<UserModel>> fetchUsers() async {
    // Construit l'URL complète vers l'endpoint (la route) /users
    final url = "$baseUrl/users";

    // Envoie une requête HTTP GET vers l'API et attend la réponse
    final response = await http.get(Uri.parse(url));

    // Vérifie si la réponse HTTP est correcte (code 200)
    if (response.statusCode == 200) {
      // Convertit le JSON brut (string) en Map (objet clé/valeur)
      final Map<String, dynamic> data = json.decode(response.body);

      // Récupère le tableau d'utilisateurs dans la clé "member"
      // Si "member" n'existe pas, retourne une liste vide
      final List<dynamic> members = data['member'] ?? [];

      // Transforme chaque élément JSON en un objet UserModel
      // puis renvoie la liste complète
      return members.map((item) => UserModel.fromJson(item)).toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }
}
