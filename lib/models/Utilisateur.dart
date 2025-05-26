import 'package:cesizen_mobile/models/Diagnostic.dart';
import 'package:cesizen_mobile/models/Role.dart';
import 'package:cesizen_mobile/models/Contenu.dart';


class Utilisateur {
  final int id;
  final String email;
  final Role role;  // Changé de List<Role> à Role
  final List<Diagnostic>? diagnostics;  // Changé de 'diagnostic' à 'diagnostics' pour correspondre à la réponse JSON
  final String nom;
  final String prenom;
  final DateTime dateNaissance;
  final String? username;
  final String? photProfil;  // Changé pour correspondre à 'photoProfile' dans la réponse
  final List<Contenu>? contenus;  // Changé de 'contenu' à 'contenus' pour correspondre à la réponse JSON
  final String? apiToken;
  final DateTime? tokenExpiresAt;

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
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] as int,
      email: json['email'] as String,
      role: Role.fromJson(json['role'] as Map<String, dynamic>),
      diagnostics: json['diagnostics'] != null
          ? (json['diagnostics'] as List<dynamic>)
          .map((e) => Diagnostic.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      dateNaissance: DateTime.parse(json['dateNaissance']),
      username: json['username'] as String?,
      photProfil: json['photoProfile'] as String?,
      contenus: json['contenus'] != null
          ? (json['contenus'] as List<dynamic>)
          .map((e) => Contenu.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      apiToken: json['apiToken'] as String?,
      tokenExpiresAt: json['tokenExpiresAt'] != null
          ? DateTime.parse(json['tokenExpiresAt'])
          : null,
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
    if (tokenExpiresAt != null)
      'tokenExpiresAt': tokenExpiresAt?.toIso8601String(),
  };
}