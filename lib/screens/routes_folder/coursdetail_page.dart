import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursDetailPage extends StatefulWidget {
  final dynamic item;

  const CoursDetailPage({Key? key, this.item}) : super(key: key);

  @override
  _CoursDetailPageState createState() => _CoursDetailPageState();
}

class _CoursDetailPageState extends State<CoursDetailPage> {
  bool isLoading = false;
  String? role;
  int? userId;
  int? coursId;

  @override
  void initState() {
    super.initState();
    coursId = widget.item['id']; // Récupération du coursId
    _loadUserFromToken();
    print("ID du cours : $coursId");
  }

  Future<void> _loadUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      setState(() {
        role = payload['role'];
        userId = payload['id'];
        print("Utilisateur ID: $userId, Rôle: $role");
      });
    } else {
      print("Token introuvable.");
    }
  }

  Future<void> _reserverCours() async {
    if (userId == null || coursId == null) {
      print("Erreur : userId ou coursId est null");
      return;
    }

    setState(() {
      isLoading = true;
    });

    final url = Uri.parse(
        'http://127.0.0.1:8081/api/reservations/reservercours?adherentId=$userId&coursId=$coursId');

    final response = await http.post(url);

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Réservation réussie')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de réservation')),
      );
      print("Réponse d'erreur: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item['nom'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            item['image'] != null
                ? Image.network(
                    'http://127.0.0.1:8081/api${item['image']}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Icon(Icons.error, size: 50));
                    },
                  )
                : const Icon(Icons.image),
            const SizedBox(height: 16),
            Text(
              'Nom: ${item['nom']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Description: ${item['description']}'),
            const SizedBox(height: 8),
            Text('Durée: ${item['dureeTotale']} min'),
            const SizedBox(height: 8),
            Text('Niveau: ${item['niveau']}'),
            const SizedBox(height: 8),
            Text('Jour: ${item['jours']}'),
            const SizedBox(height: 8),
            Text('Horaire: ${item['horaire']}'),
            const SizedBox(height: 16),

            // Bouton visible uniquement pour les adhérents
            if (role == 'ADHERENT')
              ElevatedButton(
                onPressed: isLoading ? null : _reserverCours,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Réserver'),
              ),
          ],
        ),
      ),
    );
  }
}
