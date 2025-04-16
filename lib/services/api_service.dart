import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contenu.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.53:8001'; // ou IP locale

  static String getContenuImageUrl(String fileName) {
    return '$baseUrl/uploads/contenu/$fileName';
  }

  static Future<List<Contenu>> fetchContenus() async {
    final response = await http.get(Uri.parse('$baseUrl/api/contenus'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Contenu.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des contenus');
    }
  }
}
