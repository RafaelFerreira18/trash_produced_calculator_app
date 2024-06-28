import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:calculadora_de_lixo/authenticated_home_page.dart';

class LineChartPage extends StatefulWidget {
  @override
  _LineChartPageState createState() => _LineChartPageState();
}

class _LineChartPageState extends State<LineChartPage> {
  List<FlSpot> spots = [];
  List<DateTime> dates = [];
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      loadDataForChart();
    } else {
      print('Usuário não autenticado');
    }
  }

  Future<void> loadDataForChart() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user!.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String documentId = querySnapshot.docs.first.id;
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(documentId)
                .get();

        if (userData.exists && userData.data()!.containsKey('trashData')) {
          Map<String, dynamic> trashData = userData['trashData'];

          List<FlSpot> dataSpots = [];
          trashData.forEach((date, amount) {
            DateTime dateTime = DateTime.parse(date);
            dates.add(dateTime); // Adiciona a data à lista de datas
            dataSpots.add(FlSpot(
              dateTime.millisecondsSinceEpoch.toDouble(),
              amount.toDouble(),
            ));
          });

          // Ordenar os dados por data (coordenada x)
          dataSpots.sort((a, b) => a.x.compareTo(b.x));
          dates.sort(); // Ordenar as datas

          // Limitar a lista de spots aos últimos 3 valores
          if (dataSpots.length > 3) {
            dataSpots = dataSpots.sublist(dataSpots.length - 3);
          }

          setState(() {
            spots = dataSpots;
          });
        } else {
          print('Nenhum dado de lixo encontrado');
        }
      } else {
        print('Usuário com email ${user!.email} não encontrado');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
    }
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    DateTime date = DateTime.fromMillisecondsSinceEpoch(value.toInt());

    // Exibir título somente para as datas específicas
    if (dates.any((d) => d.millisecondsSinceEpoch == value.toInt())) {
      String text = DateFormat('dd/MM').format(date);
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(text, style: style),
      );
    } else {
      return Container();
    }
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    return Text('${value.toInt()} kg', style: style, textAlign: TextAlign.left);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gráfico de Lixo Produzido por Semana'),
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
        backgroundColor:
            ColorSchemeCommom().themeData.colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Center(
          child: spots.isNotEmpty
              ? LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: bottomTitleWidgets,
                          interval: 86400000 * 3, // Intervalo de 1 semana
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: leftTitleWidgets,
                          reservedSize: 42,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: const Color(0xff37434d)),
                    ),
                    minX: spots.first.x,
                    maxX: spots.last.x,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                )
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
