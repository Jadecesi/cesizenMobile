class Role {
  final int? id;  // Rendu optionnel
  final String nom;

  Role({this.id, required this.nom});  // id est maintenant optionnel

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int?,  // Utilisation de int? pour accepter null
      nom: json['nom'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'nom': nom,
  };
}