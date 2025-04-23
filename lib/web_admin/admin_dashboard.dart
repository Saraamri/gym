import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> _abonnements = [];

  @override
  void initState() {
    super.initState();
    _fetchAbonnements();  // Appeler la méthode pour récupérer les abonnements
  }

  // Récupérer les abonnements depuis le backend
  Future<void> _fetchAbonnements() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8081/abonnements/getAll'));

    if (response.statusCode == 200) {
      setState(() {
        _abonnements = json.decode(response.body);
      });
    } else {
      throw Exception('Échec de la récupération des abonnements');
    }
  }

  // Supprimer un abonnement
  Future<void> _deleteAbonnement(int id) async {
    final response = await http.delete(Uri.parse('http://127.0.0.1:8081/abonnements/delete/$id'));

    if (response.statusCode == 200) {
      setState(() {
        _abonnements.removeWhere((abonnement) => abonnement['id'] == id);
      });
    } else {
      throw Exception('Échec de la suppression de l\'abonnement');
    }
  }

  // Ajouter un abonnement (cette partie peut être modifiée selon la manière dont tu veux ajouter un abonnement)
  Future<void> _addAbonnement() async {
    final newAbonnement = {
      'type': 'Mensuel',
      'prix': 30.0,
    };

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8081/abonnements/add'),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: json.encode(newAbonnement),
    );

    if (response.statusCode == 200) {
      _fetchAbonnements();  // Rafraîchir la liste après ajout
    } else {
      throw Exception('Échec de l\'ajout de l\'abonnement');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _addAbonnement,
              child: Text("Ajouter un Abonnement"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _abonnements.length,
                itemBuilder: (context, index) {
                  final abonnement = _abonnements[index];
                  return ListTile(
                    title: Text(abonnement['type']),
                    subtitle: Text("Prix: ${abonnement['prix']} DT"),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteAbonnement(abonnement['id']),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
