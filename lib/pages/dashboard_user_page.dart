import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Diagnostic.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import 'new_diagnostic.dart';
import 'package:intl/intl.dart';

class DashboardUserPage extends StatefulWidget {
  const DashboardUserPage({super.key});

  @override
  State<DashboardUserPage> createState() => _DashboardUserPageState();
}

class _DashboardUserPageState extends State<DashboardUserPage> {
  late Future<List<Diagnostic>> _diagnosticsFuture;

  @override
  void initState() {
    super.initState();
    _diagnosticsFuture = _loadDiagnostics();
  }

  Future<List<Diagnostic>> _loadDiagnostics() {
    return ApiService.fetchUserDiagnostics();
  }

  Future<void> _refreshDiagnostics() async {
    setState(() {
      _diagnosticsFuture = _loadDiagnostics();
    });
  }

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
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
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      final userJson = prefs.getString('current_user');
                      if (userJson != null) {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmation'),
                            content: RichText(
                              text: const TextSpan(
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(text: 'Voulez-vous vraiment supprimer votre diagnostic ?\n\n'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          final success = await ApiService.deleteDiagnostic(diagnostic.id!);
                          if (success && mounted) {
                            _refreshDiagnostics();
                          }
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
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
        title: Text(
          'Historique des diagnostics',
          style: TextStyle(
            color: AppColors.neutralColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewDiagnosticPage()),
              ).then((_) => _refreshDiagnostics());
            },
            icon: const Icon(Icons.add),
            color: AppColors.accentColor,
          ),
        ],
        backgroundColor: AppColors.primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshDiagnostics,
        color: AppColors.primaryColor,
        child: FutureBuilder<List<Diagnostic>>(
          future: _diagnosticsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Aucun diagnostic disponible'),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) =>
                  _buildDiagnosticCard(context, snapshot.data![index]),
            );
          },
        ),
      ),
    );
  }
}