import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoursDetailPage extends StatefulWidget {
  final dynamic item;

  const CoursDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _CoursDetailPageState createState() => _CoursDetailPageState();
}

class _CoursDetailPageState extends State<CoursDetailPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item['nom'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            item['image'] != null
                ? Image.network(
                    'http://127.0.0.1:8081/api${item['image']}',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(Icons.error, size: 50),
                      );
                    },
                  )
                : const Icon(Icons.image),
            const SizedBox(height: 16),
            Text(
              'Nom: ${item['nom']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Description: ${item['description']}'),
            const SizedBox(height: 8),
            Text('Durée: ${item['dureeTotale']} min'),
            const SizedBox(height: 8),
            Text('Niveau: ${item['niveau']}'),
            const SizedBox(height: 8),
            Text('Jour: ${item['jours']}'),
            const SizedBox(height: 8),
            Text('Horaire: ${item['horaire']}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() {
                        isLoading = true;
                      });

                      final url = 'http://127.0.0.1:8081/api/reservation'; // Remplacez par votre URL de réservation
                      final response = await http.post(
                        Uri.parse(url),
                        body: json.encode({
                          'coursId': item['id'], // ID du cours à réserver
                          'userId': 'userId', // ID de l'utilisateur qui réserve
                        }),
                        headers: {'Content-Type': 'application/json'},
                      );

                      setState(() {
                        isLoading = false;
                      });

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Réservation réussie')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Erreur de réservation')),
                        );
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Réserver'),
            ),
          ],
        ),
      ),
    );
  }
}
