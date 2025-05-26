import 'dart:convert';
import 'package:cesizen_mobile/models/Diagnostic.dart';
import 'package:cesizen_mobile/models/Event.dart';
import 'package:cesizen_mobile/models/Reponse.dart';
import 'package:cesizen_mobile/models/Utilisateur.dart';
import 'package:http/http.dart' as http;
import '../models/contenu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const _storage = FlutterSecureStorage();
  static const String _baseUrl = 'http://192.168.1.53:8000';

  static Future<void> _storeToken(String token) async {
    await _storage.write(key: 'api_token', value: token);
  }

  static Future<void> logout() => _storage.delete(key: 'api_token');

  static Future<Map<String, String>> _headers(token) async {
    final token = await _storage.read(key: 'api_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Contenu> createContenu(String titre, String image, String description, String url, String token) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/contenus/new'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'titre': titre,
        'image': image,
        'description': description,
        'url': url
      }),
    );

    if (response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData is Map<String, dynamic> && responseData.containsKey('error')) {
        throw Exception(responseData['error']);
      }

      return Contenu(
          id: responseData['id'],
          titre: responseData['titre'],
          image: responseData['image'],
          description: responseData['description'],
          url: responseData['url'],
      );
    } else {
      throw Exception('Erreur lors de la création du contenu: ${response.statusCode}');
    }
  }

  static String getContenuImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return '$_baseUrl/uploads/contenu/default.jpg'; // Image par défaut
    }

    if (fileName.startsWith('http://') || fileName.startsWith('https://')) {
      return fileName;
    } else {
      final encodedFileName = Uri.encodeComponent(fileName.trim());
      return '$_baseUrl/uploads/contenu/$encodedFileName';
    }
  }

  static Future<bool> checkImageExists(String url) async {
    try {
      // Si c'est une image locale, on vérifie l'existence sur notre serveur
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = getContenuImageUrl(url);
      }

      final response = await http.head(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur de vérification image: $e');
      return false;
    }
  }

  static Future<Utilisateur> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('Données JSON décodées : $data');

        print('Conversion des diagnostics...');
        if (data['diagnostics'] != null) {
          print('Diagnostics : ${data['diagnostics']}');
        }

        print('Conversion des contenus...');
        if (data['contenus'] != null) {
          print('Contenus : ${data['contenus']}');
        }

        if (data.containsKey('id')) {
          final user = Utilisateur.fromJson(data);
          final token = data['apiToken'];

          if (token != null) {
            await _storeToken(token);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('current_user', jsonEncode(data));
            return user;
          } else {
            throw Exception('Token manquant dans la réponse');
          }
        } else {
          throw Exception('ID utilisateur manquant dans la réponse');
        }
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  static Future<List<Contenu>> fetchContenus() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/contenus'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé');
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Contenu.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur de connexion : $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  static Future<Reponse> fecthReponseById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/reponses/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Reponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du chargement de la réponse');
    }
  }

  static Future<List<Event>> fetchEvents() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/events'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Délai d\'attente dépassé');
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur de connexion : $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  static Future<Event> fecthEventById(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/events/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return Event.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Erreur lors du chargement de l\'événement');
    }
  }

  static String getUserProfileImageUrl(String? fileName) {
    if (fileName == null || fileName.isEmpty) {
      return '$_baseUrl/uploads/profiles/default.jpg';
    }
    final encodedFileName = Uri.encodeComponent(fileName.trim());
    return '$_baseUrl/uploads/profiles/$encodedFileName';
  }

  static Future<Diagnostic> createDiagnostic(List<Event> selectedEvents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      final userData = jsonDecode(userJson!);
      final userId = userData['id'];

      final response = await http.post(
        Uri.parse('$_baseUrl/api/diagnostic/new-user'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'api_token')}',
        },
        body: jsonEncode({
          'utilisateur_id': userId,
          'selected_events': selectedEvents.map((e) => e.id).toList(),
        }),
      );

      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Réponse du serveur: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return Diagnostic(
          id: responseData['id'] as int,
          totalStress: responseData['totalStress'] != null
              ? (responseData['totalStress'] is int
              ? (responseData['totalStress'] as int).toDouble()
              : responseData['totalStress'] as double)
              : null,
          dateCreation: responseData['dateCreation'] != null
              ? DateTime.parse(responseData['dateCreation'] as String)
              : null,
          utilisateur: responseData['utilisateur'] as Map<String, dynamic>?,
          reponses: responseData['reponses'] != null
              ? (responseData['reponses'] as List)
              .map((r) => Reponse.fromJson(r as Map<String, dynamic>))
              .toList()
              : [],
        );
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Erreur détaillée: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la création du diagnostic: $e');
    }
  }

  static Future<List<Diagnostic>> fetchUserDiagnostics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      final userData = jsonDecode(userJson!);
      final userId = userData['id'];

      final response = await http.get(
        Uri.parse('$_baseUrl/api/diagnostic/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'api_token')}',
        },
      );

      print('Status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Réponse du serveur: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Diagnostic.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('Erreur détaillée: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erreur lors de la récupération des diagnostics: $e');
    }
  }
}