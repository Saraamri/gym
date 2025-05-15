import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AjoutObjectifPage extends StatefulWidget {
  @override
  _AjoutObjectifPageState createState() => _AjoutObjectifPageState();
}

class _AjoutObjectifPageState extends State<AjoutObjectifPage> {
  final _formKey = GlobalKey<FormState>();
  final typeController = TextEditingController();
  final poidsController = TextEditingController();
  final tailleController = TextEditingController();
  final imcController = TextEditingController();
  final graisseController = TextEditingController();
  final muscleController = TextEditingController();
  final freqController = TextEditingController();
  final dateController = TextEditingController();
  

  String token = '';
  int userId = 0;

  Future<void> ajouterObjectif() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    
  if (token.isNotEmpty) {
      final payload = JwtDecoder.decode(token);
      userId = payload['id']; // Assure-toi que "id" est bien présent dans ton JWT
    }
  
    final response = await http.post(
      Uri.parse('http://localhost:8081/api/objectif/add/$userId'),
      headers: {
    
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'type': typeController.text,
        'poidsCible': double.tryParse(poidsController.text) ?? 0.0,
        'tailleCible': double.tryParse(tailleController.text) ?? 0.0,
        'imcCible': double.tryParse(imcController.text) ?? 0.0,
        'bodyFatPercentageCible': double.tryParse(graisseController.text) ?? 0.0,
        'muscleMassCible': double.tryParse(muscleController.text) ?? 0.0,
        'frequency': int.tryParse(freqController.text) ?? 1,
        'targetDate': dateController.text,
        'user': {
        'id': userId}
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
    } else {
      print('Erreur: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter Objectif")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: typeController, decoration: InputDecoration(labelText: 'Type')),
              TextFormField(controller: poidsController, decoration: InputDecoration(labelText: 'Poids Cible')),
              TextFormField(controller: tailleController, decoration: InputDecoration(labelText: 'Taille Cible')),
              TextFormField(controller: imcController, decoration: InputDecoration(labelText: 'IMC Cible')),
              TextFormField(controller: graisseController, decoration: InputDecoration(labelText: 'Graisse Cible')),
              TextFormField(controller: muscleController, decoration: InputDecoration(labelText: 'Masse Musculaire')),
              TextFormField(controller: freqController, decoration: InputDecoration(labelText: 'Fréquence par semaine')),
              TextFormField(controller: dateController, decoration: InputDecoration(labelText: 'Date cible (YYYY-MM-DD)')),
              SizedBox(height: 20),
              ElevatedButton(onPressed: ajouterObjectif, child: Text("Ajouter")),
            ],
          ),
        ),
      ),
    );
  }
}
