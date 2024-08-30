import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumigen/components/arcProgressIndicator.dart';
import 'package:lumigen/firebase/authentication.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double progress = 0.0;
  int aqi = 40;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCachedData();
  }

  Future<void> loadCachedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('homePageData');

    if (cachedData != null) {
      Map<String, dynamic> data = jsonDecode(cachedData);
      setState(() {
        aqi = data['aqi'];
        progress = data['progress'];
        isLoading = false;
      });
    } else {
      fetchData();
    }
  }

  Future<void> fetchData() async {
    DateTime time = DateTime.now();
    String date = DateFormat('MM-dd-yyyy').format(time);
    int latestAqi = await AuthenticationHelper().getLastAirQuality(date);
    double newProgress = latestAqi / 400;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedData = prefs.getString('homePageData');
    bool isDataChanged = true;

    if (cachedData != null) {
      Map<String, dynamic> data = jsonDecode(cachedData);
      int cachedAqi = data['aqi'];
      double cachedProgress = data['progress'];

      // Check if the new data is the same as the cached data
      if (latestAqi == cachedAqi && newProgress == cachedProgress) {
        isDataChanged = false;
      }
    }

    setState(() {
      aqi = latestAqi;
      progress = newProgress;
      isLoading = false;
    });

    if (isDataChanged) {
      saveDataToCache(latestAqi, newProgress);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No new data available')),
      );
    }
  }

  Future<void> saveDataToCache(int aqi, double progress) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> data = {
      'aqi': aqi,
      'progress': progress,
    };
    prefs.setString('homePageData', jsonEncode(data));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Positioned(
                    bottom: 8,
                    child: ArcProgressIndicator(
                      progress: progress,
                      child: const Icon(
                        Icons.air,
                        size: 75,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    child: Text(
                      '$aqi', textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Positioned(child: Text('Room Air Quality Index',),),
                  TextButton(
                    onPressed: () async {
                      await fetchData();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh),
                        Text("Refresh"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
