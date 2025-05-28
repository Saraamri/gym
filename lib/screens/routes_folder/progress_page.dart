import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:intl/intl.dart';

import '../../model/Progress.dart';
import '../AddProgess_page.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<Progress> progresList = [];
  String role = '';
  int userId = 0;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await loadUserData();
    await fetchProgress();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    if (token.isNotEmpty) {
      final payload = JwtDecoder.decode(token);
      setState(() {
        role = payload['role'] ?? '';
        userId = payload['id'];
      });
    }
  }

  Future<void> fetchProgress() async {
    final url = role == 'ADHERENT'
        ? 'http://127.0.0.1:8081/api/progress/$userId'
        : 'http://127.0.0.1:8081/api/progress/all';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        List<dynamic> rawList = data is List ? data : (data['progressList'] ?? data['data'] ?? []);
        setState(() {
          progresList = rawList.map((e) => Progress.fromJson(e)).toList();
        });
      } else {
        print("Erreur HTTP: ${res.statusCode}");
      }
    } catch (e) {
      print("Erreur fetchProgress: $e");
    }
  }

  Future<void> confirmAndDeleteProgress(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Supprimer ?"),
        content: Text("Voulez-vous supprimer ce progrès ?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Annuler")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Supprimer")),
        ],
      ),
    );

    if (confirm == true) {
      final res = await http.delete(Uri.parse("http://127.0.0.1:8081/api/progress/$id"));
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Progrès supprimé")));
        fetchProgress();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur suppression")));
      }
    }
  }

  Widget buildMultiMetricChart(List<Progress> list) {
    final dateFormat = DateFormat('dd/MM');
    final dates = list.map((e) => DateTime.parse(e.date)).toList();

    List<FlSpot> poidsSpots = [];
    List<FlSpot> imcSpots = [];
    List<FlSpot> graisseSpots = [];
    List<FlSpot> muscleSpots = [];

    for (int i = 0; i < list.length; i++) {
      final p = list[i];
      poidsSpots.add(FlSpot(i.toDouble(), p.poids));
      imcSpots.add(FlSpot(i.toDouble(), p.imc));
      if (p.bodyFatPercentage != null) {
        graisseSpots.add(FlSpot(i.toDouble(), p.bodyFatPercentage!));
      }
      if (p.muscleMass != null) {
        muscleSpots.add(FlSpot(i.toDouble(), p.muscleMass!));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Évolution (Poids, IMC, Graisse, Muscle)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) => Text('${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 10)),
                    reservedSize: 40,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      int index = value.toInt();
                      if (index < 0 || index >= dates.length) return Container();
                      return Text(dateFormat.format(dates[index]), style: TextStyle(fontSize: 10));
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey)),
              lineBarsData: [
                LineChartBarData(spots: poidsSpots, isCurved: true, color: Colors.blue, barWidth: 2, dotData: FlDotData(show: true)),
                LineChartBarData(spots: imcSpots, isCurved: true, color: Colors.orange, barWidth: 2, dotData: FlDotData(show: true)),
                if (graisseSpots.isNotEmpty)
                  LineChartBarData(spots: graisseSpots, isCurved: true, color: Colors.red, barWidth: 2, dotData: FlDotData(show: true)),
                if (muscleSpots.isNotEmpty)
                  LineChartBarData(spots: muscleSpots, isCurved: true, color: Colors.green, barWidth: 2, dotData: FlDotData(show: true)),
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 10,
          children: [
            Chip(label: Text("Poids"), backgroundColor: Colors.blue[100]),
            Chip(label: Text("IMC"), backgroundColor: Colors.orange[100]),
            if (graisseSpots.isNotEmpty) Chip(label: Text("Graisse"), backgroundColor: Colors.red[100]),
            if (muscleSpots.isNotEmpty) Chip(label: Text("Muscle"), backgroundColor: Colors.green[100]),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget buildAnalysis(List<Progress> progressList) {
    if (progressList.isEmpty) return SizedBox();

    double poidsStart = progressList.first.poids;
    double poidsEnd = progressList.last.poids;
    double poidsMoyen = progressList.map((e) => e.poids).reduce((a, b) => a + b) / progressList.length;
    double imcMoyen = progressList.map((e) => e.imc).reduce((a, b) => a + b) / progressList.length;

    String progression = poidsEnd < poidsStart
        ? "Perte de poids 👍"
        : (poidsEnd > poidsStart ? "Prise de poids 💪" : "Stable ⚖️");

    return Card(
      color: Colors.grey[100],
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Analyse des progrès 📊", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("📉 Variation de poids : ${(poidsEnd - poidsStart).toStringAsFixed(1)} kg"),
            Text("⚖️ Poids moyen : ${poidsMoyen.toStringAsFixed(1)} kg"),
            Text("📐 IMC moyen : ${imcMoyen.toStringAsFixed(1)}"),
            SizedBox(height: 8),
            Chip(label: Text(progression), backgroundColor: Colors.lightBlue[100]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<int, List<Progress>> groupedByObjectif = {};
    for (var p in progresList) {
      if (!groupedByObjectif.containsKey(p.objectifId)) {
        groupedByObjectif[p.objectifId] = [];
      }
      groupedByObjectif[p.objectifId]!.add(p);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Suivi des progrès"),
        actions: [
          if (role == 'ADHERENT')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddProgressPage(userId: userId)),
                );
                if (result == true) {
                  fetchProgress();
                }
              },
            )
        ],
      ),
      body: progresList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: groupedByObjectif.entries.map((entry) {
                  final objectifId = entry.key;
                  final list = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Objectif ID: $objectifId", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      buildAnalysis(list),
                      buildMultiMetricChart(list),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final p = list[index];
                          return Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Icon(Icons.insights, color: Colors.blue),
                              title: Text("📅 ${p.date}"),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Poids : ${p.poids} kg"),
                                  Text("Taille : ${p.taille} m"),
                                  Text("IMC : ${p.imc.toStringAsFixed(1)}"),
                                  Text("Graisse : ${p.bodyFatPercentage ?? '-'} %"),
                                  Text("Muscle : ${p.muscleMass ?? '-'} %"),
                                  Text("Objectif ID : ${p.objectifId}"),
                                ],
                              ),
                              trailing: role == 'ADHERENT'
                                  ? IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => confirmAndDeleteProgress(p.id),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 30),
                    ],
                  );
                }).toList(),
              ),
            ),
    );
  }
}
