import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumigen/components/arcProgressIndicator.dart';
import 'package:lumigen/firebase/authentication.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double progress = 0.0;
  int aqi = 40;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(10),
            child: Padding(padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Positioned(
                      bottom: 8,
                      child: ArcProgressIndicator(
                          progress: progress,
                          child: const Icon(Icons.air, size: 75,
                          )
                      )
                  ),
                  Positioned(
                    bottom: 2,
                    child: Text(
                      '$aqi AQI',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  TextButton(onPressed: () async {
                    DateTime time = DateTime.now();
                    String date = DateFormat('MM-dd-yyyy').format(time);
                    int latestAqi = await AuthenticationHelper().getLastAirQuality(date);
                    double newProgress = latestAqi / 400;
                    setState(() {
                      aqi = latestAqi;
                      progress = newProgress;
                    });
                  }, child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh),
                      Text("Refresh")
                    ],
                  ))
                ],
              ),),
          )
        ],
      ),
    );;
  }
}
