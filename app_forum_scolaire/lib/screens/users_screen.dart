import 'package:flutter/material.dart';
import '../api/user_list_api.dart';
import '../model/user_model.dart';
import 'user_info_screen.dart';
import '../utils/error_translator.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Future contenant la liste des utilisateurs (chargés depuis l'API)
  late Future<List<UserModel>> futureUsers;

  @override
  void initState() {
    super.initState();
    // Appel de l'API dès l'ouverture de l'écran
    futureUsers = UserListApi().fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barre supérieure de la page
      appBar: AppBar(title: const Text('Utilisateurs du forum')),

      // FutureBuilder permet d'afficher du contenu une fois la Future terminée
      body: FutureBuilder<List<UserModel>>(
        future: futureUsers,

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
            return const Center(child: Text('Aucun utilisateur trouvé.'));
          }

          // Liste des utilisateurs une fois chargés
          final users = snapshot.data!;

          // 4. Affichage de la liste sous forme de ListView
          return ListView.builder(
            itemCount: users.length, // nombre d'utilisateurs
            itemBuilder: (context, index) {
              final u = users[index]; // utilisateur courant

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInfoScreen(user: u),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Avatar avec l'initiale du prénom
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            u.firstName.isNotEmpty
                                ? u.firstName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Informations de l'utilisateur
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${u.firstName} ${u.lastName}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                u.email,
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
