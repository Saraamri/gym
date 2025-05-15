import 'user.dart';

class SeanceIndividuelle {
  final int id;
  DateTime date;
  String statut;
  final String origine;
  final String lieu;
  final String objectif;
  final User? coach;
  final User? adherent;
  final bool proposeeParCoach;

  SeanceIndividuelle({
    required this.id,
    required this.date,
    required this.statut,
    required this.origine,
    required this.lieu,
    required this.objectif,
    this.adherent,
    this.coach,
    required this.proposeeParCoach,
  });

  // Getter pour obtenir le 'username' de l'adhérent
  String? get adherentUsername {
    return adherent?.username;
  }

  factory SeanceIndividuelle.fromJson(Map<String, dynamic> json) {
    return SeanceIndividuelle(
      id: json['id'],
      date: DateTime.parse(json['date']),
      statut: json['statut'],
      origine: json['origine'],
      lieu: json['lieu'],
      objectif: json['objectif'],
      adherent: json['adherent'] != null ? User.fromJson(json['adherent']) : null,
      coach: json['coach'] != null ? User.fromJson(json['coach']) : null,
      proposeeParCoach: json['proposeeParCoach'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('.').first,
      'statut': statut,
      'origine': origine,
      'lieu': lieu,
      'objectif': objectif,
      'adherent': adherent?.toJson(),
      'coach': coach?.toJson(),
      'proposeeParCoach': proposeeParCoach,
    };
  }
}
