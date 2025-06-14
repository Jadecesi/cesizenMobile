import 'package:cesizen_mobile/pages/result_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Diagnostic.dart';
import '../models/Event.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class NewDiagnosticPage extends StatefulWidget {
  const NewDiagnosticPage({super.key});

  @override
  State<NewDiagnosticPage> createState() => _NewDiagnosticPageState();
}

class _NewDiagnosticPageState extends State<NewDiagnosticPage> {
  final Map<int, bool> _selectedEvents = {};
  double _totalStress = 0;

  void _toggleEvent(Event event) {
    setState(() {
      if (_selectedEvents.containsKey(event.id)) {
        _selectedEvents.remove(event.id);
        _totalStress -= event.stress;
      } else {
        _selectedEvents[event.id] = true;
        _totalStress += event.stress;
      }
    });
  }

  Color _getStressColor() {
    if (_totalStress > 300) return Colors.red;
    if (_totalStress > 100) return Colors.orange;
    return Colors.green;
  }

  String _getStressMessage() {
    if (_totalStress > 300) return "Risque très élevé (80%)";
    if (_totalStress > 100) return "Risque modéré (51%)";
    return "Faible risque (30%)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Diagnostic'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStressColor().withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score total : ${_totalStress.toInt()}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getStressColor(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStressMessage(),
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStressColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(
                          value: _totalStress / 400,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey[200],
                          color: _getStressColor(),
                        ),
                      ),
                      Text(
                        '${(_totalStress / 400 * 100).toInt()}%',
                        style: TextStyle(
                          color: _getStressColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: ApiService.fetchEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erreur: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Aucun événement disponible'),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final event = snapshot.data![index];
                          final isSelected = _selectedEvents.containsKey(
                              event.id);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ListTile(
                              title: Text(event.nom),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${event.stress}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (_) => _toggleEvent(event),
                                    activeColor: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                              onTap: () => _toggleEvent(event),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FloatingActionButton.extended(
                        onPressed: _selectedEvents.isEmpty
                            ? null
                            : () async {
                          try {
                            final selectedEventsList = snapshot.data!
                                .where((event) =>
                                _selectedEvents.containsKey(event.id))
                                .toList();

                            final prefs = await SharedPreferences.getInstance();
                            final userJson = prefs.getString('current_user');

                            Diagnostic diagnostic;
                            if (userJson != null) {
                              diagnostic = await ApiService.createDiagnostic(selectedEventsList);
                            } else {
                              diagnostic = await ApiService.createLocalDiagnostic(selectedEventsList);
                            }

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Diagnostic enregistré avec succès'),
                                ),
                              );
                              if (userJson == null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResultPage(diagnostic: diagnostic),
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          }
                        },
                        backgroundColor: _selectedEvents.isEmpty
                            ? Colors.grey
                            : AppColors.accentColor,
                        label: const Text('Enregistrer'),
                        icon: const Icon(Icons.save),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}