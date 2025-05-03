import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditCoursPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const EditCoursPage({super.key, required this.item});

  @override
  State<EditCoursPage> createState() => _EditCoursPageState();
}

class _EditCoursPageState extends State<EditCoursPage> {
  late TextEditingController nomController;
  late TextEditingController descriptionController;
  late TextEditingController niveauController;
  late TextEditingController horaireController;
  late TextEditingController dureeController;

  File? _selectedImage;
  XFile? _webImage;
  final picker = ImagePicker();

  final List<String> allJours = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
  late List<String> selectedJours;

  final String baseUrl = kIsWeb
      ? 'http://127.0.0.1:8081/api'
      : 'http://192.168.199.18:8081/api';

  @override
  void initState() {
    super.initState();
    nomController = TextEditingController(text: widget.item['nom']);
    descriptionController = TextEditingController(text: widget.item['description']);
    niveauController = TextEditingController(text: widget.item['niveau']);
    horaireController = TextEditingController(text: widget.item['horaire']);
    dureeController = TextEditingController(text: widget.item['dureeTotale'].toString());
    selectedJours = List<String>.from(widget.item['jours'] ?? []);
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        setState(() {
          _webImage = picked;
        });
      } else {
        setState(() {
          _selectedImage = File(picked.path);
        });
      }
    }
  }

  Future<void> updateCours() async {
    final uri = Uri.parse('$baseUrl/coursCollectifs/updateWithImage/${widget.item['id']}');
    var request = http.MultipartRequest('PUT', uri);

    final coursData = {
      'nom': nomController.text,
      'description': descriptionController.text,
      'niveau': niveauController.text,
      'horaire': horaireController.text,
      'dureeTotale': int.tryParse(dureeController.text) ?? 0,
      'jours': selectedJours,
    };

    request.fields['cours'] = jsonEncode(coursData);

    if (kIsWeb && _webImage != null) {
      var bytes = await _webImage!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: _webImage!.name,
      ));
    } else if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cours modifié avec succès')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : ${response.statusCode}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePreview = kIsWeb
        ? (_webImage != null ? Image.network(_webImage!.path, height: 150) : null)
        : (_selectedImage != null ? Image.file(_selectedImage!, height: 150) : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le cours')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nomController, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
            TextField(controller: niveauController, decoration: const InputDecoration(labelText: 'Niveau')),
            TextField(controller: horaireController, decoration: const InputDecoration(labelText: 'Horaire')),
            TextField(
              controller: dureeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Durée (minutes)'),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Jours du cours :", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Column(
              children: allJours.map((jour) {
                return CheckboxListTile(
                  title: Text(jour),
                  value: selectedJours.contains(jour),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedJours.add(jour);
                      } else {
                        selectedJours.remove(jour);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            if (imagePreview != null) imagePreview,
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Changer l'image"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateCours,
              child: const Text("Enregistrer les modifications"),
            ),
          ],
        ),
      ),
    );
  }
}
