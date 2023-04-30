import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class RoutesList extends StatefulWidget {
  final Map<String, List<dynamic>> list;
  const RoutesList({super.key, required this.list});

  @override
  State<RoutesList> createState() => _RoutesListState();
}

class _RoutesListState extends State<RoutesList> {
  @override
  Widget build(BuildContext context) {
    int length = widget.list['public']!.length;
    if (length > 5) length = 5;
    return length != 0
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              semanticIndexOffset: 2,
              childCount: length,
              (context, index) {
                return ExpansionTile(
                  title: Text(widget.list['map']![index].name),
                  subtitle: Row(children: [
                    const Icon(Icons.timer),
                    Text(widget.list['map']![index].duration.toString()),
                    const Icon(Icons.straight),
                    Text(widget.list['map']![index].distance.toString()),
                  ]),
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
                            polylines: [widget.list['map']![index].polyline],
                          )
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          )
        : const SliverToBoxAdapter(
            child: Text('Нет маршрутов в данной категории'));
  }
}
