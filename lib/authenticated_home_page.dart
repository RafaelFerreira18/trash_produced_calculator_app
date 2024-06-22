import 'package:calculadora_de_lixo/pages/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pages/homePage.dart';
import 'pages/socialPage.dart';
import 'pages/tips.dart';

class AuthenticatedHomePage extends StatefulWidget {
  const AuthenticatedHomePage({super.key});

  @override
  State<AuthenticatedHomePage> createState() => _AuthenticatedHomePageState();
}

class _AuthenticatedHomePageState extends State<AuthenticatedHomePage> {
  final _pageController = PageController();
  int _currentIndex = 0;
  final user = FirebaseAuth.instance.currentUser!;

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
                    // Implementar outras ações aqui se necessário
                  } else if (result == 1) {
                    _logout();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                      PopupMenuItem(child: Text("Bem vindo! ${user.email!}")),
                      const PopupMenuItem<int>(
                        value: 0,
                        child: Text('Outra Ação'),
                      ),
                      const PopupMenuItem<int>(
                        value: 1,
                        child: Text('Logout'),
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
          TipsPage()
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
