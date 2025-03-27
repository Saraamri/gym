import 'package:flutter/material.dart';
import 'package:gymaccess/screens/accueil_page.dart';
import 'package:gymaccess/screens/login_page.dart';
import 'package:gymaccess/screens/routes_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymAccess',
      home:    AccueilPage(),
      routes: {
        '/LoginPage': (context) => const LoginPage(),
        '/RoutesPage':(context) => const RoutesPage(),
         // Déclaration correcte de la route
      },
    );
  }
}
