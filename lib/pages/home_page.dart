import 'package:diplom/pages/map_page/map_page.dart';
import 'package:diplom/pages/routes_page/routes_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool showBut = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [
          const MapPage(),
          const RoutesPage(),
          Container(),
        ],
        onPageChanged: (value) {
          setState(() {
            showBut = value == 0;
            _currentPage = value;
          });
        },
      ),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            _pageController.jumpToPage(index);
          },
          selectedIndex: _currentPage,
          animationDuration: const Duration(milliseconds: 500),
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
