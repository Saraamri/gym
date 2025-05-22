import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/authservice.dart';

import 'request_rest_page.dart';
import 'routes_page.dart';

import 'register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;
  bool _isObscure = true;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _usernameError = null;
        _passwordError = null;
      });

      print("Tentative de connexion...");
      try {
        final response = await _authService.login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
        print("Réponse reçue après connexion: $response");

        await saveUserData(
          response.token,
          response.username,
          response.email,
          response.role,
          response.expiresAt,
        );
        print("Données utilisateur enregistrées avec succès");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RoutesPage()),
        );
      } catch (e) {
        final errorMsg = e.toString().replaceAll('Exception:', '').trim();
        print("Erreur pendant la connexion: $errorMsg");

        setState(() {
          if (errorMsg.contains("Nom d'utilisateur")) {
            _usernameError = errorMsg;
          } else if (errorMsg.contains("Mot de passe")) {
            _passwordError = errorMsg;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorMsg)),
            );
          }
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> saveUserData(String token, String username, String email, String role, int? expiresAt) async {
    print("Enregistrement des données utilisateur...");
    final prefs = await SharedPreferences.getInstance();

    print("Stockage du token...");
    await prefs.setString('token', token);

    print("Stockage du nom d'utilisateur...");
    await prefs.setString('username', username);

    print("Stockage de l'email...");
    await prefs.setString('email', email);

    print("Stockage du rôle...");
    await prefs.setString('role', role);

    // Stockage de expiresAt avec un contrôle pour éviter les erreurs
    if (expiresAt != null) {
      print("Stockage de expiresAt: $expiresAt");
      await prefs.setInt('expiresAt', expiresAt);
    } else {
      print("expiresAt est null, stockage avec valeur par défaut 0");
      await prefs.setInt('expiresAt', 0);
    }

    print("Données utilisateur enregistrées avec succès");
  }

  InputDecoration _inputDecoration(String hintText, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.black54),
      prefixIcon: Icon(icon, color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.black54),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.black54),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blueAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.black.withOpacity(0.5)),
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 100),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: _inputDecoration("Nom d'utilisateur", Icons.person_outline)
                              .copyWith(errorText: _usernameError),
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          validator: RequiredValidator(errorText: "Nom d'utilisateur requis"),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _isObscure,
                          decoration: _inputDecoration("Mot de passe", Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _isObscure = !_isObscure),
                              icon: Icon(
                                _isObscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                                color: Colors.black54,
                              ),
                            ),
                            errorText: _passwordError,
                          ),
                          style: TextStyle(color: Colors.black, fontSize: 18),
                          validator: MultiValidator([ 
                            RequiredValidator(errorText: 'Mot de passe requis'),
                            MinLengthValidator(8, errorText: 'Minimum 8 caractères'),
                            MaxLengthValidator(15, errorText: 'Maximum 15 caractères'),
                          ]),
                        ),
                        SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RequestResetPage()),
                            ),
                            child: Text(
                              "Mot de passe oublié?",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        SizedBox(
                          width: 250,
                          child: CupertinoButton(
                            child: _isLoading
                                ? CupertinoActivityIndicator()
                                : Text("Se Connecter", style: TextStyle(fontWeight: FontWeight.bold)),
                            color: Color.fromARGB(255, 195, 195, 242),
                            borderRadius: BorderRadius.circular(15),
                            onPressed: _handleLogin,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    children: [
                      Text("Pas encore de compte?", style: TextStyle(color: Colors.white)),
                      TextButton(
                        child: Text('Inscrivez-vous', style: TextStyle(color: Colors.blueAccent)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
