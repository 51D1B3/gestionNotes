import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:notes_app/services/firestore_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final FirestoreService _service = FirestoreService();
  late Future<List<Map<String, dynamic>>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _prepareStats();
  }

  int _getMentionValue(String mention) {
    switch (mention) {
      case "Très bien": return 4;
      case "Bien": return 3;
      case "Assez bien": return 2;
      case "Passable": return 1;
      default: return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _prepareStats() async {
    final semestersSnapshot = await _service.getSemesters().first;
    final List<Map<String, dynamic>> semesterStats = [];

    for (var semesterDoc in semestersSnapshot.docs) {
      final subjectsSnapshot = await _service.getSubjects(semesterDoc.id).first;
      int mentionSum = 0;
      int subjectCount = subjectsSnapshot.docs.length;

      for (var subjectDoc in subjectsSnapshot.docs) {
        mentionSum += _getMentionValue(subjectDoc['mention'] ?? 'Echec');
      }

      double average = (subjectCount > 0) ? (mentionSum / subjectCount) : 0.0;
      semesterStats.add({
        'name': semesterDoc['name'],
        'average': average,
      });
    }
    return semesterStats;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'.tr()),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No data found.".tr()));
          }

          final stats = snapshot.data!;
          double totalAverage = stats.fold(0.0, (sum, item) => sum + item['average']) / stats.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Vue d'ensemble".tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${"Moyenne Générale".tr()} : ", style: const TextStyle(fontSize: 18)),
                        Text(totalAverage.toStringAsFixed(2), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text("Barre de Progression".tr(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 4.0, 
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                         topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                         bottomTitles: AxisTitles(
                           sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                                if (value.toInt() < stats.length) {
                                  String name = stats[value.toInt()]['name'];
                                  if (name.contains("Semestre")) {
                                    name = name.replaceAll("Semestre", "Sem".tr());
                                  }
                                  return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(name, style: const TextStyle(fontSize: 10)),
                                  );
                                }
                                return const SizedBox();
                            },
                            reservedSize: 30,
                           )
                         )
                      ),
                      gridData: const FlGridData(show: true, drawVerticalLine: false),
                      borderData: FlBorderData(show: false),
                      barGroups: stats.asMap().entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(toY: entry.value['average'], color: Colors.lightBlue, width: 20, borderRadius: BorderRadius.circular(5)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
