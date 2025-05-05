import 'package:flutter/material.dart';
import 'edit_abonnement_page.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_abonnement_page.dart';

class AbonnementListPage extends StatefulWidget {
  @override
  _AbonnementListPageState createState() => _AbonnementListPageState();
}

class _AbonnementListPageState extends State<AbonnementListPage> {
  List<dynamic> _abonnements = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAbonnements();
  }

  Future<void> _fetchAbonnements() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8081/api/abonnements/getAll'));
      if (response.statusCode == 200) {
        setState(() {
          _abonnements = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Erreur lors de la récupération des abonnements';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion au serveur';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAbonnement(int id) async {
    final bool confirmed = await _showDeleteConfirmationDialog();
    if (confirmed) {
      try {
        final response = await http.delete(Uri.parse('http://127.0.0.1:8081/api/abonnements/delete/$id'));
        if (response.statusCode == 200) {
          setState(() {
            _abonnements.removeWhere((abonnement) => abonnement['id'] == id);
          });
        } else {
          throw Exception('Erreur lors de la suppression');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression')));
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return (await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text('Êtes-vous sûr de vouloir supprimer cet abonnement ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    )) ?? false;  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
  title: Text('Liste des Abonnements'),
  actions: [
    Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 236, 163, 213), // couleur de l'icône et du texte
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 3,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddAbonnementPage()),
          ).then((_) {
            _fetchAbonnements();
          });
        },
     
        label: Text(
          'Nouveau',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
  ],
),







       
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: TextStyle(color: Colors.red)))
              : ListView.builder(
                  itemCount: _abonnements.length,
                  itemBuilder: (context, index) {
                    final abonnement = _abonnements[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(abonnement['type']),
                        subtitle: Text("Prix: ${abonnement['prix']} DT"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.orange),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAbonnementPage(abonnementId: abonnement['id']),  
                                  ),
                                ).then((_) {
                                  _fetchAbonnements();  
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAbonnement(abonnement['id']),
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
