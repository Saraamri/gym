import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProposerSeancePage extends StatefulWidget {
  @override
  _ProposerSeancePageState createState() => _ProposerSeancePageState();
}

class _ProposerSeancePageState extends State<ProposerSeancePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String _lieu = '';
  String _objectifSelectionne = '';
  int? _selectedAdherentId;

  bool _isSubmitting = false;
  List<Map<String, dynamic>> _adherents = [];
  List<String> _objectifs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(token.split(".")[1]))));
    final coachId = payload['id'];

    // Récupérer les adhérents
    final adherentResponse = await http.get(
      Uri.parse("http://localhost:8081/api/user/adherents?role=ADHERENT"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (adherentResponse.statusCode == 200) {
      final List decoded = json.decode(utf8.decode(adherentResponse.bodyBytes));
      setState(() {
        _adherents = decoded.map<Map<String, dynamic>>((user) => user).toList();
      });
    }

    // Récupérer les objectifs
    final objectifsResponse = await http.get(
      Uri.parse("http://localhost:8081/api/objectif/all"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (objectifsResponse.statusCode == 200) {
      final List decoded = json.decode(utf8.decode(objectifsResponse.bodyBytes));
      setState(() {
        _objectifs = decoded.map<String>((obj) => obj['type'].toString()).toList();
      });
    }
  }

  Future<void> _submitSeance() async {
    if (!_formKey.currentState!.validate() ||
        _selectedDate == null ||
        _selectedAdherentId == null ||
        _objectifSelectionne.isEmpty) {
      _showError("Veuillez remplir tous les champs.");
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final payload = json.decode(
          utf8.decode(base64Url.decode(base64Url.normalize(token!.split(".")[1]))));
      final coachId = payload['id'];

      final response = await http.post(
        Uri.parse("http://localhost:8081/api/seances/proposer"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "date": _selectedDate!.toIso8601String().split('.').first,
          "statut": "proposée",
          "origine": "coach",
          "lieu": _lieu,
          "objectif": _objectifSelectionne,
          "proposeeParCoach": true,
          "coach": {"id": coachId},
          "adherent": {"id": _selectedAdherentId}
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Séance proposée avec succès"), backgroundColor: Colors.green),
        );
      } else {
        _showError("Erreur lors de l'envoi. Code : ${response.statusCode}");
      }
    } catch (e) {
      _showError("Erreur réseau.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proposer une séance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? "Choisir une date"
                      : "Date : ${_selectedDate!.toLocal()}".split(' ')[0],
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              if (_selectedDate == null)
                Text("Veuillez choisir une date", style: TextStyle(color: Colors.red)),

              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: "Adhérent"),
                value: _selectedAdherentId,
                items: _adherents.map((user) {
                  return DropdownMenuItem<int>(
                    value: user['id'],
                    child: Text(user['username']),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedAdherentId = value),
                validator: (value) =>
                    value == null ? "Veuillez sélectionner un adhérent" : null,
              ),

              TextFormField(
                decoration: InputDecoration(labelText: "Lieu"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Veuillez saisir un lieu" : null,
                onSaved: (value) => _lieu = value!,
              ),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Objectif"),
                value: _objectifSelectionne.isNotEmpty ? _objectifSelectionne : null,
                items: _objectifs.map((obj) {
                  return DropdownMenuItem<String>(
                    value: obj,
                    child: Text(obj),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _objectifSelectionne = value!),
                validator: (value) =>
                    value == null || value.isEmpty ? "Veuillez choisir un objectif" : null,
              ),

              SizedBox(height: 20),
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitSeance,
                      child: Text("Proposer"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
