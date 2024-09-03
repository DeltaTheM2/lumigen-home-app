import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lumigen/firebase/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class InsightsPage extends StatefulWidget {
  @override
  _InsightsPageState createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  Map<String, int> airQualityData = {};
  bool isLoading = true;
  String selectedDuration = '1 Week'; // Default duration

  @override
  void initState() {
    super.initState();
    loadAirQualityData();
  }

  Future<void> loadAirQualityData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dates = _getDateRange(selectedDuration);

    Map<String, int> allData = {};
    for (String date in dates) {
      // Check if data is cached
      if (prefs.containsKey(date)) {
        allData.addAll(
            Map<String, int>.from(jsonDecode(prefs.getString(date)!)));
      } else {
        Map<String, int> data = await AuthenticationHelper().getAirQuality(date);
        if (data.isNotEmpty) {
          allData.addAll(data);
          prefs.setString(date, jsonEncode(data)); // Cache the data
        }
      }
    }

    setState(() {
      airQualityData = allData;
      isLoading = false;
    });
  }

  List<String> _getDateRange(String duration) {
    DateTime now = DateTime.now();
    List<String> dates = [];
    if (duration == '1 Week') {
      for (int i = 0; i < 7; i++) {
        dates.add(DateFormat('MM-dd-yyyy').format(now.subtract(Duration(days: i))));
      }
    } else if (duration == '1 Month') {
      for (int i = 0; i < 30; i++) {
        dates.add(DateFormat('MM-dd-yyyy').format(now.subtract(Duration(days: i))));
      }
    } else if (duration == 'All Time') {
      // Add your logic for all-time data; this might involve pulling all available data
      dates = ['01-01-2023']; // Placeholder: Modify this based on your data
    }
    return dates;
  }

  List<FlSpot> _generateChartData() {
    List<FlSpot> chartData = [];
    airQualityData.forEach((key, value) {
      try {
        // Check if the key is already a date
        if (key.contains('-')) {
          DateTime date = DateFormat('MM-dd-yyyy').parse(key);
          double x = date.millisecondsSinceEpoch.toDouble() / (1000 * 60 * 60 * 24);
          double y = value.toDouble();
          chartData.add(FlSpot(x, y));
        } else {
          // Otherwise, treat it as an epoch timestamp
          double x = int.parse(key).toDouble() / (1000 * 60 * 60 * 24);
          double y = value.toDouble();
          chartData.add(FlSpot(x, y));
        }
      } catch (e) {
        print('Error parsing date: $key, $e');
      }
    });
    chartData.sort((a, b) => a.x.compareTo(b.x)); // Sort by date
    return chartData;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedDuration,
          items: ['1 Week', '1 Month', 'All Time'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDuration = value!;
              isLoading = true;
              loadAirQualityData(); // Reload data when duration changes
            });
          },
        ),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : airQualityData.isEmpty
            ? Center(child: Text('No data available'))
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 400, // Specify a fixed height
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateChartData(),
                    isCurved: true,
                    barWidth: 2,
                    color: Colors.blue,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.2),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                ],
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        if (value % 50 == 0) {
                          return Text(value.toInt().toString());
                        }
                        return Container();
                      },
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false
                    )
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: 2, // Show every 2nd label
                      getTitlesWidget: (value, meta) {
                        DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          (value * 1000 * 60 * 60 * 24).toInt(),
                        );
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            DateFormat('MM/dd').format(date), // Use shorter date format
                            style: TextStyle(
                              fontSize: 10,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          angle: -45, // Rotate the labels by 45 degrees
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
                gridData: FlGridData(show: true, drawVerticalLine: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
