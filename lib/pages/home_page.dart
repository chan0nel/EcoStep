import 'package:diplom/logic/map_provider.dart';
import 'package:diplom/pages/map_page/map_page.dart';
import 'package:diplom/pages/profile_page/profile_page.dart';
import 'package:diplom/pages/routes_page/routes_page.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Provider.of<InternetConnectionStatus>(context) ==
              InternetConnectionStatus.disconnected
          ? AppBar(
              backgroundColor: Colors.red,
              title: const Text(
                'Нет подключения к интернету, '
                'большинство функций отключены',
                style: TextStyle(fontSize: 12),
              ),
            )
          : null,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller:
            Provider.of<MapModel>(context, listen: false).pageController,
        children: const [
          MapPage(),
          RoutesPage(),
          ProfilePage(),
        ],
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
          });
        },
      ),
      bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            Provider.of<MapModel>(context, listen: false)
                .pageController
                .animateToPage(index,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.bounceIn);
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
