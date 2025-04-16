import 'package:flutter/material.dart';
import 'contenu_page.dart';
import '../theme/app_colors.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: Text(
          'Bienvenue sur CESIZen',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
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
                      onPressed: () {},
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
