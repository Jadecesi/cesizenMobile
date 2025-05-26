import 'package:flutter/material.dart';
import '../models/Diagnostic.dart';
import '../models/Event.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'new_diagnostic.dart';
import 'package:intl/intl.dart';

class DashboardUserPage extends StatelessWidget {
  const DashboardUserPage({super.key});

  Widget _buildDiagnosticCard(BuildContext context, Diagnostic diagnostic) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(diagnostic.dateCreation!),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStressColor(diagnostic.totalStress?.toInt() ?? 0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${diagnostic.totalStress?.toInt() ?? 0} pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Événements :',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: diagnostic.reponses?.expand((reponse) {
                return reponse.events.map((event) => Chip(
                  label: Text(event.nom),
                  backgroundColor: Colors.grey[200],
                ));
              }).toList() ?? [],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getRiskIcon(diagnostic.totalStress?.toInt() ?? 0),
                  color: _getStressColor(diagnostic.totalStress?.toInt() ?? 0),
                ),
                const SizedBox(width: 8),
                Text(
                  _getCommentaire(diagnostic.totalStress?.toInt() ?? 0),
                  style: TextStyle(
                    color: _getStressColor(diagnostic.totalStress?.toInt() ?? 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRiskIcon(int totalStress) {
    if (totalStress >= 300) {
      return Icons.warning;
    } else if (totalStress >= 100) {
      return Icons.info;
    } else {
      return Icons.check_circle;
    }
  }

  String _getCommentaire(int totalStress) {
    if (totalStress >= 300) {
      return 'Risque très élevé (80%)';
    } else if (totalStress >= 100) {
      return 'Risque modéré (51%)';
    } else {
      return 'Risque faible (30%)';
    }
  }

  Color _getStressColor(int totalStress) {
    if (totalStress >= 300) {
      return Colors.red;
    } else if (totalStress >= 100) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des diagnostics'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder<List<Diagnostic>>(
        future: ApiService.fetchUserDiagnostics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun diagnostic disponible'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) =>
                _buildDiagnosticCard(context, snapshot.data![index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewDiagnosticPage()),
          );
        },
        backgroundColor: AppColors.accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}