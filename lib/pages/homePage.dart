import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_de_lixo/notifications_config.dart';

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
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final calcController = TextEditingController(text: '0');
  final familyController = TextEditingController(text: '0');
  String dropdownValue = trashTypeList.first;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final user = FirebaseAuth.instance.currentUser!;
  final NotificationUtils _notificationUtils = NotificationUtils();

  List<TrashEntry> trashEntries = [];

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    await _notificationUtils.initializeNotifications(context);
    await _notificationUtils.startListeningNotificationEvents();
  }

  void scheduleNotification() {
    _notificationUtils.scheduleNotification();
  }

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

  Future<void> addTrashData() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;
        DocumentReference userDocRef =
            FirebaseFirestore.instance.collection('users').doc(documentId);

        DocumentSnapshot<Object?> docSnapshot = await userDocRef.get();
        DocumentSnapshot<Map<String, dynamic>> userData =
            docSnapshot as DocumentSnapshot<Map<String, dynamic>>;

        Map<String, dynamic> newTrashData = {
          currentDate: double.parse(calculateTrash()),
        };

        if (userData.exists &&
            userData.data() != null &&
            userData.data()!.containsKey('trashData')) {
          newTrashData.addAll(userData.data()!['trashData']);
        }

        await userDocRef.set(
          {
            'trashData': newTrashData,
          },
          SetOptions(merge: true),
        );

        print(
            'Dados de lixo adicionados/atualizados com sucesso para $currentDate');
      } else {
        print('Usuário com email ${user.email} não encontrado');
      }
    } catch (e) {
      print('Erro ao adicionar/atualizar dados de lixo: $e');
    }
  }

  String calculateTrash() {
    double counter = 0;
    for (int i = 0; i < trashEntries.length; i++) {
      counter += trashEntries[i].trashCount *
          checkTypeOfTrash(trashEntries[i].trashType);
    }
    counter = counter / int.parse(familyController.text);
    return counter.toString();
  }

  Text checkAverage() {
    if (double.parse(calculateTrash()) < 7) {
      return Text(
          'Você está abaixo da média, produziu ${(double.parse(calculateTrash())).toString()}kg por pessoa, parabéns!');
    } else if (double.parse(calculateTrash()) == 7) {
      return Text(
          'Você está na da média, produziu ${(double.parse(calculateTrash())).toString()}kg por pessoa');
    } else if (double.parse(calculateTrash()) > 7) {
      return Text(
          'Você está acima da média, produziu ${(double.parse(calculateTrash())).toString()}kg por pessoa');
    } else {
      return const Text("Algum erro foi encontrado");
    }
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
              const Text("Cálculo é feito por semana",
                  style: TextStyle(fontSize: 20), textAlign: TextAlign.center),
              const SizedBox(height: 40),
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
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AlertDialog(
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
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
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          if (trashEntries.isNotEmpty) {
                                            setState(() {
                                              trashEntries.removeLast();
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
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
                            content: Column(
                              children: [
                                Text(
                                  'Você produziu aproximadamente ${calculateTrash()}kg de lixo',
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                    'A média de lixo produzida por brasileiro é de 7kg por semana'),
                                const SizedBox(
                                  height: 20,
                                ),
                                checkAverage(),
                              ],
                            ),
                          );
                        },
                      );
                      addTrashData();
                      scheduleNotification();
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
