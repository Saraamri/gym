import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/objectif.dart';


class ObjectifService {
  final String baseUrl = "http://127.0.0.1:8081/api/objectifs";
  final storage = FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: 'jwt_token');
  }

  Future<List<Objectif>> getObjectifs(String role) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(role == "COACH" ? "$baseUrl/all" : "$baseUrl/mine"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((json) => Objectif.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des objectifs');
    }
  }

  Future<void> addObjectif(Objectif objectif) async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode(objectif.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Erreur lors de l'ajout");
  }

  Future<void> updateObjectif(int id, Objectif objectif) async {
    final token = await getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/update/$id"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode(objectif.toJson()),
    );
    if (response.statusCode != 200) throw Exception("Erreur lors de la mise à jour");
  }

  Future<void> deleteObjectif(int id) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse("$baseUrl/delete/$id"),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) throw Exception("Erreur lors de la suppression");
  }
}
