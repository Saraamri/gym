import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/stats.dart';

class StatsService {
  static Future<Stats> fetchStats() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8081/api/admin/stats'));

    if (response.statusCode == 200) {
      return Stats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur de chargement des statistiques');
    }
  }
}
