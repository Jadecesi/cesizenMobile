import 'package:cesizen_mobile/models/Diagnostic.dart';
import 'package:cesizen_mobile/models/Role.dart';
import 'package:cesizen_mobile/models/Contenu.dart';

class Utilisateur {
  final int id;
  final String email;
  final Role role;
  final List<Diagnostic>? diagnostics;
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String? username;
  final String? photProfil;
  final List<Contenu>? contenus;
  final String? apiToken;
  final DateTime? tokenExpiresAt;
  final bool isActif;

  Utilisateur({
    required this.id,
    required this.email,
    required this.role,
    this.diagnostics,
    required this.nom,
    required this.prenom,
    required this.dateNaissance,
    this.username,
    this.photProfil,
    this.contenus,
    this.apiToken,
    this.tokenExpiresAt,
    required this.isActif
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      email: json['email'] as String,
      role: Role.fromJson(json['role'] as Map<String, dynamic>),
      diagnostics: (json['diagnostics'] != null && json['diagnostics'] is List)
          ? (json['diagnostics'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Diagnostic.fromJson(item))
          .toList()
          : [],
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['dateNaissance'] as String),
      username: json['username'] as String?,
      photProfil: json['photoProfile'] as String?,
      contenus: (json['contenus'] != null && json['contenus'] is List)
          ? (json['contenus'] as List)
          .whereType<Map<String, dynamic>>()
          .map((item) => Contenu.fromJson(item))
          .toList()
          : [],
      apiToken: json['apiToken'] as String?,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.parse(json['tokenExpiresAt'] as String)
          : null,
      isActif: json['isActif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role.toJson(),
    if (diagnostics != null)
      'diagnostics': diagnostics?.map((d) => d.toJson()).toList(),
    'nom': nom,
    'prenom': prenom,
    'dateNaissance': dateNaissance.toIso8601String(),
    if (username != null) 'username': username,
    'photoProfile': photProfil,
    if (contenus != null) 'contenus': contenus?.map((c) => c.toJson()).toList(),
    if (apiToken != null) 'apiToken': apiToken,
    if (tokenExpiresAt != null) 'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
    if (tokenExpiresAt != null) 'isActif': isActif,
  };
}