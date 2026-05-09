import 'package:flutter/material.dart';
import '../widgets/register_form.dart';
import '../widgets/myscaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      name: 'Inscription',
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: RegisterForm(),
      ),
    );
  }
}
