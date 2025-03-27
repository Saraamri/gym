import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Contrôleurs pour les champs de saisie
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController specialityController = TextEditingController();

  bool isEditing = false; // Mode édition activé/désactivé
  File? _imageFile; // Image de profil sélectionnée
  final ImagePicker _picker = ImagePicker(); // Outil de sélection d'image

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Êtes-vous sûr de vouloir supprimer votre profil ?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Annuler"),
            ),
            TextButton(
              onPressed: () {
                // TODO: Ajouter la logique de suppression du profil
                print("Profil supprimé !");
                Navigator.of(context).pop();
              },
              child: Text("Supprimer", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: SingleChildScrollView(  // 🔥 Ajout du défilement vertical
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 10),
            _buildImageSection(),
            SizedBox(height: 20),
            _buildTextField("Nom", lastNameController, isEditing),
            _buildTextField("Prénom", firstNameController, isEditing),
            _buildTextField("Nom d'utilisateur", usernameController, isEditing),
            _buildTextField("Email", emailController, isEditing, isEmail: true),
            _buildTextField("Mot de passe", passwordController, isEditing, isPassword: true),
            _buildTextField("Téléphone", phoneController, isEditing),
            _buildTextField("Spécialité", specialityController, isEditing),
            SizedBox(height: 20), // Ajout d'un espace en bas pour éviter que les boutons soient collés
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  // Section image de profil
  Widget _buildImageSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _imageFile != null ? FileImage(_imageFile!) : AssetImage("assets/images/person.jpg") as ImageProvider,
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text("Modifier l'image"),
        ),
        Text(_imageFile == null ? "No file chosen" : "Image sélectionnée"),
      ],
    );
  }

  // Champ de texte
  Widget _buildTextField(String label, TextEditingController controller, bool isEnabled, {bool isEmail = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        enabled: isEnabled,
        obscureText: isPassword,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  // Boutons Modifier & Supprimer
  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              isEditing = !isEditing;
            });
          },
          child: Text(isEditing ? "Enregistrer" : "Modifier Profil"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: _confirmDeleteProfile,
          child: Text("Supprimer Profil", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
