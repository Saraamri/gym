import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart' as f;
import 'package:gymaccess/services/authservice.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs correspondant aux attributs de UserEntity
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confPasswordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _adresseController = TextEditingController();
  final _profilePictureController = TextEditingController();
  final _specialiteController = TextEditingController();

  bool _isObscure = true;
  String _role = 'ADHERENT';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confPasswordController.dispose();
    _telephoneController.dispose();
    _ageController.dispose();
    _adresseController.dispose();
    _profilePictureController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    f.FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: Colors.black54) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
        ),
      ),
    );
  }
void _submitForm() async {
  if (_formKey.currentState!.validate()) {
    try {
      String message = await AuthService().register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        username: _usernameController.text,
        password: _passwordController.text,
        confPassword: _confPasswordController.text,
        specialite: _role == 'COACH' ? _specialiteController.text : null,
        telephone: _telephoneController.text,
        age: double.parse(_ageController.text),
        adresse: _adresseController.text,
        profilePicture: _profilePictureController.text,
        role:_role, 
 
      );

      print(message);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pushReplacementNamed(context, '/LoginPage');
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    }
  } else {
    print("Échec de l'inscription");
  }
}


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        hint: "Nom",
                        controller: _lastNameController,
                        icon: Icons.person_outline,
                        validator: f.RequiredValidator(errorText: "Nom requis"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildField(
                        hint: "Prénom",
                        controller: _firstNameController,
                        icon: Icons.person_outline,
                        validator: f.RequiredValidator(errorText: "Prénom requis"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Email",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: f.MultiValidator([
                    f.RequiredValidator(errorText: "Email requis"),
                    f.EmailValidator(errorText: "Email invalide"),
                  ]),
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Nom d'utilisateur",
                  controller: _usernameController,
                  icon: Icons.person,
                  validator: f.MultiValidator([
                    f.RequiredValidator(errorText: "Nom d'utilisateur requis"),
                    f.MinLengthValidator(5, errorText: "Minimum 5 caractères"),
                    f.MaxLengthValidator(15, errorText: "Maximum 15 caractères"),
                  ]),
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Mot de passe",
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  obscureText: _isObscure,
                  validator: f.MultiValidator([
                    f.RequiredValidator(errorText: "Mot de passe requis"),
                    f.MinLengthValidator(8, errorText: "Minimum 8 caractères"),
                  ]),
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Confirmer mot de passe",
                  controller: _confPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Confirmer le mot de passe";
                    } else if (val != _passwordController.text) {
                      return "Les mots de passe ne correspondent pas";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Téléphone (8 chiffres)",
                  controller: _telephoneController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: f.PatternValidator(r'^[0-9]{8}$', errorText: "Téléphone invalide"),
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Âge",
                  controller: _ageController,
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Âge requis";
                    }
                    final age = double.tryParse(value);
                    if (age == null || age < 18 || age > 120) {
                      return "Âge entre 18 et 120";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Adresse",
                  controller: _adresseController,
                  icon: Icons.home_outlined,
                ),
                const SizedBox(height: 15),

                _buildField(
                  hint: "Lien photo de profil (optionnel)",
                  controller: _profilePictureController,
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: 15),

                // Choix du rôle (affectera la spécialité si coach)
                DropdownButtonFormField<String>(
                  value: _role,
                  onChanged: (value) {
                    setState(() => _role = value!);
                  },
                  items: const [
                    DropdownMenuItem(value: 'ADHERENT', child: Text(" ADHERENT")),
                    DropdownMenuItem(value: 'COACH', child: Text("COACH")),
                  ],
                  decoration: InputDecoration(
                    hintText: "Choisissez votre rôle",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                if (_role == 'COACH')
                  _buildField(
                    hint: "Spécialité",
                    controller: _specialiteController,
                    icon: Icons.star_border,
                    validator: f.RequiredValidator(errorText: "Spécialité requise"),
                  ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFFC3C3F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("S'inscrire", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}