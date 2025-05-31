import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Utilisateur.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;
  Utilisateur? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final user = Utilisateur.fromJson(jsonDecode(userJson));
        setState(() {
          _currentUser = user;
          _nomController.text = user.nom;
          _prenomController.text = user.prenom;
          _emailController.text = user.email;
          _usernameController.text = user.username ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement du profil';
      });
    }
  }

  // Dans EditUserPage, modifiez la méthode _updateUser :
  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = await ApiService.editUser(
        _currentUser!.id,
        _currentUser!.apiToken!,
        _nomController.text,
        _prenomController.text,
        _emailController.text,
        _usernameController.text,
      );

      // Sauvegarder le nouvel utilisateur dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', jsonEncode(updatedUser.toJson()));

      if (mounted) {
        // Retourner true pour indiquer que la mise à jour a réussi
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.neutralColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Modifier le profil',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade700),
                    textAlign: TextAlign.center,
                  ),
                ),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomController,
                        decoration: _buildInputDecoration('Nom', Icons.person),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Le nom est requis' : null,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _prenomController,
                        decoration: _buildInputDecoration('Prénom', Icons.person_outline),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Le prénom est requis' : null,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: _buildInputDecoration('Email', Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'L\'email est requis' : null,
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: _buildInputDecoration('Nom d\'utilisateur', Icons.account_circle),
                        validator: (value) =>
                        value?.isEmpty ?? true ? 'Le nom d\'utilisateur est requis' : null,
                        enabled: !_isLoading,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Mettre à jour',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.primaryColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryColor),
      ),
      prefixIcon: Icon(icon, color: AppColors.primaryColor),
      filled: true,
      fillColor: Colors.white,
    );
  }
}