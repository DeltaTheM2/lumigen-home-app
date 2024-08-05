import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lumigen/home.dart';
import 'package:lumigen/insightsPage.dart';
import 'package:lumigen/userPage.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int selectedPageIndex = 0;
  final List<Widget> pages = [
    HomePage(),
    InsightsPage(),
    UserPage()
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lumigen"),
        elevation: 2,
      ),
      body: Center(child: pages[selectedPageIndex],),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPageIndex,
        onDestinationSelected: (int index){
          setState(() {
            selectedPageIndex = index;
          });
        },
        elevation: 2,
        destinations: [
          NavigationDestination(
              icon: Icon(selectedPageIndex == 0 ? Icons.home : Icons.home_outlined),
              label: "Home"
          ),
          NavigationDestination(
              icon: Icon(selectedPageIndex == 1 ? Icons.insights : Icons.insights_outlined),
              label: "Insights"
          ),
          NavigationDestination(
              icon: Icon(selectedPageIndex == 2 ? Icons.grid_view_rounded : Icons.grid_view_outlined),
              label: "Me"
          )
        ],
      ),
    );
  }
}