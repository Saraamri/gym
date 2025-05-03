import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _specialiteController = TextEditingController();

  String _selectedRole = 'ADHERENT';
  Uint8List? _imageBytes;
  String? _imageName;

  final List<String> _roles = ['ADHERENT', 'COACH'];

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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs obligatoires.')),
      );
      return;
    }

    final uri = Uri.parse("http://127.0.0.1:8081/api/user/add");

    var request = http.MultipartRequest('POST', uri);

    final userJson = {
      "username": _usernameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "firstName": _firstNameController.text,
      "lastName": _lastNameController.text,
      "telephone": _telephoneController.text,
      "role": _selectedRole,
      "specialite": _selectedRole == "COACH" ? _specialiteController.text : null
    };

    userJson.removeWhere((key, value) => value == null || value == '');

    request.files.add(http.MultipartFile.fromString(
      'user',
      jsonEncode(userJson),
      contentType: MediaType('application', 'json'),
    ));

    final mimeType = lookupMimeType(_imageName!)?.split('/');
    if (mimeType != null && mimeType.length == 2) {
      request.files.add(http.MultipartFile.fromBytes(
        'profilePicture',
        _imageBytes!,
        filename: _imageName!,
        contentType: MediaType(mimeType[0], mimeType[1]),
      ));
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Inscription réussie !")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      final res = await response.stream.bytesToString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $res")),
      );
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telephoneController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 16),
                Center(
                  child: Text(
                    "Créer un compte",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 6, 14),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildValidatedTextField(
                        label: "Prénom",
                        controller: _firstNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Le prénom est requis.";
                          if (value.length > 10)
                            return "Max 10 caractères.";
                          return null;
                        },
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildValidatedTextField(
                        label: "Nom",
                        controller: _lastNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return "Le nom est requis.";
                          if (value.length > 15)
                            return "Max 15 caractères.";
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                _buildValidatedTextField(
                  label: "Téléphone",
                  controller: _telephoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Le téléphone est requis.";
                    if (!RegExp(r'^[0-9]{8}$').hasMatch(value))
                      return "8 chiffres requis.";
                    return null;
                  },
                ),
                _buildValidatedTextField(
                  label: "Nom d'utilisateur",
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Nom d'utilisateur requis.";
                    if (value.length < 5 || value.length > 15)
                      return "5-15 caractères.";
                    return null;
                  },
                ),
                _buildValidatedTextField(
                  label: "Email",
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Email requis.";
                    if (!RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$")
                        .hasMatch(value))
                      return "Email invalide.";
                    return null;
                  },
                ),
                _buildValidatedTextField(
                  label: "Mot de passe",
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return "Mot de passe requis.";
                    if (value.length < 8)
                      return "Min 8 caractères.";
                    if (!RegExp(r'(?=.*[0-9])(?=.*[A-Z])(?=.*[@#$%^&+=])(?=\S+$)')
                        .hasMatch(value))
                      return "Inclure chiffre, majuscule, spécial.";
                    return null;
                  },
                ),
                SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: InputDecoration(
                    labelText: "Rôle",
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                if (_selectedRole == "COACH")
                  _buildValidatedTextField(
                    label: "Spécialité",
                    controller: _specialiteController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Spécialité requise.";
                      return null;
                    },
                  ),
                SizedBox(height: 10),
                _imageBytes == null
                    ? Text("Aucune image sélectionnée")
                    : Image.memory(_imageBytes!, height: 100),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text("Choisir une image"),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text("S'inscrire"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 236, 191, 226),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValidatedTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        validator: validator,
      ),
    );
  }
}
