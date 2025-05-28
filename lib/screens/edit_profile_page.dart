import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gymaccess/screens/changepassword_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _specialiteController = TextEditingController();

  File? _pickedImage;
  XFile? _webImage;
  int? _userId;
  String? _role;
  String? _token;
  String? _profilePictureUrl;

  final String baseUrl = 'http://127.0.0.1:8081/api';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null && _token!.isNotEmpty) {
      final payload = JwtDecoder.decode(_token!);
      setState(() {
        _role = payload['role'] ?? '';
        _userId = payload['id'] ?? 0;
      });

      final url = Uri.parse('$baseUrl/user/$_userId');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $_token',
      });

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        setState(() {
          _lastNameController.text = userData['lastName'] ?? '';
          _firstNameController.text = userData['firstName'] ?? '';
          _telephoneController.text = userData['telephone'] ?? '';
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _specialiteController.text = (_role == 'COACH') ? (userData['specialite'] ?? '') : '';

          final pic = userData['profilePicture'];
          if (pic != null && pic is String && pic.isNotEmpty) {
            _profilePictureUrl = '$baseUrl$pic';
          } else {
            _profilePictureUrl = null;
          }
        });
      } else {
        print('Erreur chargement utilisateur : ${response.statusCode}');
      }
    } else {
      print('Token non trouvé');
    }
  }

  Future<void> _updateUser() async {
    if (_userId == null) return;

    final url = Uri.parse('$baseUrl/user/updateWithPicture/$_userId');
    final request = http.MultipartRequest('PUT', url);

    // Ajout du header Authorization
    if (_token != null) {
      request.headers['Authorization'] = 'Bearer $_token';
    }

    final userData = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'telephone': _telephoneController.text.trim(),
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
    };

    if (_role == 'COACH') {
      userData['specialite'] = _specialiteController.text.trim();
    }

    request.fields['user'] = jsonEncode(userData);

    if (kIsWeb && _webImage != null) {
      var bytes = await _webImage!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'profilePicture',
        bytes,
        filename: _webImage!.name,
      ));
    } else if (_pickedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profilePicture', _pickedImage!.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour avec succès !')));
      _loadUserData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la mise à jour du profil')));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          _webImage = pickedFile;
          _pickedImage = null;
        } else {
          _pickedImage = File(pickedFile.path);
          _webImage = null;
        }
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _telephoneController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object>? avatarImage;

       if (kIsWeb && _webImage != null) {
      avatarImage = NetworkImage(_webImage!.path);
    } else if (_pickedImage != null) {
      avatarImage = FileImage(_pickedImage!);
    } else if (_profilePictureUrl != null) {
      avatarImage = NetworkImage(_profilePictureUrl!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres du profil"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Enregistrer",
            onPressed: _updateUser,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[600])
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_lastNameController, "Nom"),
            _buildTextField(_firstNameController, "Prénom"),
            _buildTextField(_telephoneController, "Téléphone", keyboardType: TextInputType.phone),
            _buildTextField(_usernameController, "Nom d'utilisateur"),
            _buildTextField(_emailController, "Email", keyboardType: TextInputType.emailAddress),
            if (_role == 'COACH') _buildTextField(_specialiteController, "Spécialité"),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () async {
                  if (_userId != null) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangePasswordPage(userId: _userId!),
                      ),
                    );
                  }
                },
                child: const Text(
                  "Changer le mot de passe >",
                  style: TextStyle(
                    color: Color.fromARGB(255, 131, 163, 216),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
