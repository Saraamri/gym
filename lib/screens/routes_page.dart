import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:gymaccess/screens/routes_folder/Objectifs_page.dart';
import 'package:gymaccess/screens/routes_folder/cours_page.dart';
import 'package:gymaccess/screens/routes_folder/progress_page.dart';
import 'package:gymaccess/screens/routes_folder/reservations_page.dart';
import 'package:gymaccess/screens/routes_folder/abonnements_page.dart';
import 'package:gymaccess/screens/routes_folder/settings_page.dart';
import 'package:gymaccess/screens/routes_folder/adherent_seance_page.dart';
import 'package:gymaccess/screens/routes_folder/coach_seance_page.dart';

import 'routes_folder/calendar_page.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  late List<Widget> _screens;
  final List<String> _titles = ["Cours", "Séances","Rendez-vous", "Performances"];
  int _selectedIndex = 1;

  String _role = '';
  String _username = '';
  String _email = '';
  bool _isLoading = true;
  String? _profilePictureUrl;

  final String baseUrl = 'http://127.0.0.1:8081/api';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';

    if (token.isEmpty) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    
    Map<String, dynamic> payload = Jwt.parseJwt(token);

    String role = payload['role'] ?? '';
    int userId = payload['id'] ?? 0;

    if (role.isEmpty || userId == 0) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/LoginPage');
      }
      return;
    }

   
    try {
      final url = Uri.parse('$baseUrl/user/$userId');
      final response = await http.get(url, headers: {
       
      });

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          _role = role;
          _username = userData['username'] ?? '';
          _email = userData['email'] ?? '';

          String? profilePicPath = userData['profilePicture'];
          if (profilePicPath != null && profilePicPath.isNotEmpty) {
            _profilePictureUrl = '$baseUrl$profilePicPath';
          } else {
            _profilePictureUrl = null;
          }

          _screens = [
            const CoursPage(),
            role == 'COACH'
                ? const CoachSeancesPage()
                : AdherentSeancesPage(),
            CalendarPage(),
             ProgressPage(),
          ];

          _isLoading = false;
        });
      } else {
      
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/LoginPage');
        }
      }
    } catch (e) {
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/LoginPage');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: const TextStyle(fontSize: 24)),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blueGrey),
              child: UserAccountsDrawerHeader(

                accountName: Padding(
    padding: const EdgeInsets.only(left: 8.0), 
    child: Text(_username),
  ),
                accountEmail: Text(_email),
                currentAccountPicture: _profilePictureUrl != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(_profilePictureUrl!),
                      )
                    : const CircleAvatar(child: Icon(Icons.person)),
                decoration: const BoxDecoration(color: Colors.grey),
              ),
            ),
            if (_role == 'ADHERENT')
              ListTile(
                leading: const Icon(Icons.fitness_center),
                title: const Text("Abonnements"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AbonnementPage()),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text("Mes Réservations"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReservationsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.track_changes),
              title: const Text("Mes Objectifs"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ObjectifPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Paramètres"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Cours",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: "Séances",
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Rendez_vous",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Progress",
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
