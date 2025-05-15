class Objectif {
  final int id;
  final String type;
  final double poidsCible;
  final double tailleCible;
  final double imcCible;
  final double bodyFatPercentageCible;
  final double muscleMassCible;
  final int frequency;
  final String targetDate;

  Objectif({
    required this.id,
    required this.type,
    required this.poidsCible,
    required this.tailleCible,
    required this.imcCible,
    required this.bodyFatPercentageCible,
    required this.muscleMassCible,
    required this.frequency,
    required this.targetDate,
  });

  factory Objectif.fromJson(Map<String, dynamic> json) {
    return Objectif(
      id: json['id'],
      type: json['type'],
      poidsCible: json['poidsCible'],
      tailleCible: json['tailleCible'],
      imcCible: json['imcCible'],
      bodyFatPercentageCible: json['bodyFatPercentageCible'],
      muscleMassCible: json['muscleMassCible'],
      frequency: json['frequency'],
      targetDate: json['targetDate'],
    );
  }

  Map<String, dynamic> toJson() => {
        "type": type,
        "poidsCible": poidsCible,
        "tailleCible": tailleCible,
        "imcCible": imcCible,
        "bodyFatPercentageCible": bodyFatPercentageCible,
        "muscleMassCible": muscleMassCible,
        "frequency": frequency,
        "targetDate": targetDate,
      };
}
