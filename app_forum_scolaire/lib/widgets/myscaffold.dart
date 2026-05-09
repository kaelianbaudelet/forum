import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;
  final String name;
  final int? forumId;
  final VoidCallback? onPostSuccess;

  const MyScaffold({
    super.key,
    required this.body,
    required this.name,
    this.forumId,
    this.onPostSuccess,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(name, style: const TextStyle(color: Colors.white)),
        elevation: 10.0,
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: <Widget>[
          if (authProvider.isLoggedIn ||
              ModalRoute.of(context)?.settings.name != '/register')
            IconButton(
              icon: Icon(
                authProvider.isLoggedIn ? Icons.person : Icons.person_add,
                color: Colors.white,
              ),
              tooltip: authProvider.isLoggedIn ? 'Profil' : 'Inscription',
              onPressed: () {
                if (authProvider.isLoggedIn) {
                  Navigator.pushNamed(context, '/profile');
                } else {
                  if (ModalRoute.of(context)?.settings.name != '/register') {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/register',
                      (route) => route.isFirst,
                    );
                  }
                }
              },
            ),
          if (authProvider.isLoggedIn ||
              ModalRoute.of(context)?.settings.name != '/login')
            IconButton(
              icon: Icon(
                authProvider.isLoggedIn ? Icons.logout : Icons.login,
                color: Colors.white,
              ),
              tooltip: authProvider.isLoggedIn ? 'Déconnexion' : 'Connexion',
              onPressed: () {
                if (authProvider.isLoggedIn) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text(
                        'Voulez-vous vraiment vous déconnecter ?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            authProvider.logout();
                            Navigator.of(context).pop();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text(
                            'Déconnexion',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  if (ModalRoute.of(context)?.settings.name != '/login') {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => route.isFirst,
                    );
                  }
                }
              },
            ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (authProvider.isLoggedIn) {
            final result = await Navigator.pushNamed(
              context, 
              '/write-message', 
              arguments: forumId
            );
            
            if (result == true && onPostSuccess != null) {
              onPostSuccess!();
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez vous connecter pour écrire un message'),
              ),
            );
            Navigator.pushNamed(context, '/login');
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
