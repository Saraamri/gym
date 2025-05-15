import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/objectif.dart';
import '../AjoutObjectifPage.dart';
import '../EditObjectifPage.dart';

class ObjectifPage extends StatefulWidget {
  @override
  _ObjectifPageState createState() => _ObjectifPageState();
}

class _ObjectifPageState extends State<ObjectifPage> {
  List<Objectif> objectifs = [];
  String role = '';
  int userId = 0;
  String token = '';
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await loadUserData();
    await fetchObjectifs();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      final payload = JwtDecoder.decode(token);
      role = payload['role'] ?? '';
      userId = payload['id'];
      print('Utilisateur connecté - ID: $userId, Rôle: $role');
    }
  }

  Future<void> fetchObjectifs() async {
    final url = role == 'COACH'
        ? Uri.parse('http://localhost:8081/api/objectif/all')
        : Uri.parse('http://localhost:8081/api/objectif/$userId');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final List decoded = json.decode(utf8.decode(response.bodyBytes));
      final fetched = decoded.map((json) => Objectif.fromJson(json)).toList();

      setState(() {
        objectifs = [];
      });

      for (var i = 0; i < fetched.length; i++) {
        await Future.delayed(Duration(milliseconds: 100));
        setState(() {
          objectifs.add(fetched[i]);
          _listKey.currentState?.insertItem(objectifs.length - 1);
        });
      }
    } else {
      print('Erreur de chargement: ${response.statusCode}');
    }
  }

  Future<void> deleteObjectif(int index) async {
    final id = objectifs[index].id;
    final response = await http.delete(
      Uri.parse('http://localhost:8081/api/objectif/$id'),
    );

    if (response.statusCode == 200) {
      final removed = objectifs[index];
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => buildAnimatedCard(removed, animation),
        duration: Duration(milliseconds: 300),
      );
      setState(() {
        objectifs.removeAt(index);
      });
    } else {
      print('Erreur de suppression');
    }
  }

  void navigateToAjout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AjoutObjectifPage()),
    );
    objectifs.clear();
    fetchObjectifs();
  }

  void navigateToEdit(Objectif objectif) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditObjectifPage(objectif: objectif)),
    );
    objectifs.clear();
    fetchObjectifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mes Objectifs"),
      
      ),
          floatingActionButton: role == 'ADHERENT'
        ? FloatingActionButton(
            onPressed: navigateToAjout,
            backgroundColor: Colors.purpleAccent,
            child: Icon(Icons.add, size: 32, color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
             ),
          )
        : null,
    floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,   
      body: objectifs.isEmpty
          ? Center(child: Text("Aucun objectif trouvé."))
          : AnimatedList(
              key: _listKey,
              initialItemCount: objectifs.length,
              itemBuilder: (context, index, animation) {
                return buildAnimatedCard(objectifs[index], animation, index: index);
              },
            ),
    );
  }

  Widget buildAnimatedCard(Objectif obj, Animation<double> animation, {int? index}) {
    return SizeTransition(
      sizeFactor: animation,
      child: objectifCard(obj, index),
    );
  }

  Widget objectifCard(Objectif obj, int? index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flag, color: Colors.blueAccent),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    obj.type,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (role == 'ADHERENT')
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => navigateToEdit(obj),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          if (index != null) deleteObjectif(index);
                        },
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 12),
            infoRow(Icons.monitor_weight, 'Poids cible', '${obj.poidsCible} kg'),
            infoRow(Icons.height, 'Taille cible', '${obj.tailleCible} cm'),
            infoRow(Icons.fitness_center, 'IMC cible', '${obj.imcCible}'),
            infoRow(Icons.water_drop, 'Graisse corporelle', '${obj.bodyFatPercentageCible} %'),
            infoRow(Icons.accessibility_new, 'Masse musculaire', '${obj.muscleMassCible} kg'),
            infoRow(Icons.calendar_today, 'Fréquence / semaine', '${obj.frequency}'),
            infoRow(Icons.date_range, 'Date cible', '${obj.targetDate}'),
          ],
        ),
      ),
    );
  }

  Widget infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text("$label: ", style: TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
