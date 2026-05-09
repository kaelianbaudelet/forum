import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../widgets/myscaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      name: 'Connexion',
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            LoginForm(),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Pas encore de compte ? S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
