import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

const List<String> trashTypeList = <String>[
  'Sacola de supermercado',
  'Saco de lixo'
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final calcController = TextEditingController(text: '0');
  final familyController = TextEditingController(text: '0');

  @override
  void dispose() {
    calcController.dispose();
    familyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      border: OutlineInputBorder(),
                      labelText: "Numero de sacolas utilizados na semana:"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const DropdownButtonTypesOfTrash(),
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: familyController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Quantas pessoas vivem com você?"),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              content: Text(
                                  'Você produziu aproximadamente ${int.parse(calcController.text) * int.parse(familyController.text) * 10}L de lixo'));
                        });
                  },
                  tooltip: 'Mostrar o valor',
                  child: const Icon(Icons.calculate),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownButtonTypesOfTrash extends StatefulWidget {
  const DropdownButtonTypesOfTrash({super.key});

  @override
  State<DropdownButtonTypesOfTrash> createState() =>
      _DropdownButtonTypesOfTrashState();
}

class _DropdownButtonTypesOfTrashState
    extends State<DropdownButtonTypesOfTrash> {
  String dropdownValue = trashTypeList.first;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(CupertinoIcons.arrow_down),
      elevation: 16,
      style: const TextStyle(color: Colors.black54),
      underline: Container(
        height: 2,
        color: Colors.black,
      ),
      onChanged: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      items: trashTypeList.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}