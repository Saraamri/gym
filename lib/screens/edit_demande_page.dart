import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gymaccess/model/SeanceIndividuelle.dart';
import 'package:gymaccess/model/user.dart';
import 'package:http/http.dart' as http;

class EditDemandePage extends StatefulWidget {
  final SeanceIndividuelle demande;

  const EditDemandePage({required this.demande});

  @override
  _EditDemandePageState createState() => _EditDemandePageState();
}

class _EditDemandePageState extends State<EditDemandePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lieuController;
  late TextEditingController _objectifController;
  DateTime? _selectedDate;
  User? _selectedCoach;
  List<User> _coachList = [];

  final String apiBaseUrl = "http://localhost:8081/api/seances";
  final String apiCoachUrl = "http://localhost:8081/api/user/coachs?role=COACH";

  @override
  void initState() {
    super.initState();
    _lieuController = TextEditingController(text: widget.demande.lieu);
    _objectifController = TextEditingController(text: widget.demande.objectif);
    _selectedDate = widget.demande.date;
    _selectedCoach = widget.demande.coach as User?;
    _loadCoachs();
  }

  @override
  void dispose() {
    _lieuController.dispose();
    _objectifController.dispose();
    super.dispose();
  }

  Future<void> _loadCoachs() async {
    final response = await http.get(Uri.parse(apiCoachUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _coachList = data.map((coach) => User.fromJson(coach)).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des coachs")),
      );
    }
  }

  Future<void> _updateDemande() async {
    if (_formKey.currentState!.validate()) {
      final updatedDemande = SeanceIndividuelle(
        id: widget.demande.id,
        date: _selectedDate!,
        lieu: _lieuController.text,
        objectif: _objectifController.text,
        proposeeParCoach: false,
        statut: widget.demande.statut,
        adherent: widget.demande.adherent,
        coach: _selectedCoach,
        origine: "modifiée",
      );

      final response = await http.put(
        Uri.parse("$apiBaseUrl/${widget.demande.id}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(updatedDemande.toJson()),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la mise à jour")),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Modifier la demande"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _lieuController,
                decoration: InputDecoration(labelText: "Lieu"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Lieu requis" : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _objectifController,
                decoration: InputDecoration(labelText: "Objectif"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Objectif requis" : null,
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? "Choisir une date"
                      : "Date sélectionnée : ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<User>(
                value: _selectedCoach,
                onChanged: (User? newCoach) {
                  setState(() {
                    _selectedCoach = newCoach;
                  });
                },
                items: _coachList.map((User coach) {
                  return DropdownMenuItem<User>(
                    value: coach,
                    child: Text(coach.username),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: "Choisir un coach"),
                validator: (value) =>
                    value == null ? "Coach requis" : null,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _updateDemande,
                child: Text("Mettre à jour"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
