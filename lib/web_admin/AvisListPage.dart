import 'package:flutter/material.dart';
import 'package:gymaccess/model/comment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
class AvisListPage extends StatefulWidget {
  @override
  _AvisListPageState createState() => _AvisListPageState();
}

class _AvisListPageState extends State<AvisListPage> {
  List<Commentaire> commentaires = [];

  @override
  void initState() {
    super.initState();
    fetchCommentaires();
  }

  Future<void> fetchCommentaires() async {
    final response = await http.get(Uri.parse('http://localhost:8081/api/comments/all'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        commentaires = data.map((json) => Commentaire.fromJson(json)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des commentaires')),
      );
    }
  }

  Future<void> desactiverCommentaire(int commentId) async {
    final response = await http.put(
      Uri.parse('http://localhost:8081/api/comments/disable/$commentId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Commentaire désactivé avec succès')),
      );
      fetchCommentaires(); // Refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la désactivation')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion des Avis'),
      ),
      body: commentaires.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: commentaires.length,
              itemBuilder: (context, index) {
                final c = commentaires[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.comment, color: Colors.blue),
                    title: Text(c.nomAuteur ?? 'Utilisateur inconnu'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.body),
                        SizedBox(height: 4),
                        Text(
                          c.created ?? '',
                          style: TextStyle(color: Colors.grey),
                        ),
                        if (!c.active)
                          Text(
                            'Commentaire désactivé',
                            style: TextStyle(color: Colors.red),
                          ),
                      ],
                    ),
                    trailing: c.active
                        ? IconButton(
                            icon: Icon(Icons.block, color: Colors.orange),
                            tooltip: 'Désactiver ce commentaire',
                            onPressed: () => desactiverCommentaire(c.commentId),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
