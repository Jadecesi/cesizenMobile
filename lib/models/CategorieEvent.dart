import 'package:cesizen_mobile/models/Event.dart';

class Contenu {
  final int id;
  final String? libelle;
  final List<Event> events;

  Contenu({
    required this.id,
    this.libelle,
    required this.events
  });

  factory Contenu.fromJson(Map<String, dynamic> json) {
    print('Conversion contenu: $json');
    try {
      return Contenu(
        id: json['id'] as int,
        libelle: json['libelle'] as String?,
        events: (json['events'] as List<dynamic>)
            .map((e) => Event.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      print('Erreur lors de la conversion du contenu: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    if (libelle != null) 'libelle': libelle,
    'events': events.map((e) => e.toJson()).toList(),
  };
}