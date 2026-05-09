import 'package:flutter/material.dart';
import '../api/forum_api.dart';
import '../model/forum_model.dart';
import '../widgets/myscaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ForumModel>> futureForums;

  @override
  void initState() {
    super.initState();
    futureForums = ForumApi().fetchTopLevelForums();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      name: 'Liste des Forums',
      body: FutureBuilder<List<ForumModel>>(
        future: futureForums,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun forum trouvé.'));
          }

          final forums = snapshot.data!;

          return ListView.builder(
            itemCount: forums.length + 2,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.forum,
                            size: 80, color: Colors.blue);
                      },
                    ),
                  ),
                );
              }

              if (index == forums.length + 1) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/users'),
                    icon: const Icon(Icons.people),
                    label: const Text('Liste des utilisateurs'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: Colors.blue.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                );
              }

              final f = forums[index - 1];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    f.titre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      f.description ?? 'Pas de description',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  trailing:
                      const Icon(Icons.arrow_forward_ios, color: Colors.blue),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/forum-detail',
                      arguments: f.id,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
