import 'package:cesizen_mobile/models/Diagnostic.dart';
import 'package:cesizen_mobile/models/Event.dart';

class Reponse {
  final int id;
  final List<Event> events;

  Reponse({
    required this.id,
    required this.events,
  });

  factory Reponse.fromJson(Map<String, dynamic> json) => Reponse(
    id: json['id'] as int,
    events: (json['events'] as List<dynamic>?)?.map((e) {
      if (e is Map<String, dynamic>) {
        return Event(
          id: e['id'] as int,
          nom: e['nom'] as String,
          stress: 0,
          reponses: [],
        );
      }
      throw FormatException('Format d\'event invalide');
    }).toList() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'events': events.map((e) => {'id': e.id}).toList(),
  };
}