class Contenu {
  final int id;
  final String? titre;
  final String? description;
  final String? image;
  final String? url;
  final DateTime? dateCreation;

  Contenu({
    required this.id,
    this.titre,
    this.description,
    this.image,
    this.url,
    this.dateCreation
  });

  factory Contenu.fromJson(Map<String, dynamic> json) {
    print('Conversion contenu: $json');
    try {
      return Contenu(
        id: json['id'] as int,
        titre: json['titre'] as String?,
        description: json['description'] as String?,
        image: json['image'] as String?,
        url: json['url'] as String?,
        dateCreation: json['date_creation'] != null
            ? DateTime.parse(json['date_creation'])
            : null,
      );
    } catch (e) {
      print('Erreur lors de la conversion du contenu: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (titre != null) 'titre': titre,
    if (description != null) 'description': description,
    if (image != null) 'image': image,
    if (url != null) 'url': url,
    if (dateCreation != null) 'date_creation': dateCreation!.toIso8601String(),
  };
}