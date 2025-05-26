import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart'; // Importez la page Home

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool isLoading = false; // Indicateur de chargement

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Active l'indicateur de chargement
      });

      try {
        // Appel à l'API pour se connecter
        await ApiService.login(email, password);

        // Redirection vers la page Home après une connexion réussie
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } catch (e) {
        print('Erreur lors de la connexion de l\'utilisateur : $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : ${e.toString()}')));
      } finally {
        setState(() {
          isLoading = false; // Désactive l'indicateur de chargement
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ email
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => email = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Entrez un email'
                            : null,
              ),
              const SizedBox(height: 16),
              // Champ mot de passe
              TextFormField(
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                onChanged: (value) => password = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Entrez un mot de passe'
                            : null,
              ),
              const SizedBox(height: 16),
              // Bouton de connexion
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
