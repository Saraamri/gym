import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gymaccess/services/stats_service.dart';
import 'package:gymaccess/web_admin/AvisListPage.dart';
import 'package:gymaccess/web_admin/admin_cours_page.dart';
import 'package:gymaccess/web_admin/admin_login.dart';
import 'package:gymaccess/web_admin/abonnement_list_page.dart';
import 'package:gymaccess/web_admin/user_list_page.dart';
import '../model/stats.dart';

class AdminDashboard extends StatefulWidget {
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Stats> futureStats;

  @override
  void initState() {
    super.initState();
    futureStats = StatsService.fetchStats();
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AdminLogin()),
      (Route<dynamic> route) => false,
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarChartData(Stats stats) {
    final items = [
      {'label': 'Adhérents', 'value': stats.adherents.toDouble()},
      {'label': 'Coachs', 'value': stats.coachs.toDouble()},
      {'label': 'Abonnés', 'value': stats.abonnes.toDouble()},
      {'label': 'Cours', 'value': stats.cours.toDouble()},
      {'label': 'Avis', 'value': stats.avis.toDouble()},
    ];

    return items.asMap().entries.map((entry) {
      int index = entry.key;
      double value = (entry.value['value'] as num).toDouble();
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(toY: value, color: Colors.blue, width: 22),
        ],
        showingTooltipIndicators: [0],
      );
    }).toList();
  }

  Widget _buildBarChart(Stats stats) {
    final labels = ['Adhérents', 'Coachs', 'Abonnés', 'Cours', 'Avis'];

    return BarChart(
      BarChartData(
        maxY: [
              stats.adherents,
              stats.coachs,
              stats.abonnes,
              stats.cours,
              stats.avis
            ].reduce((a, b) => a > b ? a : b).toDouble() +
            5,
        barGroups: _buildBarChartData(stats),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < labels.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(labels[index], style: const TextStyle(fontSize: 12)),
                  );
                } else {
                  return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 10,
              getTitlesWidget: (value, meta) {
                return Text(value.toInt().toString());
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(show: true),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
           getTooltipColor: (BarChartGroupData group) => Colors.blueAccent,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Administrateur'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Bienvenue Administrateur',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            ListTile(
              title: const Text('Gestion des Abonnements'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AbonnementListPage())),
            ),
            ListTile(
              title: const Text('Gestion des Utilisateurs'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UserListPage())),
            ),
            ListTile(
              title: const Text('Gestion des Cours'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminCoursPage())),
            ),
            ListTile(
              title: const Text('Gestion des Paiements'),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Page de gestion des paiements à implémenter')),
              ),
            ),
            ListTile(
              title: const Text('Gestion des Avis'),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AvisListPage())),
            ),
            const Divider(),
            ListTile(
              title: const Text('Déconnexion'),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: FutureBuilder<Stats>(
        future: futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          else if (snapshot.hasError)
            return Center(child: Text("Erreur : ${snapshot.error}"));
          else if (!snapshot.hasData)
            return const Center(child: Text("Aucune donnée disponible"));

          final stats = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard("Adhérents", '${stats.adherents}', Icons.person, Colors.blue),
                    _buildStatCard("Coachs", '${stats.coachs}', Icons.fitness_center, Colors.orange),
                    _buildStatCard("Abonnés", '${stats.abonnes}', Icons.subscriptions, Colors.green),
                    _buildStatCard("Cours", '${stats.cours}', Icons.class_, Colors.purple),
                    _buildStatCard("Avis", '${stats.avis}', Icons.reviews, Colors.teal),
                    _buildStatCard("Revenus", '${stats.revenus.toStringAsFixed(2)} Dt', Icons.attach_money, Colors.red),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 300,
                      child: _buildBarChart(stats),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
