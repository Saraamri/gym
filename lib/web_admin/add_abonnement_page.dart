import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // pour formater les dates
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddAbonnementPage extends StatefulWidget {
  @override
  _AddAbonnementPageState createState() => _AddAbonnementPageState();
}

class _AddAbonnementPageState extends State<AddAbonnementPage> {
  final _formKey = GlobalKey<FormState>();
  String _type = '';
  double _prix = 0.0;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  String? _statut = 'ACTIF'; // Valeur par défaut
  final TextEditingController _prixController = TextEditingController();
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd');

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _dateDebut = picked;
        } else {
          _dateFin = picked;
        }
      });
    }
  }

  Future<void> _addAbonnement() async {
    final newAbonnement = {
      'type': _type,
      'prix': _prix,
      'dateDebut': _dateDebut!.toIso8601String(),
      'dateFin': _dateFin!.toIso8601String(),
      'statut': _statut,
    };

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8081/api/abonnements/add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newAbonnement),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abonnement ajouté avec succès')),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Erreur lors de l\'ajout de l\'abonnement');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion au serveur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Abonnement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Type
                TextFormField(
                  decoration: InputDecoration(labelText: 'Type d\'abonnement'),
                  validator: (value) => value!.isEmpty ? 'Le type d\'abonnement est requis' : null,
                  onSaved: (value) => _type = value!,
                ),
                // Prix
                TextFormField(
                  controller: _prixController,
                  decoration: InputDecoration(labelText: 'Prix (DT)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le prix doit être supérieur à 0';
                    }
                    final parsed = double.tryParse(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Le prix doit être supérieur à 0';
                    }
                    return null;
                  },
                  onSaved: (value) => _prix = double.parse(value!),
                ),
                SizedBox(height: 20),
                // Date Début
                ListTile(
                  title: Text(_dateDebut == null
                      ? 'Sélectionner la date de début'
                      : 'Date de début : ${_dateFormatter.format(_dateDebut!)}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, true),
                ),
                // Message d'erreur pour dateDebut
                if (_dateDebut != null && _dateDebut!.isBefore(DateTime.now().subtract(Duration(days: 1))))
                  Text(
                    'La date de début doit être aujourd\'hui ou dans le futur',
                    style: TextStyle(color: Colors.red),
                  ),

                // Date Fin
                ListTile(
                  title: Text(_dateFin == null
                      ? 'Sélectionner la date de fin'
                      : 'Date de fin : ${_dateFormatter.format(_dateFin!)}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context, false),
                ),
                // Message d'erreur pour dateFin
                if (_dateFin != null && _dateFin!.isBefore(DateTime.now()))
                  Text(
                    'La date de fin doit être dans le futur',
                    style: TextStyle(color: Colors.red),
                  ),

                // Statut
                DropdownButtonFormField<String>(
                  value: _statut,
                  items: ['ACTIF', 'EXPIRE', 'SUSPENDU'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Statut'),
                  validator: (value) => value == null ? 'Le statut est requis' : null,
                  onChanged: (value) {
                    setState(() {
                      _statut = value!;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _dateDebut != null &&
                        _dateFin != null &&
                        !_dateDebut!.isBefore(DateTime.now().subtract(Duration(days: 1))) &&
                        _dateFin!.isAfter(DateTime.now())) {
                      _formKey.currentState!.save();
                      _addAbonnement();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Veuillez remplir correctement toutes les informations')),
                      );
                    }
                  },
                  child: Text('Ajouter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
