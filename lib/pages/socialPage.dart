import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});
  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
  }

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final QuerySnapshot snapshot = await _firestore.collection('users').get();
    final currentUser = _auth.currentUser;

    return snapshot.docs
        .where((doc) => doc.id != currentUser?.uid)
        .map((doc) => {
              'id': doc.id, // Include the document ID
              ...doc.data() as Map<String, dynamic>
            })
        .toList();
  }

  Future<void> _followUser(String userId) async {
    final followRef = _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('following')
        .doc(userId);

    final doc = await followRef.get();
    if (doc.exists) {
      await followRef.delete();
    } else {
      await followRef.set({'timestamp': FieldValue.serverTimestamp()});
    }
  }

  Future<bool> _isFollowing(String userId) async {
    final followRef = _firestore
        .collection('users')
        .doc(_currentUserId)
        .collection('following')
        .doc(userId);

    final doc = await followRef.get();
    return doc.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas para seguir'), // 
      ),
      body: FutureBuilder(
          future: _fetchUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            final users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final userId = user['id'];

              return Card( // Utilização de Card para envolver ListTile
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Ajustei as margens
                elevation: 3, // Altera a sombra do card
                child: ListTile(
                  title: Text(
                    user['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(user['email']),
                  trailing: FutureBuilder<bool>(
                    future: _isFollowing(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      }

                      final isFollowing = snapshot.data ?? false;

                      return IconButton(
                        icon: Icon(
                          isFollowing ? Icons.person_remove : Icons.person_add,
                          color: isFollowing ? Colors.red : Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            _followUser(userId);
                          });
                        },
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),               
    );
  }
}
