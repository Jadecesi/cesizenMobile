import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../models/contenu.dart';
import '../models/Utilisateur.dart';
import '../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../pages/new_contenu_page.dart';

class ContenusPage extends StatefulWidget {
  const ContenusPage({super.key});

  @override
  State<ContenusPage> createState() => _ContenusPageState();
}

class _ContenusPageState extends State<ContenusPage> {
  late Future<List<Contenu>> _contenus;
  Utilisateur? _currentUser;

  @override
  void initState() {
    super.initState();
    _contenus = ApiService.fetchContenus();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      print('userJson récupéré: $userJson');

      if (userJson != null) {
        final user = Utilisateur.fromJson(jsonDecode(userJson));
        print('Role de l\'utilisateur: ${user.role.nom}');
        setState(() {
          _currentUser = user;
        });
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'utilisateur: $e');
    }
  }

  Future<void> _refreshContenus() async {
    setState(() {
      _contenus = ApiService.fetchContenus();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('État actuel: currentUser=${_currentUser?.role.nom}');

    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: Text(
          'Articles et contenus',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
        actions: [
          if (_currentUser?.role.nom == 'ROLE_ADMIN')
            IconButton(
              icon: const Icon(Icons.add),
              color: AppColors.neutralColor,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewContenuPage()),
                ).then((_) => _refreshContenus());
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshContenus,
        color: AppColors.primaryColor,
        child: FutureBuilder<List<Contenu>>(
          future: _contenus,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Erreur : ${snapshot.error}',
                  style: TextStyle(color: Colors.red[700]),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "Aucun contenu disponible",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            final contenus = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contenus.length,
              itemBuilder: (context, index) {
                final contenu = contenus[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: ApiService.getContenuImageUrl(contenu.image ?? ''),
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print('Erreur de chargement image: $error');
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.error_outline,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                          memCacheWidth: 800,
                          maxWidthDiskCache: 800,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contenu.titre ?? 'Sans titre',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              ((contenu.description?.length ?? 0) > 100)
                                  ? '${contenu.description!.substring(0, 100)}...'
                                  : contenu.description ?? 'Pas de description',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (contenu.url != null && contenu.url!.isNotEmpty)
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final uri = Uri.parse(contenu.url!);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Impossible d'ouvrir le lien",
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                  ),
                                  child: const Text(
                                    "Lire +",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}