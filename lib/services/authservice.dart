import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final storage = FlutterSecureStorage();

 
  Future<AuthResponse> login(String username, String password) async {
    final url = Uri.parse("http://127.0.0.1:8081/api/auth/login");
    print("Tentative de connexion avec le nom d'utilisateur: $username");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({"username": username, "password": password}),
    );

    print("Réponse du serveur: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Données reçues: $data");

      AuthResponse authResponse = AuthResponse.fromJson(data);
      print("Réponse de l'authentification: $authResponse");

      await storeToken(authResponse.token);
      return authResponse;
    } else {
      final data = json.decode(response.body);
      String errorMessage = data['message'] ?? data['error'] ?? 'Erreur inconnue';
      print("Erreur lors de la connexion: $errorMessage");
      throw Exception(errorMessage);
    }
  }

  Future<void> storeToken(String token) async {
    print("Stockage du token...");
    if (token == null || token.isEmpty) {
      print("Erreur: Le token est null ou vide");
    }
    await storage.write(key: 'jwt_token', value: token);
    print("Token stocké avec succès");

    
  }

  Future<String?> getToken() async {
    final token = await storage.read(key: 'jwt_token');
    print("Token récupéré: $token");

    if (token == null) {
      print("Erreur: Token non trouvé");
      throw Exception('Token non trouvé');
    }
    return token;
  }
}
class AuthResponse {
  final String token;
  final String username;
  final String email;
  final String role;
  final int? expiresAt;

  AuthResponse({
    required this.token,
    required this.username,
    required this.email,
    required this.role,
    this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print("Données JSON reçues: $json");

    return AuthResponse(
      token: json['token'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      expiresAt: json['expiresAt'] ?? 0,
    );
  }
}
