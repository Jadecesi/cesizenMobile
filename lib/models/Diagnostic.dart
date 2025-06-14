import 'Event.dart';

class Diagnostic {
  final int? id;
  final double? totalStress;
  final DateTime? dateCreation;
  final Map<String, dynamic>? utilisateur;
  final List<Event> events;

  Diagnostic({
    this.id,
    this.totalStress,
    this.dateCreation,
    this.events = const [],
    this.utilisateur,
  });

  factory Diagnostic.fromJson(Map<String, dynamic> json) {
    try {
      return Diagnostic(
        id: json['id'] as int?,
        totalStress: (json['totalStress'] as num?)?.toDouble(),
        dateCreation: json['dateCreation'] != null
            ? DateTime.parse(json['dateCreation'] as String)
            : null,
        utilisateur: json['utilisateur'] as Map<String, dynamic>?,
        events: (json['events'] as List?)
            ?.map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    } catch (e) {
      print('Erreur dans Diagnostic.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    if (totalStress != null) 'totalStress': totalStress,
    if (dateCreation != null) 'dateCreation': dateCreation?.toIso8601String(),
    if (utilisateur != null) 'utilisateur': utilisateur,
    'events': events.map((e) => e.toJson()).toList(),
  };
}