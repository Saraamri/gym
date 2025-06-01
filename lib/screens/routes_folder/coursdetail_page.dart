import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoursDetailPage extends StatefulWidget {
  final dynamic item;

  const CoursDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _CoursDetailPageState createState() => _CoursDetailPageState();
}

class _CoursDetailPageState extends State<CoursDetailPage> {
  bool isLoading = false;
  bool showMore = false;
  String? role;
  int? userId;
  int? coursId;

  final String baseUrl = 'http://127.0.0.1:8081/api';
  final TextEditingController commentaireController = TextEditingController();

  List<dynamic> commentaires = [];
  bool hasLiked = false;
  int likeCount = 0;

  @override
  void initState() {
    super.initState();
    coursId = widget.item['id'];
    _loadUserFromToken();
  }

  Future<void> _loadUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      setState(() {
        role = payload['role'];
        userId = payload['id'];
      });
      await _loadCommentaires();
      if (role == 'ADHERENT') await _loadLikeStatus();
    }
  }

  Future<void> _loadLikeStatus() async {
    if (coursId == null || userId == null) return;

    final likeResponse = await http.get(Uri.parse('$baseUrl/like/exists/$coursId/$userId'));
    final countResponse = await http.get(Uri.parse('$baseUrl/like/count/$coursId'));

    if (likeResponse.statusCode == 200 && countResponse.statusCode == 200) {
      setState(() {
        hasLiked = json.decode(likeResponse.body) as bool;
        likeCount = json.decode(countResponse.body);
      });
    }
  }

  Future<void> _toggleLike() async {
    if (role != 'ADHERENT' || userId == null || coursId == null) return;

    final url = Uri.parse('$baseUrl/like/$coursId/$userId');
    final response = hasLiked ? await http.delete(url) : await http.post(url);

    if (response.statusCode == 200) {
      setState(() {
        hasLiked = !hasLiked;
        likeCount += hasLiked ? 1 : -1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de ${hasLiked ? 'la suppression' : "l'ajout"} du like')),
      );
    }
  }

  Future<void> _reserverCours() async {
    if (userId == null || coursId == null) return;

    setState(() => isLoading = true);

    final url = Uri.parse('$baseUrl/reservations/reservercours?adherentId=$userId&coursId=$coursId');
    final response = await http.post(url);
    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(response.statusCode == 200
            ? 'Réservation réussie'
            : 'Erreur lors de la réservation'),
      ),
    );
  }

  Future<void> _loadCommentaires() async {
    final response = await http.get(Uri.parse('$baseUrl/comments/cours/$coursId'));
    if (response.statusCode == 200) {
      setState(() {
        commentaires = json.decode(response.body).reversed.toList();
      });
    }
  }

  Future<void> _ajouterCommentaire() async {
    final contenu = commentaireController.text.trim();
    if (contenu.isEmpty) return;

    final response = await http.post(
      Uri.parse('$baseUrl/comments/cours/$coursId/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "body": contenu,
        "adherentId": userId,
        "coursCollectifId": coursId,
      }),
    );

    if (response.statusCode == 200) {
      commentaireController.clear();
      await _loadCommentaires();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de l'ajout du commentaire")),
      );
    }
  }

  Future<void> _supprimerCommentaire(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: const Text('Voulez-vous vraiment supprimer ce commentaire ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm != true) return;
    if (userId == null) return;

    final url = Uri.parse('$baseUrl/comments/delete/$commentId/user/$userId');
    final response = await http.delete(url);

    if (response.statusCode == 200) {
      await _loadCommentaires();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commentaire supprimé avec succès')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${response.body}')),
      );
    }
  }

  void _partagerCours() {
    final nom = widget.item['nom'] ?? 'Cours';
    final lien = 'https://votreapp.com/cours/$coursId';
    Share.share('Découvrez ce cours "$nom" sur notre app : $lien');
  }

  void _afficherCommentairesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: MediaQuery.of(ctx).viewInsets,
        child: DraggableScrollableSheet(
          expand: false,
          builder: (_, scrollController) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Commentaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: commentaires.isEmpty
                      ? const Center(child: Text('Aucun commentaire.'))
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: commentaires.length,
                          itemBuilder: (context, index) {
                            final c = commentaires[index];
                            final user = c['user'];
                            final fullName = '${user?['firstName'] ?? ''} ${user?['lastName'] ?? ''}';
                            final date = c['created']?.toString().split("T")[0] ?? '';
                            final profilePicUrl = user?['profilePicture'] != null
                                ? '$baseUrl${user?['profilePicture']}'
                                : null;

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: profilePicUrl != null
                                    ? NetworkImage(profilePicUrl)
                                    : const AssetImage('assets/default_avatar.png') as ImageProvider,
                              ),
                              title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c['body'] ?? ''),
                                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              trailing: (role == 'ADHERENT' &&
                                      user?['id'] != null &&
                                      userId != null &&
                                      user?['id'] == userId)
                                  ? IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _supprimerCommentaire(c['id']),
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
                if (role == 'ADHERENT') ...[
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentaireController,
                          decoration: const InputDecoration(hintText: 'Ajouter un commentaire...'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _ajouterCommentaire,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(title: Text(item['nom'] ?? 'Détail cours')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            item['image'] != null
                ? Image.network('$baseUrl${item['image']}', height: 200, fit: BoxFit.cover)
                : const Icon(Icons.image, size: 100),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (role == 'ADHERENT')
                  Column(
                    children: [
                      IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          hasLiked ? Icons.favorite : Icons.favorite_border,
                          color: hasLiked ? Colors.red : null,
                        ),
                      ),
                      Text('$likeCount'),
                    ],
                  ),
                IconButton(onPressed: _afficherCommentairesModal, icon: const Icon(Icons.comment_outlined)),
                IconButton(onPressed: _partagerCours, icon: const Icon(Icons.share_outlined)),
              ],
            ),

            const SizedBox(height: 8),
            Text(item['nom'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: const SizedBox(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Description : ${item['description'] ?? ''}'),
                  Text('Coach : ${item['coach']?['firstName'] ?? ''} ${item['coach']?['lastName'] ?? ''}'),
                  Text('Niveau : ${item['niveau'] ?? ''}'),
                  Text('Durée : ${item['dureeTotale'] ?? ''} min'),
                  Text('Jours : ${item['jours'] ?? ''}'),
                  Text('Horaire : ${item['horaire'] ?? ''}'),
                ],
              ),
              crossFadeState: showMore ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            ),

            TextButton(
              onPressed: () => setState(() => showMore = !showMore),
              child: Text(showMore ? 'Voir moins' : 'Voir plus'),
            ),

            if (role == 'ADHERENT')
              ElevatedButton(
                onPressed: isLoading ? null : _reserverCours,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Réserver'),
              ),
          ],
        ),
      ),
    );
  }
}
