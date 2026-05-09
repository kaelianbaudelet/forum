import 'package:flutter/material.dart';
import '../api/user_api.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        int result = await registerUser(
          _firstNameController.text,
          _lastNameController.text,
          _emailController.text,
          _passwordController.text,
          _phoneController.text.isEmpty ? null : _phoneController.text,
        );

        if (!mounted) return;
        Navigator.of(context).pop(); // retire le loader

        if (result == 201) {
          // Succès
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Inscription réussie'),
              content: Text(
                'Bonjour, ${_firstNameController.text} ${_lastNameController.text}!',
              ),
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
        } else {
          // Erreur serveur
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Échec de l’inscription'),
              content: Text(
                'Une erreur est survenue : ${result.toString()}. Veuillez réessayer.',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        // Exception réseau / JSON
        if (!mounted) return;
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Erreur'),
            content: Text('Erreur lors de l’inscription : $e'),
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
            controller: _firstNameController,
            decoration: const InputDecoration(labelText: 'Prénom'),
            validator: (value) => value == null || value.isEmpty
                ? 'Veuillez saisir votre prénom'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(labelText: 'Nom'),
            validator: (value) => value == null || value.isEmpty
                ? 'Veuillez saisir votre nom'
                : null,
          ),
          const SizedBox(height: 16),
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
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone (optionnel)',
              hintText: 'Ex: 0601020304',
            ),
            keyboardType: TextInputType.phone,
            // Pas de validator car optionnel
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('S\'inscrire'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
