import 'Diagnostic.dart';

class Event {
  int id;
  String nom;
  int stress;
  List<Diagnostic> diagnostics;

  Event({
    required this.id,
    required this.nom,
    this.stress = 0,  // Valeur par défaut
    List<Diagnostic>? diagnostics,
  }) : diagnostics = diagnostics ?? [];

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int? ?? 0,
      nom: json['nom'] as String? ?? '',
      stress: json['stress'] as int? ?? 0,  // Gestion de la valeur nulle
      diagnostics: [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'stress': stress,
    'diagnostics': diagnostics.map((d) => d.toJson()).toList(),
  };
}