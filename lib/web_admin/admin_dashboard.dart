import 'package:flutter/material.dart';
import 'package:gymaccess/web_admin/admin_cours_page.dart';
import 'abonnement_list_page.dart';
 import 'user_list_page.dart'; 

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Administrateur'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text(
                'Bienvenue Administrateur',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Gestion des Abonnements'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AbonnementListPage()),
                );
              },
            ),
            ListTile(
              title: Text('Gestion des Utilisateurs'),
              onTap: () {
                 Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) => UserListPage()),
                 );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Page de gestion des utilisateurs à implémenter')),
                );
              },
            ),
            ListTile(
              title: Text('Gestion des Cours'),
              onTap: () {
                 Navigator.push(
                  context,
                 MaterialPageRoute(builder: (context) => AdminCoursPage()),
                 );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Page de gestion des cours à implémenter')),
                );
              },   
            ),
            ListTile(
              title: Text('Gestion des Paiements'),
              onTap: () {
                // Ajoutez ici une navigation vers la gestion des paiements si nécessaire
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Page de gestion des paiements à implémenter')),
                );
              },
            ),
            Divider(), // Séparateur pour bien séparer les sections
            ListTile(
              title: Text('Déconnexion'),
              onTap: () {
                // Logique de déconnexion ici
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Déconnexion à implémenter')),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Tableau de bord Administrateur'),
      ),
    );
  }
}
