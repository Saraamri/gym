class Commentaire {
  final int commentId;
  final String body;
  final String? created;
  final bool active;
  final String? nomAuteur;
  final int? auteurId;

  Commentaire({
    required this.commentId,
    required this.body,
    this.created,
    required this.active,
    this.nomAuteur,
    this.auteurId,
  });

  factory Commentaire.fromJson(Map<String, dynamic> json) {
    return Commentaire(
      commentId: json['commentId'], 
      body: json['body'],           
      created: json['created'],     
      active: json['active'],      
      nomAuteur: json['user']?['firstName'], 
      auteurId: json['user']?['id'],   
    );
  }
}
