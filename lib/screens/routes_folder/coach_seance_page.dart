import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


import 'package:gymaccess/screens/proposer_seance_page.dart';

import '../../model/SeanceIndividuelle.dart';



class CoachSeancesPage extends StatefulWidget {
  const CoachSeancesPage({super.key});

  @override
  _CoachSeancesPageState createState() => _CoachSeancesPageState();
}

class _CoachSeancesPageState extends State<CoachSeancesPage> {
  List<SeanceIndividuelle> seancesProposees = [];
  List<SeanceIndividuelle> demandesRecues = [];

  @override
  void initState() {
    super.initState();
    fetchSeances();
  }

  Future<void> fetchSeances() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(token.split(".")[1]))));
    final coachId = payload['id'];

    final response = await http.get(
      Uri.parse("http://localhost:8081/api/seances/coach/$coachId"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = json.decode(response.body);
      final List<SeanceIndividuelle> seances =
          decoded.map((e) => SeanceIndividuelle.fromJson(e)).toList();

      setState(() {
        seancesProposees = seances.where((s) => s.proposeeParCoach).toList();
        demandesRecues = seances.where((s) => !s.proposeeParCoach).toList();
      });
    } else {
      print("Erreur ${response.statusCode}: ${response.body}");
    }
  }

  Color getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case "acceptée":
        return Colors.green;
      case "refusée":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget seanceCard(SeanceIndividuelle seance) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          "📅 ${seance.date.toLocal()}".split(' .').first,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text("📍 Lieu : ${seance.lieu}"),
            Text("🎯 Objectif : ${seance.objectif}"),
                      if (seance.adherentUsername != null) Text("👤 Adhérent : ${seance.adherentUsername}"),

          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: getStatutColor(seance.statut).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            seance.statut,
            style: TextStyle(color: getStatutColor(seance.statut), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget demandeCard(SeanceIndividuelle seance) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(16),
            title: Text(
              "📅 ${seance.date.toLocal()}".split(' .').first,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8),
                Text("📍 Lieu : ${seance.lieu}"),
                Text("🎯 Objectif : ${seance.objectif}"),
                Text("👤 Adhérent : ${seance.adherent ?? 'N/A'}"),

              ],
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: getStatutColor(seance.statut).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                seance.statut,
                style: TextStyle(color: getStatutColor(seance.statut), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Divider(height: 1),
          ButtonBar(
            children: [
              TextButton.icon(
                icon: Icon(Icons.check, color: Colors.green),
                label: Text("Accepter"),
                onPressed: () => changerStatut(seance.id, "acceptée"),
              ),
              TextButton.icon(
                icon: Icon(Icons.close, color: Colors.red),
                label: Text("Refuser"),
                onPressed: () => changerStatut(seance.id, "refusée"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> changerStatut(int id, String statut) async {
    final response = await http.put(
      Uri.parse("http://localhost:8081/api/seances/$id/statut?statut=$statut"),
    );
    if (response.statusCode == 200) fetchSeances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Séances - Coach")),
      body: RefreshIndicator(
        onRefresh: fetchSeances,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProposerSeancePage()),
                    );
                    fetchSeances();
                  },
                  icon: Icon(Icons.add),
                  label: Text("Nouvelle séance"),
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Séances Proposées", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...seancesProposees.map(seanceCard).toList(),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("Demandes Reçues", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...demandesRecues.map(demandeCard).toList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
