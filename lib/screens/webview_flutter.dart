import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// Import requis uniquement pour le Web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class WebViewPage extends StatelessWidget {
  final String url;

  const WebViewPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Ouvre l'URL PayPal dans un nouvel onglet
      html.window.open(url, "_blank");

      // Affiche une page temporaire dans l'application
      return Scaffold(
        appBar: AppBar(title: const Text('Redirection')),
        body: const Center(
          child: Text(
            "Vous allez être redirigé vers la page de paiement PayPal...",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    } else {
      // Pour les autres plateformes, retour vide ou message d'erreur
      return const Scaffold(
        body: Center(child: Text("Cette page est disponible uniquement sur Flutter Web.")),
      );
    }
  }
}
