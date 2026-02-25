import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';

class PerformanceChartScreen extends StatefulWidget {
  const PerformanceChartScreen({super.key});

  @override
  State<PerformanceChartScreen> createState() =>
      _PerformanceChartScreenState();
}

class _PerformanceChartScreenState
    extends State<PerformanceChartScreen> {

  final service = FirestoreService();
  List<double> moyennes = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    moyennes = await service.getAllMoyennes();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Performance")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  moyennes.length,
                  (index) => FlSpot(
                      index.toDouble(),
                      moyennes[index]),
                ),
                isCurved: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}