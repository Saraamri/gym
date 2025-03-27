import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _ageController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _specialiteController;

  late GlobalKey<FormState> _formKey;
  bool _isObscure = true;
  String _role = 'Adherent'; // Valeur par défaut : Adhérent

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _ageController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _specialiteController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specialiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white, // Fond blanc
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Formulaire d'inscription avec nom et prénom côte à côte
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        decoration: InputDecoration(
                          hintText: "Nom",
                          hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                          prefixIcon: Icon(Icons.person_outline, color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                          ),
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Nom requis"),
                          PatternValidator(r'^[a-zA-ZÀ-ÿ\s]+$', errorText: "Nom invalide (lettres uniquement)"),
                        ]),
                      ),
                    ),
                    SizedBox(width: 10), // Espace entre les champs Nom et Prénom
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        decoration: InputDecoration(
                          hintText: "Prénom",
                          hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                          prefixIcon: Icon(Icons.person_outline, color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                          ),
                        ),
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        validator: MultiValidator([
                          RequiredValidator(errorText: "Prénom requis"),
                          PatternValidator(r'^[a-zA-ZÀ-ÿ\s]+$', errorText: "Prénom invalide (lettres uniquement)"),
                        ]),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Champ Âge
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number, // Permet d'entrer des nombres
                  decoration: InputDecoration(
                    hintText: "Âge",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                    prefixIcon: Icon(Icons.cake_outlined, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Âge requis"),
                    PatternValidator(r'^[0-9]+$', errorText: "L'âge doit être un nombre entier"),
                    RangeValidator(min: 18, max: 100, errorText: "L'âge doit être compris entre 18 et 100 ans"),
                  ]),
                ),
                SizedBox(height: 20),

                // Champ Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Adresse email",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  validator: MultiValidator([
                    RequiredValidator(errorText: "Email requis"),
                    PatternValidator(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$', errorText: "Entrez un email valide (ex: exemple@mail.com)"),
                  ]),
                ),
                SizedBox(height: 20),

                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    hintText: "Mot de passe",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.black54),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(
                        _isObscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    ),
                  ),
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  validator: MultiValidator([
                    RequiredValidator(errorText: 'Mot de passe requis'),
                    MinLengthValidator(8, errorText: 'Minimum 8 caractères'),
                    MaxLengthValidator(15, errorText: 'Maximum 15 caractères'),
                  ]),
                ),
                SizedBox(height: 20),

                // Choix du rôle (Adhérent ou Coach)
                DropdownButtonFormField<String>(
                  value: _role,
                  onChanged: (String? newValue) {
                    setState(() {
                      _role = newValue!;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Adherent',
                      child: Text('Adhérent'),
                    ),
                    DropdownMenuItem(
                      value: 'Coach',
                      child: Text('Coach'),
                    ),
                  ],
                  decoration: InputDecoration(
                    hintText: "Choisissez votre rôle",
                    hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Si le rôle est "Coach", afficher le champ spécialité
                if (_role == 'Coach')
                  TextFormField(
                    controller: _specialiteController,
                    decoration: InputDecoration(
                      hintText: "Spécialité",
                      hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                      prefixIcon: Icon(Icons.star_outline, color: Colors.black54),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black.withOpacity(0.3)),
                      ),
                    ),
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    validator: RequiredValidator(errorText: "Spécialité requise"),
                  ),
                SizedBox(height: 30),

                // Bouton d'inscription
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Code d'inscription à ajouter ici (envoi vers le backend, etc.)
                        print("Inscription réussie");
                         Navigator.pushReplacementNamed(context, '/RoutesPage');
                      } else {
                        print("Échec de l'inscription");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 195, 195, 242), // Couleur bouton
                      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'S\'inscrire',
                      style: TextStyle(fontSize: 20),
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
}
