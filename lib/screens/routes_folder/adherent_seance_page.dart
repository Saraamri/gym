import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:http/http.dart' as http;
import '../../model/SeanceIndividuelle.dart';
import '../demande_seance_page.dart';
import '../edit_demande_page.dart';

class AdherentSeancesPage extends StatefulWidget {
  @override
  _AdherentSeancesPageState createState() => _AdherentSeancesPageState();
}

class _AdherentSeancesPageState extends State<AdherentSeancesPage> {
  List<SeanceIndividuelle> seancesProposees = [];
  List<SeanceIndividuelle> demandesAdherent = [];
  int? adherentId;

  final String apiBaseUrl = "http://localhost:8081/api/seances";

  @override
  void initState() {
    super.initState();
    initUserData();
  }

  Future<void> initUserData() async {
    int? id = await getUserIdFromToken();
    if (id != null) {
      setState(() {
        adherentId = id;
      });
      fetchSeances();
    } else {
      print("ID non trouvé dans le token");
    }
  }

  Future<int?> getUserIdFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      return payload['id']; // adapter selon ton payload
    }
    return null;
  }

  Future<void> fetchSeances() async {
    await fetchSeancesProposees();
    await fetchDemandesAdherent();
  }

  Future<void> fetchSeancesProposees() async {
    final response = await http.get(Uri.parse("$apiBaseUrl/proposees"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        seancesProposees =
            data.map((item) => SeanceIndividuelle.fromJson(item)).toList();
      });
    } else {
      print("Erreur chargement séances proposées");
    }
  }

  Future<void> fetchDemandesAdherent() async {
    if (adherentId == null) return;

    final response = await http.get(Uri.parse("$apiBaseUrl/adherent/$adherentId"));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        demandesAdherent = data
            .map((item) => SeanceIndividuelle.fromJson(item))
            .where((s) => s.proposeeParCoach == false)
            .toList();
      });
    } else {
      print("Erreur chargement demandes adhérent");
    }
  }

  Future<void> reserverSeance(SeanceIndividuelle s) async {
    final response = await http.put(
      Uri.parse("$apiBaseUrl/${s.id}/statut?statut=réservée"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode == 200) {
      fetchSeances();
    } else {
      print("Erreur de réservation");
    }
  }

  Future<void> supprimerDemande(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Supprimer"),
        content: Text("Confirmer la suppression ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Annuler")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Supprimer")),
        ],
      ),
    );

    if (confirm == true) {
      final response = await http.delete(Uri.parse("$apiBaseUrl/$id"));
      if (response.statusCode == 200 || response.statusCode == 204) {
        fetchSeances();
      } else {
        print("Erreur de suppression");
      }
    }
  }

  Widget buildSeanceCard(SeanceIndividuelle s, {bool isProposable = false, bool isEditable = false}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          "📅 ${DateFormat('dd/MM/yyyy HH:mm').format(s.date)}",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text("📍 Lieu : ${s.lieu}"),
            Text("🎯 Objectif : ${s.objectif}"),
            Text("📝 Statut : ${s.statut}"),
            // Affichage du nom du coach
            if (s.coach != null) Text("🏋️ Coach : ${s.coach!.username}"),
          ],
        ),
        trailing: isProposable && s.statut == "proposée"
            ? ElevatedButton(
                onPressed: () => reserverSeance(s),
                child: Text("Réserver"),
              )
            : isEditable
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditDemandePage(demande: s),
                            ),
                          ).then((_) => fetchSeances());
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => supprimerDemande(s.id!),
                      ),
                    ],
                  )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Séances Individuelles"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Séances proposées"),
              Tab(text: "Mes demandes"),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DemandeSeancePage()),
                );
                if (result == true) fetchSeances();
              },
            )
          ],
        ),
        body: TabBarView(
          children: [
            // Onglet 1 - séances proposées
            ListView.builder(
              itemCount: seancesProposees.length,
              itemBuilder: (context, index) =>
                  buildSeanceCard(seancesProposees[index], isProposable: true),
            ),
            // Onglet 2 - mes demandes
            ListView.builder(
              itemCount: demandesAdherent.length,
              itemBuilder: (context, index) =>
                  buildSeanceCard(demandesAdherent[index], isEditable: true),
            ),
          ],
        ),
      ),
    );
  }
}
