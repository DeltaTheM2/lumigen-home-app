import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class InsightsPage extends StatefulWidget {
  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  List<FlSpot> aqiData = [];
  bool isLoading = true;
  String selectedTimeFrame = '7 days';

  @override
  void initState() {
    super.initState();
    loadCachedData();
  }

  Future<void> loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('aqiData_$selectedTimeFrame');

    if (cachedData != null) {
      List<dynamic> decodedData = jsonDecode(cachedData);
      setState(() {
        aqiData = decodedData.map((item) => FlSpot(item[0], item[1])).toList();
        isLoading = false;
      });
    } else {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    DateTime now = DateTime.now();
    DateTime startDate;

    switch (selectedTimeFrame) {
      case '1 month':
        startDate = now.subtract(Duration(days: 30));
        break;
      case 'All time':
        startDate = DateTime(1970);
        break;
      case '7 days':
      default:
        startDate = now.subtract(Duration(days: 7));
        break;
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('air-quality')
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .orderBy('timestamp')
        .get();

    List<FlSpot> data = snapshot.docs.map((doc) {
      Map<String, dynamic> airQualityData = doc['airQuality'];
      double sum = 0;
      int count = 0;
      airQualityData.forEach((key, value) {
        sum += value;
        count++;
      });
      double meanAQI = sum / count;
      return FlSpot(
        doc['timestamp'].millisecondsSinceEpoch.toDouble(),
        meanAQI,
      );
    }).toList();

    setState(() {
      aqiData = data;
      isLoading = false;
    });

    saveDataToCache(data);
  }

  Future<void> saveDataToCache(List<FlSpot> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<List<double>> encodedData = data.map((spot) => [spot.x, spot.y]).toList();
    prefs.setString('aqiData_$selectedTimeFrame', jsonEncode(encodedData));
  }

  List<LineChartBarData> getLineChartData() {
    return [
      LineChartBarData(
        spots: aqiData,
        isCurved: true,
        barWidth: 3,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
        ),
      ),
    ];
  }

  Widget buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Color(0xffe7e8ec),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Color(0xffe7e8ec),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toString(),
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                DateTime date =
                DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    DateFormat.MMMd().format(date),
                    style: TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Color(0xffe7e8ec),
            width: 1,
          ),
        ),
        lineBarsData: getLineChartData(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insights"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedTimeFrame,
              items: <String>['7 days', '1 month', 'All time']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTimeFrame = newValue!;
                  isLoading = true;
                  loadCachedData();
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : buildChart(),
            ),
          ],
        ),
      ),
    );
  }
}
