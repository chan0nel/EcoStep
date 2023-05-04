import 'package:diplom/logic/map_service.dart';
import 'package:diplom/pages/map_page/add_route_tab_view.dart';
import 'package:diplom/logic/providers.dart';
import 'package:diplom/pages/routes_page/see_more.dart';
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
    with AutomaticKeepAliveClientMixin<MapPage>, TickerProviderStateMixin {
  late TabController _tabController;
  final PanelController _panelController = PanelController();
  Polyline viewPolyline = Polyline(points: []);
  Map<String, dynamic> _tabs = {'tab': [], 'tab-view': []};
  bool change = false;

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
      floatingActionButton: Consumer<MapModel>(
        builder: (context, value, child) {
          return _panelController.isPanelClosed &&
                  value.panelController.isPanelClosed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: FloatingActionButton(
                        onPressed: () async {
                          final pos = await MapService().determinePosition();
                          value.mapController
                              .move(LatLng(pos.latitude, pos.longitude), 15);
                        },
                        heroTag: null,
                        child: const Icon(Icons.my_location),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    FloatingActionButton(
                      onPressed: () async {
                        value.addTab('Составить маршрут',
                            AddRouteTabView(upd: _updateTabs));
                        _updateTabs();
                        await _panelController.open();
                      },
                      heroTag: null,
                      child: const Icon(Icons.add),
                    ),
                  ],
                )
              : const SizedBox.shrink();
        },
      ),
      body: Stack(
        children: [
          Consumer<MapModel>(
            builder: (context, value, child) => FlutterMap(
              mapController: value.mapController,
              options: MapOptions(
                keepAlive: true,
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
                  saveLayers: true,
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
                await _panelController.animatePanelToPosition(1);
                _updateTabs();
              },
              onPanelSlide: (position) {
                if (position == 0 && _panelController.isPanelAnimating) {
                  _panelController.close();
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
              controller: _panelController,
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
                        shouldIgnorePointerWhenScrolling: false,
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Consumer<MapModel>(
            builder: (context, value, child) => SlidingUpPanel(
                onPanelOpened: () async {
                  await value.panelController.animatePanelToPosition(1);
                },
                onPanelSlide: (position) {
                  if (position == 0 && value.panelController.isPanelAnimating) {
                    value.panelController.close();
                  }
                  if (position == 1.0 &&
                      !value.panelController.isPanelAnimating) {
                    setState(() {
                      change = true;
                    });
                  } else {
                    setState(() {
                      change = false;
                    });
                  }
                },
                onPanelClosed: () {
                  setState(() {
                    viewPolyline = Polyline(points: []);
                    change = false;
                  });
                  value.clearPolyline();
                },
                maxHeight: MediaQuery.of(context).size.height,
                snapPoint: 0.4,
                controller: value.panelController,
                minHeight: 0,
                borderRadius: !change
                    ? const BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      )
                    : null,
                panelBuilder: (sc) => SeeMorePanel(scrollController: sc)),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
