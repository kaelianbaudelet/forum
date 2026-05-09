import 'package:flutter/material.dart';
import '../api/message_api.dart';
import '../api/forum_api.dart';
import '../model/forum_model.dart';
import '../widgets/myscaffold.dart';

class WriteMessageScreen extends StatefulWidget {
  const WriteMessageScreen({super.key});

  @override
  State<WriteMessageScreen> createState() => _WriteMessageScreenState();
}

class _WriteMessageScreenState extends State<WriteMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  int? _selectedForumId;
  int? _parentId;
  String? _parentTitle;
  List<ForumModel>? _forums;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadForums();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Arguments handling: can be int (forumId) or Map (reply context)
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is int) {
      _selectedForumId = arg;
    } else if (arg is Map<String, dynamic>) {
      _selectedForumId = arg['forumId'];
      _parentId = arg['parentId'];
      _parentTitle = arg['parentTitle'];

      // Pre-fill title for replies if empty
      if (_titleController.text.isEmpty && _parentTitle != null) {
        _titleController.text = _parentTitle!.startsWith('Re: ') 
            ? _parentTitle! 
            : 'Re: $_parentTitle';
      }
    }
  }

  Future<void> _loadForums() async {
    try {
      final forums = await ForumApi().fetchAllForums();
      // On charge tous les forums pour s'assurer que même les sous-forums sont présents
      setState(() {
        _forums = forums;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des forums : $e')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedForumId == null) {
      if (_selectedForumId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez sélectionner un forum.')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      await MessageApi().postMessage(
        _titleController.text,
        _contentController.text,
        _selectedForumId!,
        parentId: _parentId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message publié avec succès !')),
        );
        Navigator.pop(context, true); // true to indicate success
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la publication : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      name: 'Nouveau Message',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_parentTitle != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.reply, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Réponse à : $_parentTitle',
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _parentId = null;
                            _parentTitle = null;
                          });
                        },
                      )
                    ],
                  ),
                ),
              // Forum Selection Dropdown (if not pre-selected or if user wants to change)
              DropdownButtonFormField<int>(
                value: _selectedForumId,
                hint: const Text('Choisir un forum'),
                items: _forums?.map((f) => DropdownMenuItem(
                  value: f.id,
                  child: Text(f.titre),
                )).toList(),
                onChanged: _parentId != null ? null : (val) { // Disable if replying
                  setState(() => _selectedForumId = val);
                },
                decoration: const InputDecoration(labelText: 'Forum'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Publier'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
