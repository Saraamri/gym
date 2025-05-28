import 'package:flutter/material.dart';
import 'package:gymaccess/screens/accueil_page.dart';
import 'package:gymaccess/screens/routes_folder/adherent_seance_page.dart';
import 'package:gymaccess/screens/routes_folder/coach_seance_page.dart';
import 'package:gymaccess/screens/register_page.dart';
import 'package:gymaccess/screens/login_page.dart';
import 'package:gymaccess/screens/routes_page.dart';
import 'package:gymaccess/web_admin/admin_dashboard.dart';
import 'package:gymaccess/web_admin/admin_login.dart';
import 'package:gymaccess/web_admin/user_list_page.dart';

void main() {
  runApp(const MyApp()); 
}
class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymAccess',
      debugShowCheckedModeBanner: false,
      home:LoginPage(),
      routes: {
        '/LoginPage': (context) =>  LoginPage(),
        '/RoutesPage':(context) => const RoutesPage(),
     
      },
    );
  }
}
