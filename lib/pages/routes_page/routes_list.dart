// ignore_for_file: unused_import, use_build_context_synchronously

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/user.dart';
import 'package:diplom/logic/list_provider.dart';
import 'package:diplom/logic/map_provider.dart';
import 'package:diplom/logic/theme_provider.dart';
import 'package:diplom/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';

class RoutesList extends StatefulWidget {
  final List<dynamic> list;
  final bool save;
  final int delete;
  final Function update;
  const RoutesList(
      {super.key,
      required this.list,
      this.save = false,
      this.delete = 0,
      required this.update});

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  @override
  Widget build(BuildContext context) {
    final length = widget.list.length;
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        semanticIndexOffset: 2,
        childCount: length,
        (context, index) {
          MapRoute mr = widget.list[index]['map'];
          User? user = widget.list[index]['user'];
          List<Comment>? com = widget.list[index]['comment'];
          return ExpansionTile(
            tilePadding:
                user != null ? const EdgeInsets.fromLTRB(0, 0, 10, 0) : null,
            leading: Visibility(
              visible: user != null,
              child: IconButton(
                  onPressed: () async {
                    if (mr.block.contains(AuthenticationService().uid)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Вы уже пожаловались на данный маршрут'),
                      ));
                    } else {
                      final res = await showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                            opt: 'пожаловаться на маршрут \'${mr.name}\''),
                      );
                      if (res) {
                        mr.block.add(AuthenticationService().uid);
                        await DBService().update('map-routes/${mr.id}', mr);
                        if (mr.block.length >= 5) {
                          widget.update();
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.block)),
            ),
            title: Text(mr.name),
            subtitle: Row(children: [
              Visibility(
                visible: user != null,
                child: GestureDetector(
                  onTap: () async {
                    if (user!.block.contains(AuthenticationService().uid)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Вы уже пожаловались на данного пользователя'),
                      ));
                    } else {
                      final res = await showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                            opt: 'пожаловаться на пользователя '
                                '\'${user.name}\''),
                      );
                      if (res) {
                        user.block.add(AuthenticationService().uid);
                        await DBService().update('users/${user.uid}', user);
                        if (user.block.length >= 5) {
                          widget.update();
                        }
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 5),
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5))),
                    child: Image.asset(
                      'images/photo (${widget.list[index]['user']?.photo}).png',
                      width: 35,
                      height: 35,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: user != null,
                child: GestureDetector(
                  onTap: () async {
                    if (user!.block.contains(AuthenticationService().uid)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Вы уже пожаловались на данного пользователя'),
                      ));
                    } else {
                      final res = await showDialog(
                        context: context,
                        builder: (context) => ConfirmDialog(
                            opt: 'пожаловаться на пользователя '
                                '\'${user.name}\''),
                      );
                      if (res) {
                        user.block.add(AuthenticationService().uid);
                        await DBService().update('users/${user.uid}', user);
                        if (user.block.length >= 5) {
                          widget.update();
                        }
                      }
                    }
                  },
                  child: Text(widget.list[index]['user']?.name ?? ''),
                ),
              ),
              Visibility(
                visible: user != null,
                child: const Spacer(flex: 10),
              ),
              const Icon(Icons.comment_outlined),
              const SizedBox(width: 5),
              Text(com?.length.toString() ?? '0')
            ]),
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 165,
                      width: 165,
                      child: Consumer<ThemeProvider>(
                        builder: (context, value, child) => FlutterMap(
                          options: MapOptions(
                              interactiveFlags: InteractiveFlag.none,
                              bounds: mr.bbox,
                              boundsOptions: const FitBoundsOptions(
                                  padding: EdgeInsets.all(30))),
                          children: [
                            TileLayer(
                              urlTemplate: value.curTheme
                                  ? 'https://tile.jawg.io/jawg-sunny/{z}/{x}/{y}.png?'
                                      'access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM'
                                  : 'https://tile.jawg.io/jawg-dark/{z}/{x}/{y}.png?'
                                      'access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM',
                            ),
                            PolylineLayer(
                              polylines: [mr.polyline],
                            )
                          ],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Протяженность: '
                          '${mr.distanceCast}',
                          maxLines: 2,
                        ),
                        Text(
                          'Длительность: '
                          '${mr.timeCast}',
                          maxLines: 2,
                        ),
                        Text(
                          'Подъем: '
                          '${mr.ascent.toString()}',
                          maxLines: 2,
                        ),
                        Text(
                          'Спуск: '
                          '${mr.descent.toString()}',
                          maxLines: 2,
                        ),
                        Consumer2<ListModel, MapModel>(
                          builder: (context, value, value2, child) {
                            return ElevatedButton(
                                onPressed: () async {
                                  value2.changeRoute(widget.list[index]);
                                  if (value2.panelController.isPanelOpen) {
                                    await value2.panelController.close();
                                  }
                                  await value2.pageController.animateToPage(0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      curve: Curves.bounceIn);
                                  Polyline pl = Polyline(
                                      points: mr.polyline.points,
                                      borderColor: mr.polyline.borderColor,
                                      color: mr.polyline.color,
                                      borderStrokeWidth:
                                          mr.polyline.borderStrokeWidth,
                                      strokeWidth: mr.polyline.strokeWidth);
                                  value2.addPolyline(pl, mr.accentPolyline);
                                  await value.panelController
                                      .animatePanelToSnapPoint(
                                          duration: const Duration(
                                              milliseconds: 300));
                                },
                                child: const Text('Узнать больше'));
                          },
                        ),
                        Visibility(
                          visible: widget.delete != 0,
                          child: ElevatedButton(
                              onPressed: () async {
                                final res = await showDialog(
                                    context: context,
                                    builder: (context) => ConfirmDialog(
                                        opt: 'удалить \'${mr.name}\''));
                                if (res) {
                                  if (widget.delete == 1) {
                                    await DBService()
                                        .delete('map-routes/${mr.id}');
                                    widget.update();
                                  }
                                  if (widget.delete == 2) {
                                    final user =
                                        await AuthenticationService().my;
                                    user.saves.remove(mr.id);
                                    await DBService().setUser(user);
                                    widget.update();
                                  }
                                }
                              },
                              child: const Text('Удалить')),
                        ),
                        Visibility(
                          visible: widget.save,
                          child: ElevatedButton(
                              onPressed: () async {
                                final user = await AuthenticationService().my;
                                user.saves.add(mr.id);
                                await DBService().setUser(user);
                                widget.update();
                              },
                              child: const Text('Сохранить')),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
