import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  // Login (inchangé)
  Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse("http://127.0.0.1:8081/api/auth/login");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      AuthResponse authResponse = AuthResponse.fromJson(data);
      await storeToken(authResponse.token);
      return authResponse;
    } else {
          final data = json.decode(response.body);
  String errorMessage = data['message'] ?? data['error'] ?? 'Erreur inconnue';

      throw Exception(errorMessage);
    }
  }

  Future<void> storeToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }
}

class AuthResponse {
  final String token;
  final String username;
  final int? expiresAt;

  AuthResponse({
    required this.token,
    required this.username,
     this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      username: json['username'],
      expiresAt: json['expiresAt'],
    );
  }
}
