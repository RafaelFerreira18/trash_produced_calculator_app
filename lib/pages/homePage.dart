import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TrashEntry {
  String trashType;
  int trashCount;

  TrashEntry(this.trashType, this.trashCount);
}

const List<String> trashTypeList = <String>[
  'Sacola de supermercado 10L',
  'Saco de lixo 50L'
];

int checkTypeOfTrash(String dropdownValue) {
  if (dropdownValue == "Sacola de supermercado 10L") {
    return 10;
  } else if (dropdownValue == "Saco de lixo 50L") {
    return 50;
  } else {
    return 0;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final calcController = TextEditingController(text: '0');
  final familyController = TextEditingController(text: '0');
  String dropdownValue = trashTypeList.first;

  List<TrashEntry> trashEntries = [];

  @override
  void dispose() {
    calcController.dispose();
    familyController.dispose();
    super.dispose();
  }

  void addTrashEntry() {
    final trashCount = int.tryParse(calcController.text) ?? 0;
    final trashEntry = TrashEntry(dropdownValue, trashCount);
    setState(() {
      trashEntries.add(trashEntry);
    });
  }

  String calculateTrash() {
    int counter = 0;
    for (int i = 0; i < trashEntries.length; i++) {
      counter += trashEntries[i].trashCount *
          checkTypeOfTrash(trashEntries[i].trashType);
    }
    counter = counter * int.parse(familyController.text);
    return counter.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Cálculo é feito por semana",
                style: TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: dropdownValue,
                    icon: const Icon(CupertinoIcons.arrow_down),
                    elevation: 20,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Tipo de sacola",
                    ),
                    style: const TextStyle(color: Colors.black54),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: trashTypeList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: calcController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Numero de sacolas utilizados na semana:",
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: familyController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Quantas pessoas vivem com você?",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      addTrashEntry();
                    },
                    tooltip: 'Adicionar entrada e mostrar lista',
                    child: const Icon(Icons.add),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: trashEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = trashEntries[index];
                                  return ListTile(
                                    title: Text(
                                      '${entry.trashType}: ${entry.trashCount}',
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    tooltip: 'Ver lista',
                    child: const Icon(Icons.list),
                  ),
                  FloatingActionButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                              'Você produziu aproximadamente ${calculateTrash()}L de lixo',
                            ),
                          );
                        },
                      );
                    },
                    tooltip: 'Mostrar o valor',
                    child: const Icon(Icons.calculate),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
