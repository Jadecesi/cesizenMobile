// lib/models/event.dart
import 'package:cesizen_mobile/models/Reponse.dart';

class Event {
  final int id;
  final String nom;
  final int stress;
  final List<Reponse> reponses;

  Event({
    required this.id,
    required this.nom,
    required this.stress,
    required this.reponses,
  });

  factory Event.fromJson(Map<String, dynamic> json) => Event(
    id: json['id'] as int,
    nom: json['nom'] as String,
    stress: json['stress'] as int,
    reponses: (json['reponses'] as List<dynamic>?)
        ?.map((e) => Reponse.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'stress': stress,
    'reponses': reponses.map((r) => r.toJson()).toList(),
  };
}