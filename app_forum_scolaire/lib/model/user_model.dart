class UserModel {
  // Identifiant unique de l'utilisateur
  final int id;

  // Prénom de l'utilisateur
  final String firstName;

  // Nom de l'utilisateur
  final String lastName;

  // Adresse e-mail de l'utilisateur
  final String email;

  // Numéro de téléphone de l'utilisateur
  final String? phone;

  // Constructeur principal
  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
  });

  // Méthode usine (factory) permettant de créer un UserModel
  // à partir d'une structure JSON reçue depuis l'API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Récupère l'id de l'utilisateur, ou 0 si non fourni
      id: json['id'] ?? 0,

      // Récupère le prénom dans la clé API 'prenom'
      firstName: json['prenom'] ?? '',

      // Récupère le nom dans la clé API 'nom'
      lastName: json['nom'] ?? '',

      // Récupère l'email
      email: json['email'] ?? '',

      // Récupère le numéro de téléphone
      phone: json['phone'],
    );
  }
}
