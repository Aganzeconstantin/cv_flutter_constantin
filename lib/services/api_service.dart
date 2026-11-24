import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/famille_membre.dart';

/// Adresse de l'API PHP (XAMPP).
///
/// - Web / Windows / iOS simulateur : localhost
/// - Émulateur Android : 10.0.2.2 (= localhost du PC)
/// - Téléphone réel : remplacer par l'IP du PC (ex. http://192.168.1.10/api-test/public)
String get apiBaseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2/api-test/public';
  }
  return 'http://localhost/api-test/public';
}

/// Erreur renvoyée par l'API : message + erreurs par champ (code 422).
class ApiException implements Exception {
  final String message;
  final Map<String, String> errors;
  final int? statusCode;

  ApiException(this.message, {this.errors = const {}, this.statusCode});

  /// Message complet, avec le détail des champs invalides.
  String get details =>
      errors.isEmpty ? message : '$message\n${errors.values.join('\n')}';

  @override
  String toString() => details;
}

/// Compte renvoyé par /accounts/login et /accounts/register.
class Account {
  final int id;
  final String email;

  Account({required this.id, required this.email});

  factory Account.fromJson(Map<String, dynamic> json) =>
      Account(id: int.parse(json['id'].toString()), email: json['email']);
}

class ApiService {
  static const _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  static const _timeout = Duration(seconds: 15);

  static Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  /// Décode la réponse JSON et lève une [ApiException] si success == false.
  static dynamic _handle(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(utf8.decode(response.bodyBytes));
    } catch (_) {
      throw ApiException(
        'Réponse invalide du serveur (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
    if (body['success'] != true) {
      final rawErrors = body['errors'];
      throw ApiException(
        body['message']?.toString() ?? 'Erreur inconnue',
        errors: rawErrors is Map
            ? rawErrors.map((k, v) => MapEntry(k.toString(), v.toString()))
            : const {},
        statusCode: response.statusCode,
      );
    }
    return body['data'];
  }

  /// Exécute la requête en transformant les erreurs réseau en message clair.
  static Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      return _handle(response);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Impossible de joindre le serveur.\n'
        'Vérifiez qu\'Apache et MySQL sont démarrés dans XAMPP.',
      );
    }
  }

  // ---------------------------------------------------------------- Comptes

  static Future<Account> login(String email, String password) async {
    final data = await _send(() => http.post(
          _uri('/accounts/login'),
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        ));
    return Account.fromJson(data);
  }

  static Future<Account> register(String email, String password) async {
    final data = await _send(() => http.post(
          _uri('/accounts/register'),
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        ));
    return Account.fromJson(data);
  }

  // ------------------------------------------------------- Membres de famille

  static Future<List<FamilleMembre>> getMembres() async {
    final data = await _send(() => http.get(_uri('/famille-membres')));
    return (data as List)
        .map((e) => FamilleMembre.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Crée un membre. Avec [image] : envoi en form-data, sinon en JSON.
  static Future<FamilleMembre> createMembre(
    FamilleMembre membre, {
    XFile? image,
  }) async {
    final data = image != null
        ? await _sendMultipart('/famille-membres', membre, image)
        : await _send(() => http.post(
              _uri('/famille-membres'),
              headers: _jsonHeaders,
              body: jsonEncode(membre.toJson()),
            ));
    return FamilleMembre.fromJson(data);
  }

  /// Modifie un membre. Avec [image] : POST form-data (remplace la photo),
  /// sinon PUT JSON (la photo actuelle est conservée).
  static Future<FamilleMembre> updateMembre(
    int id,
    FamilleMembre membre, {
    XFile? image,
  }) async {
    final data = image != null
        ? await _sendMultipart('/famille-membres/$id', membre, image)
        : await _send(() => http.put(
              _uri('/famille-membres/$id'),
              headers: _jsonHeaders,
              body: jsonEncode(membre.toJson()),
            ));
    return FamilleMembre.fromJson(data);
  }

  static Future<void> deleteMembre(int id) async {
    await _send(() => http.delete(_uri('/famille-membres/$id')));
  }

  static Future<dynamic> _sendMultipart(
    String path,
    FamilleMembre membre,
    XFile image,
  ) async {
    final bytes = await image.readAsBytes();
    return _send(() async {
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers['Accept'] = 'application/json'
        ..fields.addAll(membre.toJson())
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        ));
      return http.Response.fromStream(await request.send());
    });
  }
}
