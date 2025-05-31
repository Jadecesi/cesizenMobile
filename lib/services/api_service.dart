import 'dart:convert';
import '../models/Diagnostic.dart';
import '../models/Event.dart';
import '../models/Reponse.dart';
import '../models/Utilisateur.dart';
import 'package:http/http.dart' as http;
import '../models/contenu.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../exceptions/ApiException.dart';

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
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = getContenuImageUrl(url);
      }

      final response = await http.head(Uri.parse(url)).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
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

      // Décoder la réponse JSON quelle que soit la réponse
      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data.containsKey('id')) {
          final user = Utilisateur.fromJson(data);
          final token = data['apiToken'];

          if (token != null) {
            await _storeToken(token);
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('current_user', jsonEncode(data));
            return user;
          } else {
            throw ApiException('Token manquant dans la réponse');
          }
        } else {
          throw ApiException('ID utilisateur manquant dans la réponse');
        }
      } else {
        final errorMessage = data['error'] ?? 'Erreur inconnue';
        throw ApiException(errorMessage);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Erreur de connexion: ${e.toString()}');
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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Contenu.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
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

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Diagnostic.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Erreur HTTP: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      throw Exception('Erreur lors de la récupération des diagnostics: $e');
    }
  }

  static Future<List<Utilisateur>> fetchAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'api_token')}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Utilisateur.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw ApiException('Non autorisé : token invalide ou manquant');
      } else if (response.statusCode == 403) {
        throw ApiException('Accès refusé : droits administrateur requis');
      } else {
        throw ApiException('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Erreur lors de la récupération des utilisateurs : ${e.toString()}');
    }
  }

  static Future<bool> toggleUserStatus(int userId) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/user/$userId/statut'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'api_token')}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isActif'];
      } else if (response.statusCode == 401) {
        throw ApiException('Non autorisé : token invalide ou manquant');
      } else if (response.statusCode == 403) {
        throw ApiException('Accès refusé : droits administrateur requis');
      } else {
        throw ApiException('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Erreur lors de la mise à jour du statut : ${e.toString()}');
    }
  }

  static Future<bool> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/user/$userId/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'api_token')}',
        },
      );

      final data = jsonDecode(response.body);

      print('retourn json suppresion user: $data');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(data['error'] ?? 'Une erreur est survenue');;
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Erreur lors de la suppression de l\'utilisation : ${e.toString()}');
    }
  }

  static Future<bool> deleteDiagnostic(int diagnosticId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/diagnostic/$diagnosticId/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${await _storage.read(key: 'api_token')}',
        },
      );

      final data = jsonDecode(response.body);

      print('retourn json suppresion diagnostic: $data');

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(data['error'] ?? 'Une erreur est survenue');;
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Erreur lors de la suppression du diagnostic : ${e.toString()}');
    }
  }

  static Future<Utilisateur> editUser(int idUser, String token,String nom, String prenom, String email, String username) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/user/$idUser/edit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'username': username
        }),
      );

      final $data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = Utilisateur.fromJson($data);
        final tokenResponse = $data['apiToken'];

        if (tokenResponse != null) {
          await _storeToken(tokenResponse);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('current_user', jsonEncode($data));
          return user;
        } else {
          throw ApiException('Token manquant dans la réponse');
        }
      } else {
        final errorMessage = $data['error'] ?? 'Erreur inconnue';
        throw ApiException(errorMessage);
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Erreur de connexion: ${e.toString()}');
    }
  }
}