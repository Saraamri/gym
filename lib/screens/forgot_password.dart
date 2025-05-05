import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSending = false;
  bool _emailSent = false;

  Future<void> _sendResetRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
        _emailSent = false;
      });

      await Future.delayed(Duration(seconds: 2)); // Simule une requête

      // Ici tu peux appeler ton AuthService.resetPassword(_emailController.text)
      // ou envoyer une requête POST à ton backend

      setState(() {
        _isSending = false;
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mot de passe oublié"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                "Entrez votre adresse email pour recevoir un lien de réinitialisation.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return "Veuillez entrer un email";
                  if (!value.contains("@")) return "Email invalide";
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSending ? null : _sendResetRequest,
                child: _isSending
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Envoyer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
              ),
              SizedBox(height: 20),
              if (_emailSent)
                Text(
                  "Un email de réinitialisation a été envoyé.",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                )
            ],
          ),
        ),
      ),
    );
  }
}
