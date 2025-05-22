import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({Key? key}) : super(key: key);

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  List<dynamic> reservations = [];
  bool isLoading = true;
  String? role;
  int? userId;
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadAndDecodeToken();
  }

  Future<void> _loadAndDecodeToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token') ?? '';

    if (token.isEmpty || JwtDecoder.isExpired(token)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token invalide ou expiré")),
      );
      return;
    }

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        role = decodedToken['role'];
        userId = decodedToken['id'];
      });
      fetchReservations();
    } catch (e) {
      debugPrint('Erreur de décodage du token : $e');
    }
  }

  Future<void> fetchReservations() async {
    final String baseUrl = "http://127.0.0.1:8081/api/reservations";
    String url;

    if (role == "ADHERENT") {
      url = "$baseUrl/adherent/$userId";
    } else if (role == "COACH") {
      url = "$baseUrl/coach/$userId";
    } else {
      setState(() {
        isLoading = false;
        reservations = [];
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          reservations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erreur: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateReservationStatut(int id, String statut) async {
    final url =
        "http://127.0.0.1:8081/api/reservations/$id/$statut";
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Réservation $statut')),
        );
        fetchReservations();
      } else {
        throw Exception('Erreur : ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Erreur update statut: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la mise à jour.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(role == "COACH"
            ? "Réservations de mes cours"
            : "Mes Réservations"),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reservations.isEmpty
              ? const Center(child: Text("Aucune réservation trouvée."))
              : ListView.builder(
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    final cours = reservation['cours'];
                    final int reservationId = reservation['id'];

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        leading: const Icon(Icons.event_available),
                        title: Text(
                          cours != null && cours['nom'] != null
                              ? 'Nom: ${cours['nom']}'
                              : "Cours non disponible",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date : ${reservation['dateReservation']}"),
                            Text("Statut : ${reservation['statut']}"),
                            if (role == "COACH")
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      updateReservationStatut(
                                          reservationId, "confirmer");
                                    },
                                    icon: const Icon(Icons.check_circle,
                                        color: Colors.green),
                                    label: const Text("Confirmer"),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      updateReservationStatut(
                                          reservationId, "annuler");
                                    },
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.red),
                                    label: const Text("Annuler"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
