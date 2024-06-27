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

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final QuerySnapshot snapshot = await _firestore.collection('users').get();
    final currentUser = _auth.currentUser;

    return snapshot.docs
        .where((doc) => doc.id != currentUser?.uid)
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                return ListTile(
                  title: Text(user['name'] ?? 'Desconhecido'),
                  subtitle: Text(user['email']),
                );
              },
            );
          }),
    );
  }
}
