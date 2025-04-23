import 'package:flutter/material.dart';
import 'package:gymaccess/web_admin/admin_dashboard.dart';


class AdminLogin extends StatefulWidget {
  
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _LoginPageState();
}

class _LoginPageState extends State<AdminLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  String _errorMessage = "";

  void _login() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text;
      String password = _passwordController.text;

      // Simuler une vérification des identifiants (remplacer avec une API plus tard)
      if (email == "admin@gmail.com" && password == "admin123") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  AdminDashboard()),
        );
      } else {
        setState(() {
          _errorMessage = "Identifiants incorrects. Veuillez réessayer.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 5,
            color: Colors.blueGrey[800],
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Titre
                    Text(
                      "Connexion Administrateur",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),

                    // Champ Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blueGrey[700],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: "Email",
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.email, color: Colors.white),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un email";
                        } else if (!value.contains("@")) {
                          return "Email invalide";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),

                    // Champ Mot de passe
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.blueGrey[700],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        labelText: "Mot de passe",
                        labelStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.lock, color: Colors.white),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un mot de passe";
                        } else if (value.length < 6) {
                          return "Mot de passe trop court";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),

                    // Message d'erreur
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 20),

                    // Bouton de connexion
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.teal[400],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Mot de passe oublié
                    TextButton(
                      onPressed: () {
                        print("Mot de passe oublié");
                      },
                      child: const Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}