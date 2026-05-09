class MessageModel {
  // Identifiant unique du message
  final int id;

  // Titre du message
  final String title;

  // Contenu du message
  final String content;

  // Date et heure de publication du message
  final DateTime postedAt;

  // Nom de l'auteur du message
  final String userLastName;

  // Prénom de l'auteur du message
  final String userFirstName;

  // Identifiant du message parent s'il s'agit d'une réponse (peut être null)
  final int? parentId;

  // Liste des réponses directes à ce message
  final List<MessageModel> replies;

  // Constructeur principal : permet de créer un objet MessageModel
  MessageModel({
    required this.id,
    required this.title,
    required this.content,
    required this.postedAt,
    required this.userLastName,
    required this.userFirstName,
    this.parentId,
    this.replies = const [],
  });

  // Méthode usine (factory) permettant de créer un MessageModel
  // à partir d'une structure JSON reçue depuis l'API
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Helper to extract ID from a potential IRI string or object
    int? extractId(dynamic value) {
      if (value == null) return null;
      if (value is Map && value.containsKey('@id')) {
        return int.tryParse(value['@id'].toString().split('/').last);
      }
      if (value is String) {
        return int.tryParse(value.split('/').last);
      }
      return null;
    }

    // Récupère l'objet "user" dans le JSON, ou un objet vide si absent
    final user = json['user'] ?? {};

    return MessageModel(
      // Récupère l'id du message, ou 0 si non fourni
      id: json['id'] ?? extractId(json['@id']) ?? 0,

      // Récupère le titre dans la clé API 'titre'
      title: json['titre'] ?? '',

      // Récupère le contenu dans la clé API 'contenu'
      content: json['contenu'] ?? '',

      // Convertit la chaîne 'datePoste' en objet DateTime
      postedAt: json['datePoste'] != null 
          ? DateTime.tryParse(json['datePoste'].toString()) ?? DateTime.now()
          : DateTime.now(),

      // Récupère le nom de l'auteur
      userLastName: user['nom'] ?? '',

      // Récupère le prénom de l'auteur
      userFirstName: user['prenom'] ?? '',

      // Si "parent" existe :
      // - on extrait son @id (ex : "/forum/api/messages/8") ou on traite comme IRI
      // - on récupère la dernière valeur : "8"
      // - et on le convertit en entier
      // Sinon, parentId = null
      parentId: extractId(json['parent']),

      // Récupération récursive des réponses si présentes dans le JSON
      replies: (json['replies'] as List? ?? [])
          .whereType<Map<String, dynamic>>() // On ne traite que les objets pleins, pas les IRIs
          .map((item) => MessageModel.fromJson(item))
          .toList(),
    );
  }
}
