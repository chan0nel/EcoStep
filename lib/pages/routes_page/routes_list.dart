import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class RoutesList extends StatefulWidget {
  final Map<String, List<dynamic>> list;
  final bool minimal;
  final bool save;
  const RoutesList(
      {super.key, required this.list, this.minimal = true, this.save = false});

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  @override
  Widget build(BuildContext context) {
    int length = widget.list['public']!.length;
    if (length > 5 && widget.minimal) length = 5;
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
                            child: FlutterMap(
                              options: MapOptions(
                                  interactiveFlags: InteractiveFlag.none,
                                  bounds: widget.list['map']![index].bbox,
                                  boundsOptions: const FitBoundsOptions(
                                      padding: EdgeInsets.all(30))),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://tile.jawg.io/jawg-sunny/{z}/{x}/{y}.png?'
                                      'access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM',
                                ),
                                PolylineLayer(
                                  polylines: [
                                    widget.list['map']![index].polyline
                                  ],
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Text('Протяженность: '
                                  '${widget.list['map']![index].distanceCast}'),
                              Text('Длительность: '
                                  '${widget.list['map']![index].timeCast}'),
                              Text('Подъем: '
                                  '${widget.list['map']![index].ascent.toString()}'),
                              Text('Спуск: '
                                  '${widget.list['map']![index].descent.toString()}'),
                              widget.save
                                  ? ElevatedButton(
                                      onPressed: () {},
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
