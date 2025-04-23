import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoursPage extends StatefulWidget {
  const CoursPage({super.key});

  @override
  State<CoursPage> createState() => _CoursPageState();
}

class _CoursPageState extends State<CoursPage> {
  String selectedType = 'collectifs';
  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Charger les cours collectifs par défaut
  }

  Future<void> fetchData() async {
    final url = selectedType == 'collectifs'
        ? 'http://127.0.0.1:8081/api/coursCollectifs/getAll'
        : 'http://127.0.0.1:8081/seances';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      setState(() {
        data = selectedType == 'individuelles'
            ? decoded.where((s) => s['proposeeParCoach'] == true).toList()
            : decoded;
      });
    } else {
      print("Erreur lors du chargement des données : ${response.statusCode}");
    }
  }

  Future<void> reserverCours(int coursId) async {
    final adherentId = 1; // À remplacer dynamiquement selon l'utilisateur connecté
    final url = Uri.parse(
        'http://127.0.0.1:8081/api/reservations/reservercours?adherentId=$adherentId&coursId=$coursId');

    try {
      final response = await http.post(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Réservation réussie')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
    }
  }

  Future<void> demanderSeance(Map<String, dynamic> coachSeance) async {
    final url = Uri.parse('http://127.0.0.1:8081/seances/demande');

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "titre": coachSeance['titre'],
        "description": coachSeance['description'],
        "coach": coachSeance['coach'],
        "adherent": {"id": 1}, // À remplacer dynamiquement
        "date": coachSeance['date'],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande envoyée')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Échec de la demande')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cours & Séances")),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [
              selectedType == 'collectifs',
              selectedType == 'individuelles'
            ],
            onPressed: (index) {
              setState(() {
                selectedType = index == 0 ? 'collectifs' : 'individuelles';
              });
              fetchData();
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Cours Collectifs"),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text("Séances Individuelles"),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: selectedType == 'collectifs'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item['imageUrl'] != null)
                                Image.network(item['imageUrl']),
                              Text("Nom : ${item['nom'] ?? ''}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("Description : ${item['description'] ?? ''}"),
                              Text("Niveau : ${item['niveau'] ?? ''}"),
                              Text("Durée : ${item['dureeTotale']} min"),
                              Text("Jour : ${item['jours'] ?? ''}"),
                              Text("Horaire : ${item['horaire'] ?? ''}"),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => reserverCours(item['id']),
                                child: const Text("Réserver"),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Objectif : ${item['objectif'] ?? ''}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text("Statut : ${item['statut'] ?? ''}"),
                              Text("Lieu : ${item['lieu'] ?? ''}"),
                              Text("Date : ${item['date'] ?? ''}"),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => demanderSeance(item),
                                child: const Text("Demander"),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
