import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditAbonnementPage extends StatefulWidget {
  final int abonnementId;

  EditAbonnementPage({required this.abonnementId});

  @override
  _EditAbonnementPageState createState() => _EditAbonnementPageState();
}

class _EditAbonnementPageState extends State<EditAbonnementPage> {
  final _formKey = GlobalKey<FormState>();

  // ➔ Initialisation pour éviter LateInitializationError
  late String _type = '';
  late double _prix = 0.0;
  late DateTime _dateDebut = DateTime.now();
  late DateTime _dateFin = DateTime.now();
  late String _statut = 'ACTIF';

  bool _isLoading = false;
  bool _isFetching = true;

  @override
  void initState() {
    super.initState();
    _fetchAbonnement();
  }

  Future<void> _fetchAbonnement() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8081/api/abonnements/${widget.abonnementId}'),
      );

      if (response.statusCode == 200) {
        final abonnement = json.decode(response.body);
        setState(() {
          _type = abonnement['type'] ?? '';
          _prix = (abonnement['prix'] ?? 0).toDouble();
          _dateDebut = DateTime.parse(abonnement['dateDebut']);
          _dateFin = DateTime.parse(abonnement['dateFin']);
          _statut = abonnement['statut'] ?? 'ACTIF';
          _isFetching = false;
        });
      } else {
        throw Exception('Échec de la récupération des informations.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion : $e')),
      );
      setState(() {
        _isFetching = false;
      });
    }
  }

  Future<void> _updateAbonnement() async {
    setState(() {
      _isLoading = true;
    });

    final updatedAbonnement = {
      'type': _type,
      'prix': _prix,
      'dateDebut': _dateDebut.toIso8601String(),
      'dateFin': _dateFin.toIso8601String(),
      'statut': _statut,
    };

    try {
      final response = await http.put(
        Uri.parse('http://127.0.0.1:8081/api/abonnements/update/${widget.abonnementId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedAbonnement),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Abonnement mis à jour avec succès')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur serveur : ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur inattendue : $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Abonnement'),
      ),
      body: _isFetching
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _type,
                      decoration: InputDecoration(labelText: 'Type d\'abonnement'),
                      validator: (value) => value == null || value.isEmpty ? 'Type requis' : null,
                      onChanged: (value) => _type = value,
                    ),
                    TextFormField(
                      initialValue: _prix == 0.0 ? '' : _prix.toString(),
                      decoration: InputDecoration(labelText: 'Prix (DT)'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Prix requis';
                        final parsedValue = double.tryParse(value);
                        if (parsedValue == null || parsedValue <= 0) return 'Prix doit être supérieur à 0';
                        return null;
                      },
                      onChanged: (value) => _prix = double.tryParse(value) ?? 0.0,
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: _dateDebut.toLocal().toString().split(' ')[0]),
                      decoration: InputDecoration(labelText: 'Date de début'),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dateDebut,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateDebut = pickedDate;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(text: _dateFin.toLocal().toString().split(' ')[0]),
                      decoration: InputDecoration(labelText: 'Date de fin'),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: _dateFin,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dateFin = pickedDate;
                          });
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _statut,
                      decoration: InputDecoration(labelText: 'Statut'),
                      items: ['ACTIF', 'EXPIRE', 'SUSPENDU']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _statut = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _updateAbonnement();
                              }
                            },
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text('Sauvegarder'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
