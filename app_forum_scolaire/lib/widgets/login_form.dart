import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/secure_storage.dart';
import '../utils/error_translator.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final SecureStorage secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credentials = await secureStorage.readCredentials();
    setState(() {
      _emailController.text = credentials['email'] ?? '';
      _passwordController.text = credentials['password'] ?? '';
    });
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Loader (matching RegisterScreen design)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        await Provider.of<AuthProvider>(
          context,
          listen: false,
        ).loginUser(_emailController.text, _passwordController.text);

        if (!mounted) return;
        Navigator.of(context).pop(); // retire le loader

        // Succès (matching RegisterScreen design)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Authentification réussie'),
            content: const Text('Heureux de vous revoir !'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/');
                },
              ),
            ],
          ),
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.of(context).pop(); // retire le loader

        // Échec (matching RegisterScreen design)
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Échec de l\'authentification'),
            content: Text(ErrorTranslator.translate(e)),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || value.isEmpty
                ? 'Veuillez saisir votre email'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            obscureText: true,
            validator: (value) => value == null || value.isEmpty
                ? 'Veuillez saisir votre mot de passe'
                : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _login, child: const Text('Se connecter')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
