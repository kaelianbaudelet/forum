class BadgeModel {
  // Identifiant unique de l'utilisateur
  final int id;

  // Prénom de l'utilisateur
  final String name;

  // Nom de l'utilisateur
  final String description;

  // Constructeur principal
  BadgeModel({required this.id, required this.name, required this.description});

  // Méthode usine (factory) permettant de créer un UserModel
  // à partir d'une structure JSON reçue depuis l'API
  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      // Récupère l'id de l'utilisateur, ou 0 si non fourni
      id: json['id'] ?? 0,

      // Récupère le prénom dans la clé API 'prenom'
      name: json['nom'] ?? '',

      // Récupère le numéro de téléphone
      description: json['description'],
    );
  }
}
