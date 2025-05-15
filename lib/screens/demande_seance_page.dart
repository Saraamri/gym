import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:intl/intl.dart'; // Pour formater la date
import '../model/user.dart';

class DemandeSeancePage extends StatefulWidget {
  const DemandeSeancePage({super.key});

  @override
  _DemandeSeancePageState createState() => _DemandeSeancePageState();
}

class _DemandeSeancePageState extends State<DemandeSeancePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _lieu = '';
  String _objectif = '';
  User? _selectedCoach;
  List<User> _coachList = [];
  bool _isSubmitting = false;
  int? adherentId;

  final String apiCoachUrl = "http://localhost:8081/api/user/coachs?role=COACH";

  @override
  void initState() {
    super.initState();
    _loadCoachs();
    _loadAdherentId();
  }

  Future<void> _loadAdherentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      setState(() {
        adherentId = payload['id'];
      });
    }
  }

  Future<void> _loadCoachs() async {
    final response = await http.get(Uri.parse(apiCoachUrl));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _coachList = data.map((coach) => User.fromJson(coach)).toList();
      });
    } else {
      _showError("Erreur lors du chargement des coachs");
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitDemande() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedCoach == null) {
      _showError("Veuillez sélectionner un coach.");
      return;
    }

    if (adherentId == null) {
      _showError("Erreur : ID adhérent introuvable.");
      return;
    }

    setState(() => _isSubmitting = true);

    final DateTime dateTimeWithHour = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final seance = {
       'date': dateTimeWithHour.toIso8601String().split('.')[0],
      'statut': 'demande',
      'origine': 'adhérent',
      'lieu': _lieu,
      'objectif': _objectif,
      'proposeeParCoach': false,
      'coach': {'id': _selectedCoach!.id},
      'adherent': {'id': adherentId}
    };

    try {
      final response = await http.post(
        Uri.parse("http://localhost:8081/api/seances/demande"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(seance),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Demande envoyée avec succès"), backgroundColor: Colors.green),
        );
      } else {
        _showError("Erreur lors de l'envoi de la demande.");
      }
    } catch (e) {
      _showError("Erreur réseau. Veuillez vérifier votre connexion.");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Demander une séance")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    ListTile(
                      title: Text('Date : ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: _selectDate,
                    ),
                    ListTile(
                      title: Text('Heure : ${_selectedTime.format(context)}'),
                      trailing: Icon(Icons.access_time),
                      onTap: _selectTime,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Lieu"),
                      validator: (value) => value!.isEmpty ? "Veuillez saisir un lieu" : null,
                      onSaved: (value) => _lieu = value!,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "Objectif"),
                      validator: (value) => value!.isEmpty ? "Veuillez saisir un objectif" : null,
                      onSaved: (value) => _objectif = value!,
                    ),
                    SizedBox(height: 16),
                    _coachList.isEmpty
                        ? Text("Aucun coach disponible", style: TextStyle(color: Colors.red))
                        : DropdownButtonFormField<User>(
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
                            validator: (value) => value == null ? "Coach requis" : null,
                          ),
                    SizedBox(height: 20),
                    _isSubmitting
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submitDemande,
                            child: Text("Envoyer la demande"),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
