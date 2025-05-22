import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'coursdetail_page.dart';
import 'add_cours_page.dart';
import 'edit_cours_page.dart';
import 'package:shimmer/shimmer.dart';

class CoursPage extends StatefulWidget {
  const CoursPage({super.key});

  @override
  State<CoursPage> createState() => _CoursPageState();
}

class _CoursPageState extends State<CoursPage> {
  List<dynamic> coursList = [];
  bool isLoading = true;
  String role = '';
  int userId = 0;
  int coachId = 0;
  String token = '';

  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8081/api'
      : 'http://192.168.199.18:8081/api';

  @override
  void initState() {
    super.initState();
    initUserAndFetch();
  }

  Future<void> initUserAndFetch() async {
    await _loadUserData();
    await _fetchCours();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      final payload = JwtDecoder.decode(token);
      setState(() {
        role = payload['role'] ?? '';
        userId = payload['id'] ?? 0;
        if (role == 'COACH') coachId = userId;
      });

      debugPrint('Connecté - ID: $userId, Rôle: $role');
    }
  }

  Future<void> _fetchCours() async {
    setState(() => isLoading = true);

    final url = (role == 'COACH')
        ? '$baseUrl/coursCollectifs/getByCoach/$coachId'
        : '$baseUrl/coursCollectifs/getAll';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          coursList = json.decode(response.body);
        });
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur de chargement : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des cours')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteCours(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment supprimer ce cours ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response =
            await http.delete(Uri.parse('$baseUrl/coursCollectifs/delete/$id'));
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cours supprimé')),
          );
          _fetchCours();
        } else {
          throw Exception('Erreur ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression')),
        );
      }
    }
  }

  void _navigateToEdit(Map<String, dynamic> cours) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCoursPage(item: cours)),
    );
    _fetchCours();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 241, 241),
      appBar: AppBar(
        actions: role == 'COACH'
            ? [
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    color: Color.fromARGB(255, 13, 122, 126),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddCoursPage()),
                    );
                    _fetchCours();
                  },
                )
              ]
            : null,
      ),
      body: isLoading
          ? _buildLoadingShimmer()
          : coursList.isEmpty
              ? const Center(child: Text('Aucun cours trouvé'))
              : _buildCoursList(),
    );
  }

  Widget _buildLoadingShimmer() {
    return Center(
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (_, __) => Shimmer.fromColors(
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
          ),
        ),
      ),
    );
  }

  Widget _buildCoursList() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListView.builder(
        itemCount: coursList.length,
        itemBuilder: (context, index) {
          final item = coursList[index];
          final imageUrl = '$baseUrl${item['image']}';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoursDetailPage(item: item),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['nom'] ?? 'Sans nom',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Durée : ${item['dureeTotale']} min',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (role == 'COACH') ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              OutlinedButton(
                                onPressed: () => _navigateToEdit(item),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color.fromARGB(255, 129, 3, 91),
                                  ),
                                ),
                                child: const Text(
                                  'Modifier',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 129, 3, 91),
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () => _deleteCours(item['id']),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.redAccent),
                                ),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 60),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
