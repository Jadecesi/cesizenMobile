import 'package:cesizen_mobile/models/Utilisateur.dart';
import 'package:cesizen_mobile/models/Reponse.dart';

class Diagnostic {
  final int id;
  final double? totalStress;
  final DateTime? dateCreation;
  final Map<String, dynamic>? utilisateur;
  final List<Reponse>? reponses;

  Diagnostic({
    required this.id,
    this.totalStress,
    this.dateCreation,
    this.utilisateur,
    this.reponses,
  });

  factory Diagnostic.fromJson(Map<String, dynamic> json) {
    return Diagnostic(
      id: json['id'] as int,
      totalStress: json['totalStress'] != null
          ? (json['totalStress'] is int
          ? (json['totalStress'] as int).toDouble()
          : json['totalStress'] as double)
          : null,
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'])
          : null,
      utilisateur: json['utilisateur'] as Map<String, dynamic>?,
      reponses: json['reponses'] != null
          ? List<Reponse>.from(json['reponses']
          .map((r) => Reponse.fromJson(r as Map<String, dynamic>)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (totalStress != null) 'totalStress': totalStress,
    if (dateCreation != null) 'dateCreation': dateCreation?.toIso8601String(),
    if (utilisateur != null) 'utilisateur': utilisateur,
    if (reponses != null) 'reponses': reponses?.map((r) => r.toJson()).toList(),
  };
}