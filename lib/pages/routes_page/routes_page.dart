// ignore_for_file: unused_field, must_be_immutable

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/public_route.dart';
import 'package:diplom/logic/database/users.dart';
import 'package:diplom/pages/routes_page/routes_list.dart';
import 'package:diplom/pages/routes_page/sliver_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage>
    with AutomaticKeepAliveClientMixin<RoutesPage> {
  final DBService _service = DBService();
  late Future<List<dynamic>> _pr, _mr, _u;
  AuthenticationService auth = AuthenticationService();
  TextEditingController ctrl = TextEditingController();
  bool search = false;
  String? name = null;

  @override
  void initState() {
    super.initState();
    Provider.of<AuthenticationService>(context, listen: false)
        .stream
        .listen((event) {
      refresh();
    });
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
    final auth = Provider.of<AuthenticationService>(context, listen: false);
    if (!auth.isAnonymous || auth.isVerified) {
      final uid = auth.uid;
      final my = u.firstWhere((element) => element.uid == uid);
      map['yours']['public'] =
          pr.where((element) => element.uid == uid).toList();
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
      map['saves']['user'] = map['saves']['public'].map((element) {
        final t = u.firstWhere(
          (el) => el.uid == element.uid,
          orElse: () => User(),
        );
        if (t.uid != '') {
          return t;
        }
      }).toList();
    }
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
    map['other']['user'] = map['other']['public'].map((element) {
      final t = u.firstWhere(
        (el) => el.uid == element.uid,
        orElse: () => User(),
      );
      if (t.uid != '') {
        return t;
      }
    }).toList();
    if (search && name != null) {
      if (!auth.isAnonymous || auth.isVerified) {
        for (var i = map['yours']['map'].length - 1; i >= 0; i--) {
          if (name!
              .toLowerCase()
              .allMatches(map['yours']['map'][i].name.toLowerCase())
              .isEmpty) {
            map['yours']['map'].removeAt(i);
            map['yours']['public'].removeAt(i);
          }
        }
        for (var i = map['saves']['map'].length - 1; i >= 0; i--) {
          if (name!
              .toLowerCase()
              .allMatches(map['saves']['map'][i].name.toLowerCase())
              .isEmpty) {
            map['saves']['map'].removeAt(i);
            map['saves']['public'].removeAt(i);
            map['saves']['user'].removeAt(i);
          }
        }
      }

      for (var i = map['default']['map'].length - 1; i >= 0; i--) {
        if (name!
            .toLowerCase()
            .allMatches(map['default']['map'][i].name.toLowerCase())
            .isEmpty) {
          map['default']['map'].removeAt(i);
          map['default']['public'].removeAt(i);
        }
      }
      for (var i = map['other']['map'].length - 1; i >= 0; i--) {
        if (name!
            .toLowerCase()
            .allMatches(map['other']['map'][i].name.toLowerCase())
            .isEmpty) {
          map['other']['map'].removeAt(i);
          map['other']['public'].removeAt(i);
          map['other']['user'].removeAt(i);
        }
      }
    }
    return map;
  }

  List<Widget> _sliver(widget1, widget2, flag) {
    return [
      Visibility(
        child: widget1,
        visible: flag,
        replacement: const SliverToBoxAdapter(),
      ),
      Visibility(
        child: widget2,
        visible: flag,
        replacement: const SliverToBoxAdapter(),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: search
              ? IconButton(
                  onPressed: () {
                    ctrl.text = '';
                    setState(() {
                      search = false;
                      name = null;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                )
              : null,
          title: search
              ? TextField(
                  onSubmitted: (value) {
                    setState(() {
                      name = value;
                    });
                  },
                  onChanged: (value) {
                    if (value == '') {
                      setState(() {
                        name = null;
                      });
                    }
                  },
                  controller: ctrl,
                  decoration: InputDecoration(
                      hintText: 'Найти...',
                      alignLabelWithHint: true,
                      suffixIcon: IconButton(
                        onPressed: () {
                          ctrl.text = '';
                        },
                        icon: const Icon(Icons.clear),
                      )),
                  textAlignVertical: TextAlignVertical.bottom,
                )
              : const Text('Маршруты'),
          actions: !search
              ? [
                  IconButton(
                      onPressed: () {
                        setState(() {
                          search = true;
                        });
                      },
                      icon: const Icon(Icons.search))
                ]
              : null,
        ),
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
                    // search
                    //     ? SliverToBoxAdapter(
                    //         child: Wrap(
                    //           children: ['название', 'пользователь']
                    //               .map((e) => ChoiceChip(
                    //                   label: Text(e),
                    //                   selected: list.contains(e)))
                    //               .toList(),
                    //         ),
                    //       )
                    //     : const SliverToBoxAdapter(),
                    ..._sliver(
                        const SliverHeader(text: 'Ваши маршруты'),
                        RoutesList(
                          list:
                              map['yours'].cast<String, List<dynamic>>() ?? [],
                          update: refresh,
                          delete: 1,
                        ),
                        map['yours']['public'] != null &&
                            map['yours']['public'].isNotEmpty),
                    ..._sliver(
                        const SliverHeader(text: 'Сохранненные маршруты'),
                        RoutesList(
                          list:
                              map['saves'].cast<String, List<dynamic>>() ?? [],
                          update: refresh,
                          delete: 2,
                        ),
                        map['saves']['public'] != null &&
                            map['saves']['public'].isNotEmpty),
                    ..._sliver(
                        const SliverHeader(text: 'Наши маршруты'),
                        RoutesList(
                          list: map['default'].cast<String, List<dynamic>>() ??
                              [],
                          update: refresh,
                        ),
                        map['default']['public'].isNotEmpty),
                    ..._sliver(
                        const SliverHeader(text: 'Пользовательские маршруты'),
                        RoutesList(
                          list:
                              map['other'].cast<String, List<dynamic>>() ?? [],
                          save: map['yours']['public'] != null,
                          update: refresh,
                        ),
                        map['other']['public'].isNotEmpty),
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
