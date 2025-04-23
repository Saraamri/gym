import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AbonnementPage extends StatefulWidget {
  const AbonnementPage({super.key});

  @override
  State<AbonnementPage> createState() => _AbonnementPageState();
}

class _AbonnementPageState extends State<AbonnementPage> {
  List<dynamic> abonnements = [];

  @override
  void initState() {
    super.initState();
    fetchAbonnements();
  }

  Future<void> fetchAbonnements() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8081/api/abonnements/getAll"));
    
    if (response.statusCode == 200) {
      setState(() {
        abonnements = jsonDecode(response.body);
      });
    } else {
      print("Erreur lors du chargement des abonnements");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choisissez un Abonnement")),
      body: abonnements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: abonnements.length,
              itemBuilder: (context, index) {
                final abo = abonnements[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(abo['type']),
                    subtitle: Text("Durée : ${abo['dateDebut']} ➜ ${abo['dateFin']}\nStatut : ${abo['statut']}"),
                    trailing: Text("${abo['prix']} €"),
                    onTap: () {
                      // Action: aller vers la page de paiement
                    },
                  ),
                );
              },
            ),
    );
  }
}
