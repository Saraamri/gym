import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class AdminCoursPage extends StatefulWidget {
  const AdminCoursPage({super.key});

  @override
  State<AdminCoursPage> createState() => _AdminCoursPageState();
}

class _AdminCoursPageState extends State<AdminCoursPage> {
  List<dynamic> cours = [];
  bool isLoading = true;

  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8081/api'
      : 'http://192.168.199.18:8081/api';

  @override
  void initState() {
    super.initState();
    fetchCours();
  }

  Future<void> fetchCours() async {
    final response = await http.get(Uri.parse('$baseUrl/coursCollectifs/getAll'));
    if (response.statusCode == 200) {
      setState(() {
        cours = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Erreur : ${response.statusCode}");
    }
  }

  Future<void> deleteCours(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Supprimer le cours"),
        content: const Text("Êtes-vous sûr de vouloir supprimer ce cours ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Supprimer")),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.delete(Uri.parse('$baseUrl/coursCollectifs/delete/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cours supprimé")));
        fetchCours();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : ${response.statusCode}")));
      }
    }
  }

  Widget buildCoursCard(Map<String, dynamic> item) {
    final imageUrl = '$baseUrl${item['image']}';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // For spacing between cards
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with horizontal scrolling
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: 300, // Limiting the width of the image container
                  height: 150, // Limiting the height of the image
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      imageUrl,
                      width: 300, // Ensure image doesn't exceed container width
                      height: 150, // Ensure image doesn't exceed container height
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Nom: ${item['nom']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Description: ${item['description']}', style: const TextStyle(fontSize: 14)),
              Text('Durée: ${item['dureeTotale']} min'),
              Text('Niveau: ${item['niveau']}'),
              Text('Jour: ${item['jours']}'),
              Text('Horaire: ${item['horaire']}'),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  label: const Text("Supprimer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onPressed: () => deleteCours(item['id']),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestion des Cours (Admin)", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cours.isEmpty
              ? const Center(child: Text("Aucun cours disponible"))
              : ListView.builder(
                  itemCount: cours.length,
                  itemBuilder: (context, index) => buildCoursCard(cours[index]),
                ),
    );
  }
}
