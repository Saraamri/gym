import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordPage extends StatefulWidget {
  final String token;

  const ResetPasswordPage({super.key, required this.token});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isResetting = false;
  String? _message;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isResetting = true;
      _message = null;
    });

    final url = Uri.parse("http://127.0.0.1:8081/api/password/reset");
    final response = await http.post(
      url,
      body: {
        "token": widget.token,
        "newPassword": _passwordController.text,
      },
    );

    setState(() {
      _isResetting = false;
      _message = response.statusCode == 200
          ? "Mot de passe mis à jour avec succès."
          : "Erreur : ${response.body}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Réinitialiser le mot de passe")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text("Entrez votre nouveau mot de passe :", style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Nouveau mot de passe",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.length < 6 ? "Mot de passe trop court" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isResetting ? null : _resetPassword,
                child: _isResetting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Valider"),
              ),
              SizedBox(height: 20),
              if (_message != null)
                Text(
                  _message!,
                  style: TextStyle(color: _message!.startsWith("Erreur") ? Colors.red : Colors.green),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
