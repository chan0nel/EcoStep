// ignore_for_file: unused_import, use_build_context_synchronously

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/user.dart';
import 'package:diplom/logic/provider/list_provider.dart';
import 'package:diplom/logic/provider/map_provider.dart';
import 'package:diplom/logic/provider/theme_provider.dart';
import 'package:diplom/widgets/confirm_dialog.dart';
import 'package:diplom/widgets/info_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';

class RoutesList extends StatefulWidget {
  final String name;
  final bool save;
  final int delete;
  const RoutesList(
      {super.key, required this.name, this.save = false, this.delete = 0});

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ListModel>(
      builder: (context, value, child) {
        dynamic list = value.map[widget.name];
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            semanticIndexOffset: 2,
            childCount: list.length,
            (context, index) {
              MapRoute mr = list[index]['map'];
              User? user = list[index]['user'];
              List<Comment>? com = list[index]['comment'];
              return ExpansionTile(
                tilePadding:
                    user != null ? const EdgeInsets.only(right: 10) : null,
                leading: Visibility(
                  visible: user != null && !AuthenticationService().isAnonymous,
                  child: IconButton(
                      onPressed: () async {
                        if (AuthenticationService().isAnonymous ||
                            !AuthenticationService().isVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ваш аккаунт не верифицирован.')));
                          return;
                        }
                        if (mr.block.contains(AuthenticationService().uid)) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:
                                Text('Вы уже пожаловались на данный маршрут'),
                          ));
                        } else {
                          final res = await showDialog(
                            context: context,
                            builder: (context) => ConfirmDialog(
                                opt: 'пожаловаться на маршрут \'${mr.name}\''),
                          );
                          if (res) {
                            value.changeRoute(widget.name, index);
                            mr.block.add(AuthenticationService().uid);
                            await DBService().update('map-routes/${mr.id}', mr);
                            value.updateBlock('map');
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
                        if (AuthenticationService().isAnonymous ||
                            !AuthenticationService().isVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ваш аккаунт не верифицирован.')));
                          return;
                        }
                        ;
                        if (user!.block.contains(AuthenticationService().uid)) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Вы уже пожаловались на данного пользователя'),
                          ));
                        } else {
                          final res = await showDialog(
                            context: context,
                            builder: (context) => ConfirmDialog(
                                opt: 'пожаловаться на пользователя '
                                    '\'${user.name}\''),
                          );
                          if (res) {
                            value.changeRoute(widget.name, index);
                            user.block.add(AuthenticationService().uid);
                            await DBService().update('users/${user.uid}', user);
                            value.updateBlock('user');
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(right: 5),
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        child: Image.asset(
                          'images/photo (${list[index]['user']?.photo}).png',
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
                        if (AuthenticationService().isAnonymous ||
                            !AuthenticationService().isVerified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Ваш аккаунт не верифицирован.')));
                          return;
                        }
                        if (user!.block.contains(AuthenticationService().uid)) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Вы уже пожаловались на данного пользователя'),
                          ));
                        } else {
                          final res = await showDialog(
                            context: context,
                            builder: (context) => ConfirmDialog(
                                opt: 'пожаловаться на пользователя '
                                    '\'${user.name}\''),
                          );
                          if (res) {
                            value.changeRoute(widget.name, index);
                            user.block.add(AuthenticationService().uid);
                            await DBService().update('users/${user.uid}', user);
                            value.updateBlock('user');
                          }
                        }
                      },
                      child: Text(list[index]['user']?.name ?? ''),
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
                    padding: const EdgeInsets.fromLTRB(15, 5, 0, 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(
                          height: 190,
                          width: 180,
                          child: Consumer<ThemeProvider>(
                              builder: (context, value, child) => Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary
                                            .withAlpha(90)),
                                  ),
                                  child: FlutterMap(
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
                                  ))),
                        ),
                        Column(
                          children: [
                            SizedBox(
                                width: MediaQuery.of(context).size.width - 210,
                                child: Center(
                                  child: Wrap(
                                    spacing: 1.0,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      InfoChip(
                                        icon: Icons.height,
                                        text: mr.distanceCast,
                                        angle: 90,
                                      ),
                                      InfoChip(
                                          icon: Icons.timelapse,
                                          text: mr.timeCast),
                                      InfoChip(
                                          icon: Icons.straight,
                                          text: mr.ascent.toString()),
                                      InfoChip(
                                        icon: Icons.straight,
                                        text: mr.descent.toString(),
                                        angle: 180,
                                      ),
                                    ],
                                  ),
                                )),
                            Consumer2<ListModel, MapModel>(
                              builder: (context, value, value2, child) {
                                return ElevatedButton(
                                    onPressed: () async {
                                      value.changeRoute(widget.name, index);
                                      if (value2.panelController.isPanelOpen) {
                                        await value2.panelController.close();
                                      }
                                      Polyline pl = Polyline(
                                          points: mr.polyline.points,
                                          borderColor: mr.polyline.borderColor,
                                          color: mr.polyline.color,
                                          borderStrokeWidth:
                                              mr.polyline.borderStrokeWidth,
                                          strokeWidth: mr.polyline.strokeWidth);
                                      value2.addPolyline(pl, mr.accentPolyline);
                                      if (value.panelController.isPanelOpen) {
                                        await value.panelController.close();
                                      }
                                      await value2.pageController.animateToPage(
                                          0,
                                          duration:
                                              const Duration(milliseconds: 100),
                                          curve: Curves.bounceIn);
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
                                        value.refresh();
                                      }
                                      if (widget.delete == 2) {
                                        final user =
                                            await AuthenticationService().my;
                                        user.saves.remove(mr.id);
                                        await DBService().setUser(user);
                                        value.refresh();
                                      }
                                    }
                                  },
                                  child: const Text('Удалить')),
                            ),
                            Visibility(
                              visible: widget.save,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    final user =
                                        await AuthenticationService().my;
                                    user.saves.add(mr.id);
                                    await DBService().setUser(user);
                                    value.refresh();
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
      },
    );
  }
}
