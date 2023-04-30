// ignore_for_file: unused_field

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/public_route.dart';
import 'package:diplom/logic/database/users.dart';
import 'package:diplom/pages/routes_page/routes_list.dart';
import 'package:diplom/pages/routes_page/sliver_header.dart';
import 'package:flutter/material.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage>
    with AutomaticKeepAliveClientMixin {
  final DBService _service = DBService();
  final auth = AuthenticationService();
  late Future<List<dynamic>> _pr, _mr, _u;

  @override
  void initState() {
    super.initState();

    _pr = loadPublicRoutes();
    _mr = loadMapRoutes();
    _u = loadUsers();
  }

  Future<List<dynamic>> loadPublicRoutes() async {
    return _service.get('public-routes');
  }

  Future<List<dynamic>> loadMapRoutes() async {
    return _service.get('map-routes');
  }

  Future<List<dynamic>> loadUsers() async {
    return _service.get('users');
  }

  Future<void> refresh() async {
    setState(() {
      _pr = loadPublicRoutes();
      _mr = loadMapRoutes();
      _u = loadUsers();
    });
  }

  Map<String, dynamic> updateCategories(
      List<PublicRoute> pr, List<MapRoute> mr, List<User> u) {
    Map<String, dynamic> map = {
      'yours': {},
      'saves': {},
      'default': {},
      'other': {}
    };
    final uid = auth.uid;
    final my = u.firstWhere((element) => element.uid == uid);
    map['yours']['public'] = pr.where((element) => element.uid == uid).toList();
    map['yours']['map'] = mr
        .where((element) =>
            map['yours']['public'].any((el) => el.routeid == element.id))
        .toList();
    map['saves']['public'] =
        pr.where((element) => my.saves.contains(element.routeid)).toList();
    map['saves']['map'] = mr
        .where((element) =>
            map['saves']['public'].any((el) => el.routeid == element.id))
        .toList();
    map['default']['public'] =
        pr.where((element) => element.uid == 'default').toList();
    map['default']['map'] = mr
        .where((element) =>
            map['default']['public'].any((el) => el.routeid == element.id))
        .toList();
    List<PublicRoute> list = [];
    list.addAll(map['yours']['public'] ?? []);
    list.addAll(map['saves']['public'] ?? []);
    list.addAll(map['default']['public'] ?? []);
    map['other']['public'] =
        pr.where((element) => !list.contains(element)).toList();
    map['other']['map'] = mr
        .where((element) =>
            map['other']['public'].any((el) => el.routeid == element.id))
        .toList();
    return map;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(),
        body: FutureBuilder(
          future: Future.wait([
            loadPublicRoutes(),
            loadMapRoutes(),
            loadUsers(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final data = snapshot.data ?? [];
              Map<String, dynamic> map = updateCategories(
                  data[0].cast<PublicRoute>(),
                  data[1].cast<MapRoute>(),
                  data[2].cast<User>());
              return RefreshIndicator(
                onRefresh: refresh,
                child: CustomScrollView(
                  slivers: [
                    const SliverHeader(text: 'Ваши маршруты'),
                    RoutesList(
                        list: map['yours'].cast<String, List<dynamic>>() ?? []),
                    const SliverHeader(text: 'Сохранненные маршруты'),
                    RoutesList(
                        list: map['saves'].cast<String, List<dynamic>>() ?? []),
                    const SliverHeader(text: 'Наши маршруты'),
                    RoutesList(
                        list:
                            map['default'].cast<String, List<dynamic>>() ?? []),
                    const SliverHeader(text: 'Пользовательские маршруты'),
                    RoutesList(
                        list: map['other'].cast<String, List<dynamic>>() ?? []),
                  ],
                ),
              );
            }
          },
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
