import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora de lixo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 31, 85, 71)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Calculadora de lixo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final calcController = TextEditingController();
  final familyController = TextEditingController();

  @override
  void dispose() {
    calcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(75.0),
            child: Column(
              children: [
                TextField(
                  controller: calcController,
                  decoration: const InputDecoration(
                      labelText: "Numero de sacolas utilizados:"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: familyController,
                  decoration: const InputDecoration(
                      labelText: "Quantas pessoas vivem com você?"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              content: Text((int.parse(calcController.text) *
                                      int.parse(familyController.text))
                                  .toString()));
                        });
                  },
                  tooltip: 'Show me the value',
                  child: const Icon(Icons.calculate),
                )
              ],
            ),
          ),
          BottomNavigationBar(items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.group_solid), label: 'Socials'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.delete), label: 'Apagar')
          ])
        ],
      ),
    );
  }
}
