import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RequestResetPage extends StatefulWidget {
  @override
  _RequestResetPageState createState() => _RequestResetPageState();
}

class _RequestResetPageState extends State<RequestResetPage> {
  final TextEditingController _emailController = TextEditingController();
  String? _message;
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final url = Uri.parse("http://127.0.0.1:8081/api/password/request-reset"); // ⚠️ change URL si nécessaire
    final response = await http.post(
      url,
      body: {
        "email": _emailController.text.trim(),
      },
    );

    setState(() {
      _isLoading = false;
      _message = response.statusCode == 200
          ? "Un lien a été envoyé à votre adresse email."
          : "Erreur : ${response.body}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mot de passe oublié")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Entrez votre email pour recevoir un lien de réinitialisation."),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Envoyer"),
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
    );
  }
}
