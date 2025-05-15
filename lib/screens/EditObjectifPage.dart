import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/objectif.dart';


class EditObjectifPage extends StatefulWidget {
  final Objectif objectif;

  EditObjectifPage({required this.objectif});

  @override
  _EditObjectifPageState createState() => _EditObjectifPageState();
}

class _EditObjectifPageState extends State<EditObjectifPage> {
  late TextEditingController typeController;
  late TextEditingController poidsController;
  late TextEditingController tailleController;
  late TextEditingController imcController;
  late TextEditingController graisseController;
  late TextEditingController muscleController;
  late TextEditingController freqController;
  late TextEditingController dateController;
  int userId = 0;

  @override
  void initState() {
    super.initState();
    typeController = TextEditingController(text: widget.objectif.type);
    poidsController = TextEditingController(text: widget.objectif.poidsCible.toString());
    tailleController = TextEditingController(text: widget.objectif.tailleCible.toString());
    imcController = TextEditingController(text: widget.objectif.imcCible.toString());
    graisseController = TextEditingController(text: widget.objectif.bodyFatPercentageCible.toString());
    muscleController = TextEditingController(text: widget.objectif.muscleMassCible.toString());
    freqController = TextEditingController(text: widget.objectif.frequency.toString());
    dateController = TextEditingController(text: widget.objectif.targetDate);
  }

  Future<void> updateObjectif() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('http://localhost:8081/api/objectif/update/${widget.objectif.id}'),
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

    if (response.statusCode == 200) {
      Navigator.pop(context);
    } else {
      print('Erreur update: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modifier Objectif")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            TextFormField(controller: typeController, decoration: InputDecoration(labelText: 'Type')),
            TextFormField(controller: poidsController, decoration: InputDecoration(labelText: 'Poids Cible')),
            TextFormField(controller: tailleController, decoration: InputDecoration(labelText: 'Taille Cible')),
            TextFormField(controller: imcController, decoration: InputDecoration(labelText: 'IMC Cible')),
            TextFormField(controller: graisseController, decoration: InputDecoration(labelText: 'Graisse Cible')),
            TextFormField(controller: muscleController, decoration: InputDecoration(labelText: 'Masse Musculaire')),
            TextFormField(controller: freqController, decoration: InputDecoration(labelText: 'Fréquence')),
            TextFormField(controller: dateController, decoration: InputDecoration(labelText: 'Date cible (YYYY-MM-DD)')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: updateObjectif, child: Text("Mettre à jour")),
          ],
        ),
      ),
    );
  }
}
