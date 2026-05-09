import 'package:flutter/material.dart';
import '../api/forum_api.dart';
import '../api/message_api.dart';
import '../model/forum_model.dart';
import '../model/message_model.dart';
import '../widgets/myscaffold.dart';
import '../utils/error_translator.dart';

class ForumDetailScreen extends StatefulWidget {
  const ForumDetailScreen({super.key});

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  late Future<ForumModel> futureForum;
  Future<List<MessageModel>>? futureMessages;
  int? forumId;
  final Set<int> _expandedIds = {};
  final Map<int, List<MessageModel>> _loadedReplies = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    forumId = ModalRoute.of(context)!.settings.arguments as int;
    futureForum = ForumApi().fetchForumDetail(forumId!);
    futureMessages = MessageApi().fetchRootMessagesByForum(forumId!);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ForumModel>(
      future: futureForum,
      builder: (context, forumSnapshot) {
        if (forumSnapshot.connectionState == ConnectionState.waiting) {
          return const MyScaffold(
            name: 'Chargement...',
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (forumSnapshot.hasError) {
          return MyScaffold(
            name: 'Erreur',
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  ErrorTranslator.translate(forumSnapshot.error),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final forum = forumSnapshot.data!;

        return MyScaffold(
          name: forum.titre,
          forumId: forum.id,
          onPostSuccess: () {
            setState(() {
              futureMessages = MessageApi().fetchRootMessagesByForum(forum.id);
            });
          },
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (forum.description != null) ...[
                  Text(
                    forum.description!,
                    style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                  ),
                  const SizedBox(height: 20),
                ],

                // Section Sous-forums
                if (forum.children.isNotEmpty) ...[
                  const Text(
                    'Sous-forums',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...forum.children.map(
                    (child) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/forum-detail',
                            arguments: child.id,
                          );
                        },
                        icon: const Icon(Icons.forum_outlined),
                        label: Text(child.titre),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Section Messages
                const Text(
                  'Messages',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<MessageModel>>(
                  future: futureMessages,
                  builder: (context, msgSnapshot) {
                    if (msgSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (msgSnapshot.hasError) {
                      return Center(
                        child: Text(
                          ErrorTranslator.translate(msgSnapshot.error),
                        ),
                      );
                    }
                    final messages = msgSnapshot.data ?? [];
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('Aucun message dans ce forum.'),
                      );
                    }
                    return Column(
                      children: messages
                          .map((m) => _buildMessageItem(m, forum.id))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(MessageModel m, int forumId, {double indent = 0}) {
    final bool isExpanded = _expandedIds.contains(m.id);
    final List<MessageModel>? cachedReplies = _loadedReplies[m.id];

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: indent),
          child: _MessageCard(
            message: m,
            indent: indent,
            isExpanded: isExpanded,
            forumId: forumId,
            onToggleExpand: () async {
              if (isExpanded) {
                setState(() => _expandedIds.remove(m.id));
              } else {
                // If not loaded, fetch from API
                if (cachedReplies == null) {
                  setState(
                    () => _expandedIds.add(m.id),
                  ); // Show loading if we want, or just start fetch
                  try {
                    final replies = await MessageApi().fetchReplies(m.id);
                    setState(() {
                      _loadedReplies[m.id] = replies;
                    });
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ErrorTranslator.translate(e))),
                      );
                    }
                  }
                } else {
                  setState(() => _expandedIds.add(m.id));
                }
              }
            },
            onReplySuccess: () async {
              if (m.parentId == null) {
                // Si on a répondu à un message racine, on recharge la liste des racines
                setState(() {
                  futureMessages = MessageApi().fetchRootMessagesByForum(
                    forumId,
                  );
                });
              } else {
                // Si on a répondu à une réponse, on recharge la liste des réponses du parent de 'm'
                // pour que 'm' soit actualisé avec son nouveau compteur de réponses
                try {
                  final parentReplies = await MessageApi().fetchReplies(
                    m.parentId!,
                  );
                  setState(() {
                    _loadedReplies[m.parentId!] = parentReplies;
                  });
                } catch (e) {
                  // Fallback: refresh root if something fails
                  setState(() {
                    futureMessages = MessageApi().fetchRootMessagesByForum(
                      forumId,
                    );
                  });
                }
              }
            },
          ),
        ),
        if (isExpanded)
          cachedReplies == null
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : Column(
                  children: cachedReplies
                      .map(
                        (reply) => _buildMessageItem(
                          reply,
                          forumId,
                          indent: indent + 16,
                        ),
                      )
                      .toList(),
                ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  final MessageModel message;
  final double indent;
  final bool isExpanded;
  final int forumId;
  final VoidCallback onToggleExpand;
  final VoidCallback onReplySuccess;

  const _MessageCard({
    required this.message,
    required this.indent,
    required this.isExpanded,
    required this.forumId,
    required this.onToggleExpand,
    required this.onReplySuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: indent > 0 ? Colors.grey.withOpacity(0.05) : Colors.white,
        border: Border(
          left: indent > 0
              ? BorderSide(color: Colors.blue.shade300, width: 3)
              : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: indent > 0
            ? const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              )
            : BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (indent > 0)
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 14,
                        color: Colors.blue.shade300,
                      ),
                    if (indent > 0) const SizedBox(width: 5),
                    Text(
                      "${message.userFirstName} ${message.userLastName}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      " • ${message.postedAt.day}/${message.postedAt.month}/${message.postedAt.year}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message.title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: indent > 0 ? Colors.black87 : Colors.blue.shade900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.content,
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (message.replies.isNotEmpty)
                  InkWell(
                    onTap: onToggleExpand,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isExpanded
                                ? "Masquer les réponses"
                                : "Afficher les ${message.replies.length} réponses",
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                InkWell(
                  onTap: () async {
                    final success = await Navigator.pushNamed(
                      context,
                      '/write-message',
                      arguments: {
                        'forumId': forumId,
                        'parentId': message.id,
                        'parentTitle': message.title,
                      },
                    );
                    if (success == true) onReplySuccess();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.reply,
                          size: 16,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Répondre',
                          style: TextStyle(
                            color: Colors.blue.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
