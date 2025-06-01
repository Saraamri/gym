class Stats {
  final int adherents;
  final int coachs;
  final int abonnes;
  final int cours;
  final int avis;
  final double revenus;

  Stats({
    required this.adherents,
    required this.abonnes,
    required this.coachs,
    required this.cours,
    required this.avis,
    required this.revenus,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      adherents: json['adherents'],
      abonnes: json['abonnes'],
      coachs: json['coachs'],
      cours: json['cours'],
      avis: json['avis'],
      revenus: json['revenus'].toDouble(),
    );
  }
}
