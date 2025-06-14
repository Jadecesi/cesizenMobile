import 'package:flutter/material.dart';
import '../models/Diagnostic.dart';
import '../theme/app_colors.dart';

class ResultPage extends StatelessWidget {
  final Diagnostic diagnostic;

  const ResultPage({super.key, required this.diagnostic});

  @override
  Widget build(BuildContext context) {
    final totalStress = diagnostic.totalStress ?? 0;
    String message;
    Color color;
    if (totalStress > 300) {
      message = "Risque très élevé (80%)";
      color = Colors.red;
    } else if (totalStress > 100) {
      message = "Risque modéré (51%)";
      color = Colors.orange;
    } else {
      message = "Faible risque (30%)";
      color = Colors.green;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Résultat du Diagnostic',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Score total : ${totalStress.toInt()}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Événements sélectionnés :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...?(diagnostic.events ?? []).map((e) => ListTile(
                  title: Text(e.nom),
                  trailing: Text('${e.stress}'),
                )),
                const SizedBox(height: 24),
                Text(
                  diagnostic.dateCreation != null
                      ? "Date : ${diagnostic.dateCreation!.toLocal().toString().split(' ')[0]}"
                      : "",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}