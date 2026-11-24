/// Membre de famille tel que renvoyé par l'API (/famille-membres).
class FamilleMembre {
  final int? id;
  final String nom;
  final String postnom;
  final String prenom;
  final String lieuNaissance;
  final String dateNaissance; // AAAA-MM-JJ
  final String parente;
  final String? imageUrl;

  const FamilleMembre({
    this.id,
    required this.nom,
    required this.postnom,
    required this.prenom,
    required this.lieuNaissance,
    required this.dateNaissance,
    required this.parente,
    this.imageUrl,
  });

  String get nomComplet => '$prenom $nom $postnom';

  factory FamilleMembre.fromJson(Map<String, dynamic> json) {
    return FamilleMembre(
      id: int.tryParse(json['id'].toString()),
      nom: json['nom'] ?? '',
      postnom: json['postnom'] ?? '',
      prenom: json['prenom'] ?? '',
      lieuNaissance: json['lieu_naissance'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      parente: json['parente'] ?? '',
      imageUrl: json['image_url'],
    );
  }

  /// Champs envoyés à l'API (création et modification).
  Map<String, String> toJson() => {
        'nom': nom,
        'postnom': postnom,
        'prenom': prenom,
        'lieu_naissance': lieuNaissance,
        'date_naissance': dateNaissance,
        'parente': parente,
      };
}
