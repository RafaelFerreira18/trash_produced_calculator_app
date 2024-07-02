import 'package:calculadora_de_lixo/pages/tips.dart';
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
  'Sacola 5L',
  'Sacola 10L',
  'Saco de lixo 50L'
];

int checkTypeOfTrash(String dropdownValue) {
  if (dropdownValue == "Sacola 10L") {
    return 10;
  } else if (dropdownValue == "Saco de lixo 50L") {
    return 50;
  } else if (dropdownValue == 'Sacola 5L') {
    return 5;
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

        DocumentSnapshot<Map<String, dynamic>> docSnapshot =
            await userDocRef.get() as DocumentSnapshot<Map<String, dynamic>>;

        Map<String, dynamic> newTrashData = {
          currentDate: double.parse(calculateTrash()),
        };

        if (docSnapshot.exists &&
            docSnapshot.data() != null &&
            docSnapshot.data()!.containsKey('trashData')) {
          newTrashData.addAll(docSnapshot.data()!['trashData']);
        }

        await userDocRef.set(
          {
            'trashData': newTrashData,
          },
          SetOptions(merge: true),
        );

        print(
            'Dados de lixo adicionados/atualizados com sucesso para $currentDate');

        // Calcula a pontuação e atualiza se for o caso
        double totalTrashGenerated =
            newTrashData.values.reduce((a, b) => a + b);
        await updateUserPoints(documentId, totalTrashGenerated);
      } else {
        print('Usuário com email ${user.email} não encontrado');
      }
    } catch (e) {
      print('Erro ao adicionar/atualizar dados de lixo: $e');
    }
  }

  Future<void> updateUserPoints(
      String userId, double totalTrashGenerated) async {
    const double averageTrash = 7.0;
    double points = 0;

    if (averageTrash - totalTrashGenerated <= 0) {
      points = 0;
    } else {
      points = averageTrash - totalTrashGenerated;
    }

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userRef);

      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;

      double currentPoints = userData?['points'] ?? 0.0;
      Timestamp? lastPointUpdateTimestamp = userData?['lastPointUpdate'];
      DateTime now = DateTime.now();

      // Verifica se o usuário já recebeu pontos na última semana
      if (lastPointUpdateTimestamp != null) {
        DateTime lastPointUpdate = lastPointUpdateTimestamp.toDate();
        if (now.difference(lastPointUpdate).inDays < 7) {
          print("User has already received points this week.");
          return;
        }
      }

      // Inicializa os campos se não existirem e atualiza pontos e lastPointUpdate
      transaction.set(
          userRef,
          {
            'points': currentPoints + points,
            'lastPointUpdate': now,
          },
          SetOptions(merge: true));
    });
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

  Widget checkAverage() {
    if (double.parse(calculateTrash()) < 7) {
      return const Text(
        'Você está abaixo da média, parabéns!',
        style: TextStyle(fontSize: 20),
      );
    } else if (double.parse(calculateTrash()) == 7) {
      return const Text(
        "Você está na média",
        style: TextStyle(fontSize: 20),
      );
    } else if (double.parse(calculateTrash()) > 7) {
      return Column(
        children: [
          const Text(
            'Você está acima da média, tome cuidado!',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 15),
          const Text(
            'Siga as dicas a seguir para conseguir diminuir a quantidade de lixo produzida',
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(
            height: 20,
          ),
          FilledButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TipsPage()),
              );
            },
            child: const Text('Dicas'),
          )
        ],
      );
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
          padding: const EdgeInsets.all(24.0),
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
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Você produziu aproximadamente ${calculateTrash()}kg de lixo',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                const Text(
                                  'A média de lixo produzida por brasileiro é de 7kg por semana',
                                  style: TextStyle(fontSize: 15),
                                ),
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
