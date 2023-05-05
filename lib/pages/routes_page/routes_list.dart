import 'dart:async';

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/providers.dart';
import 'package:diplom/logic/theme_provider.dart';
import 'package:diplom/pages/map_page/route_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';

class RoutesList extends StatefulWidget {
  final Map<String, List<dynamic>> list;
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
    int length = widget.list['public']!.length;
    //if (length > 5 && widget.minimal) length = 5;
    return length != 0
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              semanticIndexOffset: 2,
              childCount: length,
              (context, index) {
                return ExpansionTile(
                  // leading: IconButton(
                  //     onPressed: () {}, icon: const Icon(Icons.info_outline)),
                  title: Text(widget.list['map']![index].name),
                  subtitle: Row(children: [
                    widget.list['user'] != null
                        ? Container(
                            padding: const EdgeInsets.only(right: 5),
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            child: Image.asset(
                              'images/photo (${widget.list['user']![index].photo}).png',
                              width: 35,
                              height: 35,
                            ),
                          )
                        : const SizedBox.shrink(),
                    widget.list['user'] != null
                        ? Text(widget.list['user']![index].name)
                        : const SizedBox.shrink(),
                    widget.list['user'] != null
                        ? const Spacer(flex: 10)
                        : const SizedBox.shrink(),
                    const Icon(Icons.comment_outlined),
                    const SizedBox(width: 5),
                    Text(widget.list['public']![index].comments.length
                        .toString())
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
                                    bounds: widget.list['map']![index].bbox,
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
                                    polylines: [
                                      widget.list['map']![index].polyline
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'Протяженность: '
                                '${widget.list['map']![index].distanceCast}',
                                maxLines: 2,
                              ),
                              Text(
                                'Длительность: '
                                '${widget.list['map']![index].timeCast}',
                                maxLines: 2,
                              ),
                              Text(
                                'Подъем: '
                                '${widget.list['map']![index].ascent.toString()}',
                                maxLines: 2,
                              ),
                              Text(
                                'Спуск: '
                                '${widget.list['map']![index].descent.toString()}',
                                maxLines: 2,
                              ),
                              Consumer<MapModel>(
                                builder: (context, value, child) {
                                  return ElevatedButton(
                                      onPressed: () async {
                                        if (value.panelController.isPanelOpen) {
                                          await value.panelController.close();
                                        }
                                        value.changeRoute({
                                          'public':
                                              widget.list['public']![index],
                                          'map': widget.list['map']![index],
                                        });
                                        value.addPolyline(
                                            widget.list['map']![index].polyline,
                                            widget.list['map']![index]
                                                .accentPolyline);
                                        value.mapController.move(
                                            widget.list['map']![index].bbox
                                                .center,
                                            13);
                                        await value.panelController.open();
                                        await value.panelController
                                            .animatePanelToSnapPoint(
                                                duration: const Duration(
                                                    milliseconds: 100));
                                        await value.pageController
                                            .animateToPage(0,
                                                duration: const Duration(
                                                    milliseconds: 100),
                                                curve: Curves.bounceIn);
                                      },
                                      child: const Text('Узнать больше'));
                                },
                              ),
                              widget.delete != 0
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        if (widget.delete == 1) {
                                          await DBService().delete(
                                              'map-routes/${widget.list['map']![index].id}');
                                          await DBService().delete(
                                              'public-routes/${widget.list['public']![index].routeid}');
                                          widget.update();
                                        }
                                        if (widget.delete == 2) {
                                          final user =
                                              await AuthenticationService().my;
                                          user.saves.remove(
                                              widget.list['map']![index].id);
                                          await DBService().setUser(user);
                                          widget.update();
                                        }
                                      },
                                      child: const Text('Удалить'))
                                  : const SizedBox.shrink(),
                              widget.save
                                  ? ElevatedButton(
                                      onPressed: () async {
                                        final user =
                                            await AuthenticationService().my;
                                        user.saves
                                            .add(widget.list['map']![index].id);
                                        await DBService().setUser(user);
                                        widget.update();
                                      },
                                      child: const Text('Сохранить'))
                                  : const SizedBox.shrink()
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        : const SliverToBoxAdapter(
            child: Text('Нет маршрутов в данной категории'));
  }
}
