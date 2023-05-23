// ignore_for_file: unused_field, must_be_immutable, avoid_init_to_null

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/user.dart';
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
//with AutomaticKeepAliveClientMixin<RoutesPage>
{
  final DBService _service = DBService();
  late Future<List<dynamic>> _com, _mr, _u;
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
    _com = loadComments();
    _mr = loadMapRoutes();
    _u = loadUsers();
  }

  Future<List<dynamic>> loadComments() async {
    return _service.get('comments');
  }

  Future<List<dynamic>> loadMapRoutes() async {
    return _service.get('map-routes');
  }

  Future<List<dynamic>> loadUsers() async {
    return _service.get('users');
  }

  Future<void> refresh() async {
    setState(() {
      _com = loadComments();
      _mr = loadMapRoutes();
      _u = loadUsers();
    });
  }

  Map<String, dynamic> updateCategories(
      List<Comment> com, List<MapRoute> mr, List<User> u) {
    Map<String, dynamic> map = {
      'yours': [],
      'saves': [],
      'default': [],
      'other': []
    };
    final auth = Provider.of<AuthenticationService>(context, listen: false);
    String uid = '';
    User my = User();
    if (!auth.isAnonymous || auth.isVerified) {
      uid = auth.uid;
      my = u.firstWhere((element) => element.uid == uid);
    }
    for (var element in mr) {
      if (!auth.isAnonymous || auth.isVerified) {
        if (element.uid == uid) {
          map['yours'].add({
            'map': element,
            'comment': com.where((el) => el.routeid == element.id).toList()
          });
          continue;
        }
        if (my.saves.contains(element.id)) {
          map['saves'].add({
            'map': element,
            'comment': com.where((el) => el.routeid == element.id).toList(),
            'user': u.firstWhere((el) => el.uid == element.uid,
                orElse: () => User())
          });
          continue;
        }
      }
      if (element.uid == 'default') {
        map['default'].add({
          'map': element,
          'comment': com.where((el) => el.routeid == element.id).toList(),
        });
        continue;
      }
      map['other'].add({
        'map': element,
        'comment': com.where((el) => el.routeid == element.id).toList(),
        'user': u.firstWhere((el) => el.uid == element.uid)
      });
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
    //super.build(context);
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
            loadComments(),
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
                  data[0].cast<Comment>(),
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
                          list: map['yours'] ?? [],
                          update: refresh,
                          delete: 1,
                        ),
                        map['yours'].isNotEmpty),
                    ..._sliver(
                        const SliverHeader(text: 'Сохранненные маршруты'),
                        RoutesList(
                          list: map['saves'] ?? [],
                          update: refresh,
                          delete: 2,
                        ),
                        map['saves'].isNotEmpty),
                    ..._sliver(
                        const SliverHeader(text: 'Наши маршруты'),
                        RoutesList(
                          list: map['default'] ?? [],
                          update: refresh,
                        ),
                        map['default'].isNotEmpty),
                    ..._sliver(
                        const SliverHeader(text: 'Пользовательские маршруты'),
                        RoutesList(
                          list: map['other'] ?? [],
                          save: map['yours'] != null,
                          update: refresh,
                        ),
                        map['other'].isNotEmpty),
                  ],
                ),
              );
            }
          },
        ));
  }

  // @override
  // bool get wantKeepAlive => true;
}
