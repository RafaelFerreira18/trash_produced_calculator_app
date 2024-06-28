import 'package:flutter/material.dart';

class TipsPage extends StatefulWidget {
  const TipsPage({Key? key}) : super(key: key);

  @override
  _TipsPageState createState() => _TipsPageState();
}

class _TipsPageState extends State<TipsPage> {
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    // Exemplo de posts iniciais aqui. Adicionar dicas.
    posts = [
      Post(title: 'Título do Post X', description: 'Descrição do Post X'),
      Post(title: 'Título do Post X', description: 'Descrição do Post X'),
    ];
  }

  void addPost(String? title, String? description) {
    if (title != null && description != null) {
      setState(() {
        posts.add(Post(title: title, description: description));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dicas'),
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
    String? title;
    String? description;

    title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Post'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Título'),
          onChanged: (value) {
            title = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Criar'),
            onPressed: () {
              if (title != null && title!.isNotEmpty) {
                Navigator.of(context).pop(title);
              }
            },
          ),
        ],
      ),
    );
    if (title == null) return;

    description = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descrição'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Descrição'),
          onChanged: (value) {
            description = value;
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Criar'),
            onPressed: () {
              if (description != null && description!.isNotEmpty) {
                Navigator.of(context).pop(description);
              }
            },
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
