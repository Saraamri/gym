import 'package:flutter/material.dart';
import 'package:gymaccess/screens/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AbonnementPage extends StatefulWidget {
  const AbonnementPage({super.key});

  @override
  State<AbonnementPage> createState() => _AbonnementPageState();
}

class _AbonnementPageState extends State<AbonnementPage> {
  List<dynamic> abonnements = [];

  @override
  void initState() {
    super.initState();
    fetchAbonnements();
  }

  Future<void> fetchAbonnements() async {
    final response = await http.get(Uri.parse("http://127.0.0.1:8081/api/abonnements/getAll"));

    if (response.statusCode == 200) {
      setState(() {
        abonnements = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des abonnements")),
      );
    }
  }

  Future<void> processPayment(int abonnementId, double montant) async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8081/api/paypal/pay"),
      body: {
        "amount": montant.toString(),
        "abonnementId": abonnementId.toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      if (body.containsKey('approvalUrl') && body['approvalUrl'] != null) {
        String approvalUrl = body['approvalUrl'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(url: approvalUrl),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune URL d’approbation reçue de PayPal.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la création du paiement : ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choisissez un Abonnement")),
      body: abonnements.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: abonnements.length,
              itemBuilder: (context, index) {
                final abo = abonnements[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(abo['type']),
                    subtitle: Text("Durée : ${abo['dateDebut']} ➜ ${abo['dateFin']}\nStatut : ${abo['statut']}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("${abo['prix']} €"),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            processPayment(abo['id'], abo['prix']);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Payer"),
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
