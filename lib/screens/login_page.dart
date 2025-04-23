import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:gymaccess/screens/routes_page.dart';
import 'inscription_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
          
           

            // Fond semi-transparent
            Container(
              color: Colors.black.withOpacity(0.5),
            ),

            // Contenu du formulaire
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 100), // Espacement en haut
                  SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Adresse email",
                              hintStyle: TextStyle(color: Colors.black54, fontSize: 18),
                              prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                            ),
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            validator: MultiValidator([
                              RequiredValidator(errorText: "Email requis"),
                              PatternValidator(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                errorText: "Entrez un email valide",
                              ),
                            ]),
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
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
                                  _isObscure ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                                  color: Colors.black54,
                                ),
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
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                print("Mot de passe oublié cliqué");
                              },
                              child: Text(
                                "Mot de passe oublié?",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          SizedBox(
                            width: 250,
                            child: CupertinoButton(
                              child: Text(
                                "Se Connecter",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              color: Color.fromARGB(255, 195, 195, 242),
                              borderRadius: BorderRadius.circular(15),
                            
                                onPressed: () {
                          // Redirection vers la page d'inscription
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>RoutesPage()),
                            );},
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Pas encore de compte?",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        child: Text(
                          'Inscrivez-vous',
                          style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                        ),
                        onPressed: () {
                          // Redirection vers la page d'inscription
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>InscriptionPage()),
                          );
                        },
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
