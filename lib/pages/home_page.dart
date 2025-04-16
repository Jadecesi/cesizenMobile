import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF4CAF50);
    const secondaryColor = Color(0xFF81C784);
    const accentColor = Color(0xFFFFC107);
    const accentColorSecondary = Color(0xFFC49403);
    const neutralColor = Color(0xFFF5F5F5);
    const textColor = Color(0xFF333333);

    return Scaffold(
      backgroundColor: neutralColor,
      appBar: AppBar(
        title: Text(
          'Bienvenue sur CESIZen',
          style: TextStyle(color: neutralColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
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
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Découvrez des outils simples et efficaces pour mieux gérer votre stress et prendre soin de votre santé mentale. Suivez vos émotions, pratiquez des exercices de respiration et explorez des activités détente pour un quotidien équilibré.',
                  style: TextStyle(fontSize: 16, color: textColor, height: 1.6),
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
                        backgroundColor: primaryColor,
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
                        style: TextStyle(color: neutralColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
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
                        'En savoir plus',
                        style: TextStyle(color: neutralColor),
                      ),
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
