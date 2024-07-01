import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  _FeedPageState createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Exemplo de posts iniciais aqui. Adicionar dicas.
    fetchFeed();
  }

  Future<void> fetchFeed() async {
    print('FETCH FEED');
    User? user = FirebaseAuth.instance.currentUser;
    print('USER $user');
    if (user != null) {
      print('BUSCANDO...');
      QuerySnapshot followerSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("following")
          .get();

      List<String> followingIds =
          followerSnapshot.docs.map((doc) => doc.id).toList();

      followingIds.add(user.uid);
      print('following ids $followingIds');
      if (followingIds.isNotEmpty) {
        QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
            .collection("posts")
            .where('userId', whereIn: followingIds)
            .get();

        final List<Map<String, dynamic>> postsList =
            await Future.wait(postsSnapshot.docs.map((post) async {
          final userId = post['userId'];
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
          final userName = userDoc['name'];
          return {
            'id': post.id,
            'userName': userName,
            ...post.data() as Map<String, dynamic>
          };
        }).toList());

        setState(() {
          posts = postsList;
          _loading = false;
        });
      }
    }
  }

  Future<void> addPost(String title, String content) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection("posts").add({
        'userId': user.uid,
        'title': title,
        'content': content,
        'timestamp': FieldValue.serverTimestamp()
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Post criado!")));
      fetchFeed();
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    var formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addNewPost(context);
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(child: Text('Sem postagens por enquanto'))
              : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    final String date = _formatTimestamp(post['timestamp']);

                    return ListTile(
                      title: Text(post['userName']),
                      subtitle: Text(post['content']),
                      trailing: Text(date),
                    );
                  },
                ),
    );
  }

  void _addNewPost(BuildContext context) async {
    String? title;
    String? content;

    await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Título'),
              onChanged: (value) {
                title = value;
              },
            ),
            TextField(
              autofocus: false,
              decoration: const InputDecoration(labelText: 'Mensagem'),
              onChanged: (value) {
                content = value;
              },
            )
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Criar'),
            onPressed: () {
              bool canCreate = title != null &&
                  title!.isNotEmpty &&
                  content != null &&
                  content!.isNotEmpty;
              if (canCreate) {
                addPost(title ?? "", content ?? "");
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class Post {
  String title;
  String description;

  Post({required this.title, required this.description});
}
