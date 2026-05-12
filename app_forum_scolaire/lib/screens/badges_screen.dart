import 'package:flutter/material.dart';
import 'package:forum/model/badge_model.dart';
import '../api/badge_list_api.dart';
import '../utils/error_translator.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  // Future contenant la liste des badges (chargés depuis l'API)
  late Future<List<BadgeModel>> futureBadges;

  @override
  void initState() {
    super.initState();
    // Appel de l'API dès l'ouverture de l'écran
    futureBadges = BadgeListApi().fetchBadges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre supérieure de la page
      appBar: AppBar(title: const Text('Badges du Forum')),

      // FutureBuilder permet d'afficher du contenu une fois la Future terminée
      body: FutureBuilder<List<BadgeModel>>(
        future: futureBadges,

        // builder = fonction appelée à chaque changement d'état du Future
        builder: (context, snapshot) {
          // 1. Affichage d'un loader pendant le chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Affichage d'un message d'erreur si l'API échoue
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  ErrorTranslator.translate(snapshot.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // 3. Cas où aucune donnée n'est retournée
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun badge trouvé.'));
          }

          // Liste des badges une fois chargés
          final badges = snapshot.data!;

          // 4. Affichage de la liste sous forme de ListView
          return ListView.builder(
            itemCount: badges.length, // nombre de badges
            itemBuilder: (context, index) {
              final u = badges[index]; // badge courant

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Informations de l'utilisateur
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                u.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                u.description,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Badge avec l'ID
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${u.id}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
