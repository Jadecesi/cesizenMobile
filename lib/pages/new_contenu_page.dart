import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Utilisateur.dart';

class NewContenuPage extends StatefulWidget {
  const NewContenuPage({super.key});

  @override
  State<NewContenuPage> createState() => _NewContenuPageState();
}

class _NewContenuPageState extends State<NewContenuPage> {
  final _formKey = GlobalKey<FormState>();
  String titre = '';
  String image = '';
  String description = '';
  String url = '';
  bool isLoading = false;
  Utilisateur? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        setState(() {
          _currentUser = Utilisateur.fromJson(jsonDecode(userJson));
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    }
  }

  Future<void> _createContenu() async {
    if (_formKey.currentState!.validate()) {
      if (_currentUser == null || _currentUser!.apiToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté pour créer un contenu')),
        );
        return;
      }

      setState(() {
        isLoading = true;
      });

      try {
        await ApiService.createContenu(
            titre,
            image,
            description,
            url,
            _currentUser!.apiToken!
        );

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contenu créé avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau contenu'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Titre'),
                onChanged: (value) => titre = value,
                validator: (value) =>
                value?.isEmpty ?? true ? 'Le titre est requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => image = value,
                validator: (value) =>
                value?.isEmpty ?? true ? 'L\'URL de l\'image est requise' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onChanged: (value) => description = value,
                validator: (value) =>
                value?.isEmpty ?? true ? 'La description est requise' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'URL (optionnel)'),
                onChanged: (value) => url = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _createContenu,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Créer le contenu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}