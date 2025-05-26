import 'package:cesizen_mobile/pages/diagnostic_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'contenu_page.dart';
import '../theme/app_colors.dart';
import 'auth_page.dart';
import '../models/Utilisateur.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/api_service.dart';
import 'dashboard_user_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Bienvenue sur CESIZen',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        actions: [
          _currentUser != null
              ? PopupMenuButton<String>(
            offset: const Offset(0, 45),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentColor,
                    width: 1,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    ApiService.getUserProfileImageUrl(_currentUser!.photProfil),
                  ),
                  radius: 16,
                  backgroundColor: AppColors.accentColor,
                ),
              ),
            ),
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: AppColors.textColor),
                    SizedBox(width: 8),
                    Text('Profil'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'dashboard',
                child: Row(
                  children: [
                    Icon(Icons.dashboard, color: AppColors.textColor),
                    SizedBox(width: 8),
                    Text('Tableau de bord'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Déconnexion', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (String value) async {
              switch (value) {
                case 'profile':
                // Navigation vers le profil
                  break;
                case 'dashboard':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardUserPage(),
                    ),
                  );
                  break;
                case 'logout':
                  await ApiService.logout();
                  setState(() {
                    _currentUser = null;
                  });
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('current_user');
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthPage()),
                    );
                  }
                  break;
              }
            },
          )
              : IconButton(
            icon: const Icon(Icons.person),
            color: AppColors.neutralColor,
            tooltip: 'Connexion / Inscription',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset('assets/logo-sans-font.png', height: 120),
                SizedBox(height: 20),
                Text(
                  'Votre bien-être, notre priorité',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Découvrez des outils simples et efficaces pour mieux gérer votre stress et prendre soin de votre santé mentale. Suivez vos émotions, pratiquez des exercices de respiration et explorez des activités détente pour un quotidien équilibré.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textColor,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DiagnosticPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Commencer',
                        style: TextStyle(color: AppColors.neutralColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ContenusPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                          0xFFFFC107,
                        ), // bouton jaune/orangé
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('En savoir plus'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
