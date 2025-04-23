import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  // Méthode pour se connecter
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
      throw Exception("Failed to login");
    }
  }

  Future<String> register({
  required String firstName,
  required String lastName,
  required String email,
  required String username,
  required String password,
  required String confPassword,
  String? specialite,
  required String telephone,
  required double age,
  required String adresse,
  String? profilePicture,
  bool isActive = true,
  bool isAccountNonLocked = true,
  String role = 'ADHERENT',
}) async {
  final url = Uri.parse("http://127.0.0.1:8081/api/user/add");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "username": username,
      "password": password,
      "confPassword": confPassword,
      "specialite": role.toUpperCase() == "COACH" ? specialite : null,
      "telephone": telephone,
      "age": age,
      "adresse": adresse,
      "profilePicture": profilePicture,
      "isActive": isActive,
      "isAccountNonLocked": isAccountNonLocked,
     "role": {
  "roleName": role.toUpperCase()
}// Envoie sous forme de string simple
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return "Inscription réussie";
  } else {
    print("Erreur d'inscription: ${response.statusCode}");
    print("Message: ${response.body}");
    throw Exception("Échec de l'inscription");
  }
}

    

  // Méthode pour stocker le token JWT
  Future<void> storeToken(String token) async {
    await storage.write(key: 'jwt_token', value: token);
  }

  // Méthode pour récupérer le token JWT
  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }
}

// Classe pour la réponse de l'authentification
class AuthResponse {
  final String token;
  final String username;
  final int expiresAt;

  AuthResponse({
    required this.token,
    required this.username,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      username: json['username'],
      expiresAt: json['expiresAt'],
    );
  }
}