import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, Map<String, double>>> loadReportData() async {
  final url = Uri.parse('http://192.168.0.113:5000/detailed-daily-report'); // flask
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> rawData = json.decode(response.body);
    return rawData.map((day, values) {
      final map = Map<String, double>.fromEntries(
        (values as Map<String, dynamic>).entries.map(
          (e) => MapEntry(e.key, (e.value as num).toDouble()),
        ),
      );
      return MapEntry(day, map);
    });
  } else {
    throw Exception('Failed to load data');
  }
}

enum LegendShape { circle, rectangle }

class DailyReport extends StatefulWidget {
  final String day;
  const DailyReport({Key? key, required this.day}) : super(key: key);

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
  Map<String, double>? dataMap;
  final colorList = <Color>[
    const Color(0xff5409DA),
    const Color(0xff4E71FF),
    const Color(0xff8DD8FF),
    const Color(0xffBBFBFF),
  ];

  @override
  void initState() {
    super.initState();
    _loadDataforToday(widget.day);
  }

  Future<void> _loadDataforToday(String day) async {
    final allData = await loadReportData();
    setState(() {
      dataMap = allData[day];
    });
  }

  ChartType _chartType = ChartType.ring; // default chart type

  @override
  Widget build(BuildContext context) {
    final chartData = (dataMap == null || dataMap!.isEmpty)
        ? <String, double>{"No data": 1}
        : dataMap!;

    return Center(
      child: PieChart(
        dataMap: chartData,
        animationDuration: const Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        chartRadius: MediaQuery.of(context).size.width / 2.0,
        colorList: (dataMap == null || dataMap!.isEmpty)
            ? [Colors.grey.shade300]
            : colorList,
        initialAngleInDegree: 0,
        chartType: _chartType,
        ringStrokeWidth: 32,
        legendOptions: LegendOptions(
          showLegends: !(dataMap == null || dataMap!.isEmpty),
          legendPosition: LegendPosition.right,
          showLegendsInRow: false,
          legendTextStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        chartValuesOptions: ChartValuesOptions(
          showChartValueBackground: false,
          showChartValues: dataMap != null && dataMap!.isNotEmpty,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
          decimalPlaces: 1,
        ),
        centerText: (dataMap == null || dataMap!.isEmpty) ? "No data." : "",
        centerTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }
}
