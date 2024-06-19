import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({super.key});

  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  List<Post> posts = [
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    Post(title: 'Título do Post X', description: 'Descrição do Post X'),
  ];

  void addPost(String title, String description) {
    setState(() {
      posts.add(Post(title: title, description: description));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed de Exemplo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addNewPost(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post.title),
            subtitle: Text(post.description),
          );
        },
      ),
    );
  }

  void _addNewPost(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Post'),
        content: const TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: 'Título'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Criar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    if (title == null) return;

    final description = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descrição'),
        content: const TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: 'Descrição'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Criar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
    if (description == null) return;

    addPost(title, description);
  }
}

class Post {
  String title;
  String description;

  Post({required this.title, required this.description});
}
