import 'package:bottom_bar_with_sheet/bottom_bar_with_sheet.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/pages/map_page/map_page.dart';
import 'package:diplom/widgets/atlitude_chart.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int currentPageIndex = 0;
  bool showBut = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        const MapPage(),
        Container(),
        Container(),
      ][currentPageIndex],
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
              showBut = index == 0;
            });
          },
          animationDuration: const Duration(milliseconds: 500),
          selectedIndex: currentPageIndex,
          destinations: const [
            NavigationDestination(
              selectedIcon: Icon(Icons.map),
              icon: Icon(Icons.map_outlined),
              label: 'Карта',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.route),
              icon: Icon(Icons.route_outlined),
              label: 'Маршруты',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outline),
              label: 'Профиль',
            ),
          ]),
    );
  }
}
