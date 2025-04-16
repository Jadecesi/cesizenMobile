class Contenu {
  final int id;
  final String titre;
  final String description;
  final String image;
  final String? url;

  Contenu({
    required this.id,
    required this.titre,
    required this.description,
    required this.image,
    this.url,
  });

  factory Contenu.fromJson(Map<String, dynamic> json) {
    return Contenu(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      image: json['image'],
      url: json['url'],
    );
  }
}
