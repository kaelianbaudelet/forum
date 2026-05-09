import 'message_model.dart';

class ForumModel {
  final int id;
  final String titre;
  final String? description;
  final List<ForumModel> children;
  final List<MessageModel> messages;
  final int? parentId;

  ForumModel({
    required this.id,
    required this.titre,
    this.description,
    this.children = const [],
    this.messages = const [],
    this.parentId,
  });

  factory ForumModel.fromJson(Map<String, dynamic> json) {
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

    return ForumModel(
      id: json['id'] ?? extractId(json['@id']) ?? 0,
      titre: json['titre'] ?? '',
      description: json['description'],
      parentId: extractId(json['parent']),
      children: (json['children'] as List? ?? [])
          .map((child) => ForumModel.fromJson(child as Map<String, dynamic>))
          .toList(),
      messages: (() {
        final rawMessages = json['messages'];
        List<dynamic> messageList = [];
        if (rawMessages is List) {
          messageList = rawMessages;
        } else if (rawMessages is Map) {
          messageList = rawMessages['hydra:member'] ?? rawMessages['member'] ?? [];
        }
        return messageList
            .where((msg) => msg is Map)
            .map((msg) => MessageModel.fromJson(Map<String, dynamic>.from(msg as Map)))
            .toList();
      })(),
    );
  }
}
