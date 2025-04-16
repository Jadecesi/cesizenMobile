import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/contenu.dart';
import '../theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class ContenusPage extends StatefulWidget {
  const ContenusPage({super.key});

  @override
  State<ContenusPage> createState() => _ContenusPageState();
}

class _ContenusPageState extends State<ContenusPage> {
  late Future<List<Contenu>> _contenus;

  @override
  void initState() {
    super.initState();
    _contenus = ApiService.fetchContenus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: const Text("Articles et contenus"),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Contenu>>(
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
                      child: Image.network(
                        ApiService.getContenuImageUrl(contenu.image),
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
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
                            contenu.titre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            contenu.description.length > 100
                                ? '${contenu.description.substring(0, 100)}...'
                                : contenu.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (contenu.url != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () async {
                                  final uri = Uri.parse(contenu.url!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Impossible d'ouvrir le lien",
                                        ),
                                      ),
                                    );
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
    );
  }
}
