import 'package:calculadora_de_lixo/authenticated_home_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AuthenticatedHomePage(),
              ),
            );
          },
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .orderBy('points', descending: true)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Text('No data available');
          }

          List<DocumentSnapshot> users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              return Container( 
                decoration: BoxDecoration(
                  color: Colors.grey[200], //adiciona cor de fundo. [] -> diminui tom da cor
                  borderRadius: BorderRadius.circular(10), //Adiciona uma borda arredondada
                ),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: ListTile(
                title: Text(user['email'], style: const TextStyle(fontWeight: FontWeight.bold),),
                subtitle: Text('Points: ${user['points']}'),
                leading: CircleAvatar(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold),)),
                ), //margem interna
              );
            },
          );
        },
      ),
    );
  }
}
