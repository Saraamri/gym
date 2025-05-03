import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AddCoursPage extends StatefulWidget {
  @override
  _AddCoursPageState createState() => _AddCoursPageState();
}

class _AddCoursPageState extends State<AddCoursPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _descController = TextEditingController();
  final _dureeController = TextEditingController();
  final _horaireController = TextEditingController();

  String? _selectedNiveau;
  List<String> _selectedJours = [];
  Uint8List? _imageBytes;
  String? _imageName;

  final List<String> _niveaux = ['Débutant', 'Intermédiaire', 'Avancé'];
  final List<String> _joursDisponibles = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  // Méthode pour choisir une image
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _imageBytes = result.files.single.bytes!;
        _imageName = result.files.single.name;
      });
    }
  }

  // Méthode pour soumettre le formulaire
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _imageBytes == null ||
        _selectedJours.isEmpty ||
        _selectedNiveau == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis')),
      );
      return;
    }

    try {
      final uri = Uri.parse('http://127.0.0.1:8081/api/coursCollectifs/add');
      var request = http.MultipartRequest('POST', uri);

      final coursJson = {
        "nom": _nomController.text,
        "description": _descController.text,
        "dureeTotale": int.parse(_dureeController.text),
        "niveau": _selectedNiveau,
        "jours": _selectedJours, // Envoi des jours comme liste
        "horaire": _horaireController.text,
      };

      // Ajoute la partie JSON comme MultipartFile
      request.files.add(http.MultipartFile.fromString(
        'cours',
        json.encode(coursJson),
        contentType: MediaType('application', 'json'),
      ));

      // Ajoute l'image
      final mimeType = lookupMimeType(_imageName!)?.split('/');
      if (mimeType != null && mimeType.length == 2) {
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          _imageBytes!,
          filename: _imageName!,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cours ajouté avec succès')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l’ajout du cours')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s’est produite : $e')),
      );
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descController.dispose();
    _dureeController.dispose();
    _horaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter un Cours')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom du cours'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Nom requis' : null,
            ),
            TextFormField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Description requise' : null,
            ),
            TextFormField(
              controller: _dureeController,
              decoration: InputDecoration(labelText: 'Durée (en minutes)'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final duree = int.tryParse(value ?? '');
                return (duree == null || duree <= 0)
                    ? 'Durée invalide'
                    : null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedNiveau,
              decoration: InputDecoration(labelText: 'Niveau'),
              items: _niveaux.map((niveau) {
                return DropdownMenuItem(value: niveau, child: Text(niveau));
              }).toList(),
              onChanged: (value) => setState(() => _selectedNiveau = value),
              validator: (value) => value == null ? 'Niveau requis' : null,
            ),
            MultiSelectDialogField(
              items: _joursDisponibles
                  .map((jour) => MultiSelectItem<String>(jour, jour))
                  .toList(),
              title: Text("Jours"),
              buttonText: Text("Sélectionner les jours"),
              onConfirm: (values) =>
                  _selectedJours = List<String>.from(values),
              validator: (values) => values == null || values.isEmpty
                  ? "Sélectionnez au moins un jour"
                  : null,
            ),
            TextFormField(
              controller: _horaireController,
              decoration:
                  InputDecoration(labelText: 'Horaire (ex: 18:00 - 19:00)'),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Horaire requis';
                final regex = RegExp(r'^\d{2}:\d{2} - \d{2}:\d{2}$');
                return regex.hasMatch(value)
                    ? null
                    : 'Format invalide (ex: 18:00 - 19:00)';
              },
            ),
            SizedBox(height: 10),
            _imageBytes == null
                ? Text('Aucune image sélectionnée')
                : Image.memory(_imageBytes!, height: 100),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: Icon(Icons.image),
              label: Text("Choisir une image"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text("Ajouter le cours"),
            ),
          ]),
        ),
      ),
    );
  }
}
