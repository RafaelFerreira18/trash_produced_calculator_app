import 'package:calculadora_de_lixo/pages/socialPage.dart';
import 'package:calculadora_de_lixo/pages/tips.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'pages/homePage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Calculadora de lixo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 31, 85, 71)),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            backgroundColor:
                ColorSchemeCommom().themeData.colorScheme.inversePrimary,
            title: const Text("Calculadora de lixo"),
            centerTitle: true,
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
                    icon: Icon(CupertinoIcons.checkmark_shield_fill),
                    label: 'Dicas')
              ]),
        ));
  }
}

class ColorSchemeCommom {
  ThemeData themeData = ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 31, 85, 71)));
}
