// ignore_for_file: unused_import

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/user.dart';
import 'package:diplom/logic/map-provider.dart';
import 'package:diplom/logic/theme_provider.dart';
import 'package:diplom/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';

class RoutesList extends StatefulWidget {
  final List<dynamic> list;
  //final bool minimal;
  final bool save;
  final int delete;
  final Function update;
  const RoutesList(
      {super.key,
      required this.list,
      //this.minimal = true,
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
            // leading: IconButton(
            //     onPressed: () {}, icon: const Icon(Icons.info_outline)),
            title: Text(mr.name),
            subtitle: Row(children: [
              Visibility(
                visible: user != null,
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
              Visibility(
                visible: user != null,
                child: Text(widget.list[index]['user']?.name ?? ''),
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
                              keepAlive: true,
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
                              saveLayers: true,
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
                        Consumer<MapModel>(
                          builder: (context, value, child) {
                            return ElevatedButton(
                                onPressed: () async {
                                  value.changeRoute(widget.list[index]);
                                  value.addPolyline(
                                      mr.polyline, mr.accentPolyline);
                                  await value.panelController.open();
                                  await value.panelController
                                      .animatePanelToSnapPoint(
                                          duration: const Duration(
                                              milliseconds: 100));
                                  await value.pageController.animateToPage(0,
                                      duration:
                                          const Duration(milliseconds: 100),
                                      curve: Curves.bounceIn);
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
