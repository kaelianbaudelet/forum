import 'dart:convert';
import 'package:forum/model/badge_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BadgeListApi {
  // Récupère l'URL de base depuis le fichier .env.local
  // Le "!" signifie que la valeur ne peut pas être nulle.
  final String baseUrl = dotenv.env['API_BASE_URL']!;

  // Méthode asynchrone qui renvoie une liste d'objets BadgeModel
  Future<List<BadgeModel>> fetchBadges() async {
    // Construit l'URL complète vers l'endpoint (la route) /badges
    final url = "$baseUrl/badges";

    // Envoie une requête HTTP GET vers l'API et attend la réponse
    final response = await http.get(Uri.parse(url));

    // Vérifie si la réponse HTTP est correcte (code 200)
    if (response.statusCode == 200) {
      // Convertit le JSON brut (string) en Map (objet clé/valeur)
      final Map<String, dynamic> data = json.decode(response.body);

      // Récupère le tableau de badges dans la clé "member"
      // Si "member" n'existe pas, retourne une liste vide
      final List<dynamic> badges = data['member'] ?? [];

      // Transforme chaque élément JSON en un objet BadgeModel
      // puis renvoie la liste complète
      return badges.map((item) => BadgeModel.fromJson(item)).toList();
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}');
    }
  }
}
