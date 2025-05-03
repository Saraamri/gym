import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'coursdetail_page.dart';
import 'add_cours_page.dart';
import 'edit_cours_page.dart'; // ← Ajouté pour édition
import 'package:shimmer/shimmer.dart';

class CoursPage extends StatefulWidget {
  const CoursPage({super.key});

  @override
  _CoursPageState createState() => _CoursPageState();
}

class _CoursPageState extends State<CoursPage> {
  List<dynamic> data = [];
  bool isLoading = true;

  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8081/api'
      : 'http://192.168.199.18:8081/api';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final url = '$baseUrl/coursCollectifs/getAll';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        data = decoded;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Erreur lors du chargement des données : ${response.statusCode}");
    }
  }

  // 🔥 Fonction de suppression avec confirmation
  Future<void> deleteCours(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer ce cours ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.delete(Uri.parse('$baseUrl/coursCollectifs/delete/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cours supprimé")));
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : ${response.statusCode}")));
      }
    }
  }

  // 🔄 Fonction navigation vers édition
  void navigateToEdit(Map<String, dynamic> cours) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCoursPage(item: cours)),
    );
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 245, 241, 241),
        elevation: 1,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCoursPage()),
                ).then((_) => fetchData());
              },
              child: const Text(
                "Nouveau",
                style: TextStyle(color: Color.fromARGB(255, 129, 3, 91), fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonction de recherche à implémenter')),
                );
              },
              child: const Text(
                "Recherche",
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : data.isEmpty
              ? const Center(child: Text("Aucun cours trouvé"))
              : Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(
                    child: SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          final imageUrl = '$baseUrl${item['image']}';

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CoursDetailPage(item: item),
                                ),
                              );
                            },
                            child: Container(
                              width: 200,
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      imageUrl,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image, size: 60),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['nom'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['description'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        // 🔥 Modification et Suppression
                                        const SizedBox(height: 10), // Espacement entre description et boutons
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            OutlinedButton(
                                              onPressed: () => navigateToEdit(item),
                                              child: const Text(
                                                'Modifier',
                                                style: TextStyle(color: Color.fromARGB(255, 99, 4, 103)),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Color.fromARGB(255, 235, 185, 218)),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                            ),
                                            OutlinedButton(
                                              onPressed: () => deleteCours(item['id']),
                                              child: const Text(
                                                'Supprimer',
                                                style: TextStyle(color: Color.fromARGB(255, 170, 229, 233)),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: Color.fromARGB(255, 111, 61, 58)),
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
    );
  }
}
