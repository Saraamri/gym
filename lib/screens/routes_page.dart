import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymaccess/screens/routes_folder/Objectifs_page.dart';
import 'package:gymaccess/screens/routes_folder/cours_page.dart';
import 'package:gymaccess/screens/routes_folder/performance_page.dart';
import 'package:gymaccess/screens/routes_folder/reservations_page.dart';
import 'package:gymaccess/screens/routes_folder/profile_page.dart';
import 'package:gymaccess/screens/routes_folder/abonnements_page.dart';
import 'package:gymaccess/screens/routes_folder/settings_page.dart';
import 'package:gymaccess/screens/routes_folder/adherent_seance_page.dart';
import 'package:gymaccess/screens/routes_folder/coach_seance_page.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  late List<Widget> _screens;
  final List<String> _titles = ["Cours", "Séances", "Profil", "Performances"];
  int _selectedIndex = 2;

  String _role = '';
  String _username = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    String token = prefs.getString('token') ?? '';
    
    if (token.isEmpty) {
      // Redirection vers la page de login si pas de token
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    // Décodage du token JWT pour obtenir le rôle
   Map<String, dynamic> payload = Jwt.parseJwt(token); 

    String role = payload['role'] ?? '';

    String username = prefs.getString('username') ?? '';
    String email = prefs.getString('email') ?? '';
    String adherentId = prefs.getString('Id') ?? '';

    // Vérifie que l'ID de l'adhérent est valide
    int adherentIdInt = int.tryParse(adherentId) ?? 0;

    // Gère les erreurs si le rôle est inconnu
    if (role.isEmpty) {
      // Affiche un message d'erreur ou redirige vers la page de login si rôle invalide
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    setState(() {
      _role = role;
      _username = username;
      _email = email;

      // Charge les pages en fonction du rôle
      _screens = [
        const CoursPage(),
        role == 'COACH'
            ? const CoachSeancesPage() // Page spécifique au coach
            : AdherentSeancesPage(), // Page spécifique à l'adhérent
        ProfilePage(),
        const PerformancePage(),
      ];
      _isLoading = false;
    });
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
                accountName: Text(_username),
                accountEmail: Text(_email),
                currentAccountPicture: const CircleAvatar(), // Ajoute image ici si souhaité
                currentAccountPictureSize: const Size.square(50),
                decoration: const BoxDecoration(color: Colors.grey),
              ),
            ),
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
                  MaterialPageRoute(builder: (context) => const ReservationPage()),
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
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Déconnexion"),
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.clear(); // Déconnexion simple
                // Redirection vers la page de login
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Cours",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Séances",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Performances",
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
