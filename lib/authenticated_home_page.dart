import 'package:calculadora_de_lixo/pages/chartPage.dart';
import 'package:calculadora_de_lixo/pages/leaderBoardPage.dart';
import 'package:calculadora_de_lixo/pages/loginPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pages/homePage.dart';
import 'pages/socialPage.dart';
import 'pages/tips.dart';
import 'pages/feed.dart';

class UserData {
  String email;
  String name;

  UserData({required this.email, required this.name});
}

Future<UserData> getData() async {
  UserData userData;
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var ds = querySnapshot.docs.first;
        userData = UserData(
          email: ds['email'],
          name: ds['name'],
        );
        return userData;
      } else {
        throw Exception("No user found with this email");
      }
    } else {
      throw Exception("No user is currently signed in");
    }
  } catch (e) {
    throw Exception("Failed to fetch user data: $e");
  }
}

class AuthenticatedHomePage extends StatefulWidget {
  const AuthenticatedHomePage({super.key});

  @override
  State<AuthenticatedHomePage> createState() => _AuthenticatedHomePageState();
}

class _AuthenticatedHomePageState extends State<AuthenticatedHomePage> {
  final _pageController = PageController();
  int _currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;
  UserData? _userData;

  Future<void> _loadUserData() async {
    try {
      UserData userData = await getData();
      setState(() {
        _userData = userData;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _logout() async {
    FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            ColorSchemeCommom().themeData.colorScheme.inversePrimary,
        title: const Text("Calculadora de lixo"),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: PopupMenuButton<int>(
                icon: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                onSelected: (int result) {
                  if (result == 0) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LineChartPage()),
                    );
                  } else if (result == 1) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeaderboardPage()),
                    );
                  } else if (result == 2) {
                    _logout();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                      PopupMenuItem(
                          child: Text(
                              "Bem vindo! ${_userData?.name.split(" ")[0]}")),
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Histórico'),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('Leaderboard'),
                      ),
                      const PopupMenuItem<int>(
                        value: 2,
                        child: Text('Sair'),
                      ),
                    ]),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: const <Widget>[
          MyHomePage(title: "Calculadora de lixo"),
          SocialPage(),
          FeedPage()
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.group_solid), label: 'Socials'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.checkmark_shield_fill), label: 'Dicas')
        ],
      ),
    );
  }
}

class ColorSchemeCommom {
  ThemeData themeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 31, 85, 71)));
}
