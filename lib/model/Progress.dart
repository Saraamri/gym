class Progress {
  final int id;
  final String date;
  final double poids;
  final double taille;
  final double imc;
   final double bodyFatPercentage;
  double? muscleMass;

  final int objectifId;

  Progress({
    required this.id,
    required this.date,
    required this.poids,
    required this.taille,
    required this.imc,
     required this.bodyFatPercentage,
    required this.muscleMass,
    required this.objectifId,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      date: json['date'],
      poids: json['poids'],
      taille: json['taille'],
      imc: json['imc'],
       bodyFatPercentage: json['bodyFatPercentage'],
      muscleMass: json['muscleMass'],
      objectifId: json['objectif'] != null ? json['objectif']['id'] : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'poids': poids,
      'taille': taille,
      'imc': imc,
      'bodyFatPercentage': bodyFatPercentage,
        'muscleMass': muscleMass,
      'objectif': {
        'id': objectifId,
      },
    };
  }
}
