import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gymaccess/model/user.dart';
import 'package:http/http.dart' as http;

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<User>> _usersFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usersFuture = _fetchUsers();

    // Recherche dynamique : déclenche une recherche à chaque changement de texte
    _searchController.addListener(_searchUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<User>> _fetchUsers() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8081/api/user/all'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des utilisateurs');
    }
  }

  Future<void> _searchUsers() async {
    String email = _searchController.text.trim();

    if (email.isNotEmpty) {
      final response = await http.get(Uri.parse('http://127.0.0.1:8081/api/user/search/email?email=$email'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _usersFuture = Future.value(data.map((e) => User.fromJson(e)).toList());
        });

        if (data.isEmpty) {
          _showError("Aucun utilisateur trouvé.");
        }
      } else {
        _showError("Erreur lors de la recherche par email");
      }
    } else {
      setState(() {
        _usersFuture = _fetchUsers();
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteUser(int userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirmation"),
        content: const Text("Voulez-vous vraiment supprimer cet utilisateur ?"),
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
      final response = await http.delete(Uri.parse('http://127.0.0.1:8081/api/user/delete/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _usersFuture = _fetchUsers();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Utilisateur supprimé")));
      } else {
        _showError("Erreur lors de la suppression");
      }
    }
  }

  Color _getRoleColor(String? role) {
    switch (role?.toUpperCase()) {
      case 'COACH':
        return Colors.green;
      case 'ADHERENT':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: Colors.blueAccent,
        title: Row(
          children: [
            const SizedBox(width: 12),
            const Text('Liste des Utilisateurs'),
            const Spacer(),
            Container(
              width: 250,
              height: 40,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Rechercher par email...",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchUsers(); // recharge tous les utilisateurs
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun utilisateur trouvé"));
          }

          List<User> users = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: users.map((user) {
                String imageUrl = user.profilePicture != null
                    ? 'http://127.0.0.1:8081/api${user.profilePicture}'
                    : 'https://via.placeholder.com/100';

                return Container(
                  width: 200,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: NetworkImage(imageUrl),
                        onBackgroundImageError: (_, __) => const Icon(Icons.broken_image, size: 40),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.email,
                        style: const TextStyle(fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      if (user.role != null) ...[
                        const SizedBox(height: 5),
                        Text(
                          user.role!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getRoleColor(user.role),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => _deleteUser(user.id),
                        child: const Text('Supprimer', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
