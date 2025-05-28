import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddProgressPage extends StatefulWidget {
  final int userId;

  const AddProgressPage({Key? key, required this.userId}) : super(key: key);

  @override
  _AddProgressPageState createState() => _AddProgressPageState();
}

class _AddProgressPageState extends State<AddProgressPage> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();

  double? poids, taille, imc, bodyFat, muscleMass;
  int? selectedObjectifId;
  DateTime selectedDate = DateTime.now();

  List<dynamic> objectifs = [];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    fetchObjectifs();
  }

  Future<void> fetchObjectifs() async {
    final response = await http.get(Uri.parse("http://localhost:8081/api/objectif/all"));
    if (response.statusCode == 200) {
      setState(() {
        objectifs = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors du chargement des objectifs")));
    }
  }

  Future<void> submitProgress() async {
    if (!_formKey.currentState!.validate() || selectedObjectifId == null) return;

    final progressData = {
      'date': _dateController.text,
      'poids': poids,
      'taille': taille,
      'imc': imc,
      'bodyFatPercentage': bodyFat,
      'muscleMass': muscleMass,
      'user': {'id': widget.userId},
    };

    final response = await http.post(
      Uri.parse("http://localhost:8081/api/progress/add/${widget.userId}/$selectedObjectifId"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(progressData),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Échec de l'ajout du progrès")));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un progrès')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(labelText: "Date"),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Poids (kg)"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null || double.parse(value) <= 0 ? "Entrer un poids valide" : null,
                onChanged: (value) => poids = double.tryParse(value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Taille (cm)"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null || double.parse(value) <= 0 ? "Entrer une taille valide" : null,
                onChanged: (value) => taille = double.tryParse(value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "IMC"),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || double.tryParse(value) == null || double.parse(value) <= 0 ? "Entrer un IMC valide" : null,
                onChanged: (value) => imc = double.tryParse(value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "% Graisse corporelle"),
                keyboardType: TextInputType.number,
                onChanged: (value) => bodyFat = double.tryParse(value),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Masse musculaire"),
                keyboardType: TextInputType.number,
                onChanged: (value) => muscleMass = double.tryParse(value),
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Objectif"),
                items: objectifs.map<DropdownMenuItem<int>>((obj) {
                  return DropdownMenuItem<int>(
                    value: obj['id'],
                    child: Text(obj['type']),
                  );
                }).toList(),
                onChanged: (value) => selectedObjectifId = value,
                validator: (value) => value == null ? "Sélectionner un objectif" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitProgress,
                child: Text("Ajouter"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
