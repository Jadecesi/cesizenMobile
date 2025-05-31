import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/Event.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'new_diagnostic.dart';

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  Future<bool>? _hasDiagnostic;

  @override
  void initState() {
    super.initState();
    _checkDiagnostic();
  }

  Future<void> _checkDiagnostic() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    setState(() {
      _hasDiagnostic = Future.value(userJson != null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralColor,
      appBar: AppBar(
        title: Text(
          'Diagnostic',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<bool>(
              future: _hasDiagnostic,
              builder: (context, snapshot) {
                if (snapshot.hasData && !snapshot.data!) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Vous n'avez pas encore réalisé de diagnostic",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textColor,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SelectableText(
              "Échelle de Stress de Holmes et Rahe",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 20),
            _buildStressLevels(),
            const SizedBox(height: 30),
            _buildEventsTable(),
            const SizedBox(height: 30),
            _buildStartButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const SelectableText( // Remplace Text par SelectableText
        "L'échelle de stress de Holmes et Rahe permet d'évaluer le niveau de stress "
            "accumulé en fonction des événements de vie récents. Chaque événement est "
            "associé à un score de stress, et le total permet d'estimer le risque de "
            "développer une maladie liée au stress.",
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: AppColors.textColor,
        ),
      ),
    );
  }

  Widget _buildStressLevels() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Interprétation des scores :",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildStressLevel("Plus de 300 points :", "Risque très élevé (80%)", Colors.red),
          _buildStressLevel("Entre 100 et 300 points :", "Risque modéré (51%)", Colors.orange),
          _buildStressLevel("Moins de 100 points :", "Faible risque (30%)", Colors.green),
        ],
      ),
    );
  }

  Widget _buildStressLevel(String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 30,
            color: color,
            margin: const EdgeInsets.only(right: 8),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: AppColors.textColor),
                children: [
                  TextSpan(
                    text: title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: " $description"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTable() {
    return FutureBuilder<List<Event>>(
      future: ApiService.fetchEvents(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text('Aucun événement disponible'));
        }

        final events = snapshot.data!.take(3).toList();

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Principaux Événements Stressants",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              for (var event in events)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: SelectableText(event.nom)),
                      Text(
                        event.stress.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewDiagnosticPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentColor,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Démarrer un nouveau test",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}