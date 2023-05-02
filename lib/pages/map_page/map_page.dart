import 'package:diplom/pages/map_page/floating_buttons.dart';
import 'package:diplom/logic/providers.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;
  Polyline viewPolyline = Polyline(points: []);
  Map<String, dynamic> _tabs = {'tab': [], 'tab-view': []};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  void _updateTabs() {
    final mapmodel = Provider.of<MapModel>(context, listen: false);
    setState(() {
      _tabController =
          TabController(length: mapmodel.tabs['tab'].length, vsync: this);
      _tabs = mapmodel.tabs;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingButtons(upd: _updateTabs),
      body: Stack(
        children: [
          Consumer<MapModel>(
            builder: (context, value, child) => FlutterMap(
              mapController: value.mapController,
              options: MapOptions(
                center: LatLng(53.893009, 27.567444),
                onTap: (tapPosition, point) {
                  final idx = value.states['editPoint'];
                  if (idx != null) {
                    value.addPoint(point, idx);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.jawg.io/jawg-sunny/{z}/{x}/{y}.png?'
                      'access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM',
                ),
                PolylineLayer(
                  polylines: [...value.polylines, viewPolyline],
                ),
                MarkerLayer(
                  markers: value.markers,
                ),
              ],
            ),
          ),
          Consumer<MapModel>(
            builder: (context, value, child) => SlidingUpPanel(
              onPanelOpened: () async {
                await value.panelController.animatePanelToPosition(1);
                _updateTabs();
              },
              onPanelSlide: (position) {
                if (position == 0 && value.panelController.isPanelAnimating) {
                  value.panelController.close();
                }
              },
              onPanelClosed: () {
                setState(() {
                  viewPolyline = Polyline(points: []);
                });
                value.clearTabs();
                _updateTabs();
              },
              snapPoint: 0.3,
              controller: value.panelController,
              minHeight: 0,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              panelBuilder: (ScrollController sc) {
                value.scrollController = sc;
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black26,
                      ),
                    ),
                    TabBar(
                      //overlayColor: ,
                      onTap: (idx) {
                        if (idx > 0) {
                          setState(() {
                            viewPolyline = value.viewPolylines[idx - 1];
                          });
                        } else {
                          setState(() {
                            viewPolyline = Polyline(points: []);
                          });
                        }
                      },
                      controller: _tabController,
                      tabs: _tabs['tab'].cast<Widget>(),
                    ),
                    Expanded(
                      child: ExtendedTabBarView(
                        physics: const NeverScrollableClampingScrollPhysics(),
                        controller: _tabController,
                        children: _tabs['tab-view'].cast<Widget>(),
                        link: true,
                        cacheExtent: 4,
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
