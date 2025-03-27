import 'package:flutter/material.dart';
import 'package:gymaccess/screens/routes_folder/Objectifs_page.dart';
import 'package:gymaccess/screens/routes_folder/cours_page.dart';
import 'package:gymaccess/screens/routes_folder/performance_page.dart';
import 'package:gymaccess/screens/routes_folder/reservations_page.dart';
import 'package:gymaccess/screens/routes_folder/profile_page.dart';
import 'package:gymaccess/screens/routes_folder/abonnements_page.dart';
import 'package:gymaccess/screens/routes_folder/settings_page.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  List<Widget> _screens = [
   
    CoursPage(),
    ReservationPage(),
    ProfilePage(),
    PerformancePage()
  ];

  List<String> _titles = [ "Cours", "Réservations", "Profil","Performances"];
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex], style: TextStyle(fontSize: 24)),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.7,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blueGrey,
              ),
              child: UserAccountsDrawerHeader(
                accountName: Text("Nom de l'utilisateur"),
                accountEmail: Text("email@example.com"),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/person.jpg"),
                ),
                currentAccountPictureSize: Size.square(50),
                decoration: BoxDecoration(color: Colors.grey),
              ),
            ),
            ListTile(
              leading: Icon(Icons.fitness_center),
              title: Text("Abonnements"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AbonnementPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text("Mes Réservations"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationPage()),
                );
              },
            ),
           ListTile(
             leading: Icon(Icons.track_changes),
  title: Text("Mes Objectifs"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ObjectifsPage()),
                );
              },
           ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Paramètres"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Déconnexion"),
              onTap: () {
                // Ajouter la logique de déconnexion ici
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
        items: [
          
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: "Cours",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Réservations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), // Icône de performance
            label: "Performances", // Label de performance
          ),
        ],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}
