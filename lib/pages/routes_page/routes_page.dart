// ignore_for_file: unused_field, must_be_immutable, avoid_init_to_null

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/user.dart';
import 'package:diplom/logic/provider/list_provider.dart';
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
  late Future<List<dynamic>> _com, _mr, _u;
  AuthenticationService auth = AuthenticationService();
  TextEditingController ctrl = TextEditingController();
  bool upd = false;
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
      upd = true;
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
    if (search) {
      map = _search(map);
    }
    return map;
  }

  List<Widget> _sliver(widget1, widget2, name) {
    return [
      Consumer<ListModel>(
        builder: (context, value, child) => Visibility(
          child: widget1,
          visible: value.map[name].isNotEmpty,
          replacement: const SliverToBoxAdapter(),
        ),
      ),
      Consumer<ListModel>(
        builder: (context, value, child) => Visibility(
          child: widget2,
          visible: value.map[name].isNotEmpty && value.shown[name]!,
          replacement: const SliverToBoxAdapter(),
        ),
      ),
    ];
  }

  dynamic _search(Map<String, dynamic> map) {
    if (name == null) return map;
    final mapSearch = Provider.of<ListModel>(context).search;
    String search = name!.trim().toLowerCase();
    map.map((key, value) {
      value.removeWhere((element) {
        bool flag1 = mapSearch['название']
            ? !element['map'].name.toLowerCase().contains(search)
            : false;
        bool flag2 = false;
        if (mapSearch['пользователь']) {
          flag2 = element['user'] != null
              ? !element['user'].name.toLowerCase().contains(search)
              : true;
        }
        bool flag3 = mapSearch['тип передвижения']
            ? !element['map'].profile.toLowerCase().contains(search)
            : false;
        return ((mapSearch['название'] == flag1) &&
            (mapSearch['пользователь'] == flag2) &&
            (mapSearch['тип передвижения'] == flag3));
      });
      return MapEntry(key, value);
    });
    if (mapSearch['с подъемом'] != mapSearch['со спуском']) {
      if (mapSearch['с подъемом']) {
        map.map((key, value) {
          value.removeWhere((element) {
            return (element['map'].ascent <= element['map'].descent) == true;
          });
          return MapEntry(key, value);
        });
      }
      if (mapSearch['со спуском']) {
        map.map((key, value) {
          value.removeWhere((element) =>
              (element['map'].ascent > element['map'].descent) == true);
          return MapEntry(key, value);
        });
      }
    }
    return map;
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
            loadComments(),
            loadMapRoutes(),
            loadUsers(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              upd = false;
            }
            if (snapshot.connectionState == ConnectionState.waiting && !upd) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final data = snapshot.data ?? [];
              upd = true;
              dynamic temp = updateCategories(data[0].cast<Comment>(),
                  data[1].cast<MapRoute>(), data[2].cast<User>());
              Provider.of<ListModel>(context, listen: false).setMap(temp);
              return RefreshIndicator(
                onRefresh: refresh,
                child: CustomScrollView(
                  slivers: [
                    Visibility(
                      visible: search,
                      replacement: const SliverToBoxAdapter(),
                      child: SliverToBoxAdapter(
                          child: Consumer<ListModel>(
                        builder: (context, value, child) => Wrap(
                          spacing: 5.0,
                          children: value.search.keys
                              .map((e) => ChoiceChip(
                                  onSelected: (val) {
                                    value.changeSearch(e, val);
                                  },
                                  label: Text(e),
                                  selected: value.search[e]))
                              .toList(),
                        ),
                      )),
                    ),
                    ..._sliver(
                        const SliverHeader(
                            text: 'Ваши маршруты', name: 'yours'),
                        RoutesList(
                          name: 'yours',
                          update: refresh,
                          delete: 1,
                        ),
                        'yours'),
                    ..._sliver(
                        const SliverHeader(
                            text: 'Сохранненные маршруты', name: 'saves'),
                        RoutesList(
                          name: 'saves',
                          update: refresh,
                          delete: 2,
                        ),
                        'saves'),
                    ..._sliver(
                        const SliverHeader(
                            text: 'Наши маршруты', name: 'default'),
                        RoutesList(
                          name: 'default',
                          update: refresh,
                        ),
                        'default'),
                    ..._sliver(
                        const SliverHeader(
                            text: 'Пользовательские маршруты', name: 'other'),
                        RoutesList(
                          name: 'other',
                          save: !AuthenticationService().isAnonymous,
                          update: refresh,
                        ),
                        'other'),
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
