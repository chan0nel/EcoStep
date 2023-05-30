// ignore_for_file: avoid_init_to_null

import 'package:async_button/async_button.dart';
import 'package:diplom/logic/list_provider.dart';
import 'package:diplom/logic/map_provider.dart';
import 'package:diplom/logic/map_service.dart';
import 'package:diplom/logic/theme_provider.dart';
import 'package:diplom/pages/map_page/add_route_tab_view.dart';
import 'package:diplom/pages/routes_page/see_more.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
  AsyncBtnStatesController asyncCtrl = AsyncBtnStatesController();
  late TabController _tabController;
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
      floatingActionButton: Consumer2<MapModel, ListModel>(
        builder: (context, value, value2, child) {
          return Visibility(
              visible: value.panelController.isPanelClosed &&
                  value2.panelController.isPanelClosed,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AsyncElevatedBtn(
                    asyncBtnStatesController: asyncCtrl,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(15, 55),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        shadowColor: Colors.black87,
                        elevation: 3),
                    loadingStyle: AsyncBtnStateStyle(
                        widget: SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).canvasColor,
                        strokeWidth: 2,
                      ),
                    )),
                    failureStyle: AsyncBtnStateStyle(
                        widget: Icon(
                      Icons.location_disabled,
                      color: Theme.of(context).colorScheme.surface,
                    )),
                    onPressed: () async {
                      asyncCtrl.update(AsyncBtnState.loading);
                      Position? pos = null;
                      try {
                        pos = await MapService().determinePosition();
                      } catch (ex) {
                        asyncCtrl.update(AsyncBtnState.failure);
                      }
                      if (pos != null) {
                        value.mapController
                            .move(LatLng(pos.latitude, pos.longitude), 17);
                        asyncCtrl.update(AsyncBtnState.idle);
                      }
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  FloatingActionButton(
                    onPressed: () async {
                      value.addTab('Составить маршрут',
                          AddRouteTabView(upd: _updateTabs));
                      _updateTabs();
                      await value.panelController.open();
                    },
                    heroTag: null,
                    child: const Icon(Icons.add),
                  ),
                ],
              ));
        },
      ),
      body: Stack(
        children: [
          Consumer2<MapModel, ThemeProvider>(
            builder: (context, value, value2, child) => FlutterMap(
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
                  urlTemplate: value2.curTheme
                      ? 'https://tile.jawg.io/jawg-sunny/{z}/{x}/{y}.png?'
                          'access-token=43LAhxnCITdWbjRocDbg5csEq5LaIYqxcn1TLZX2mSI0ngLlFmDmfR4Tq9UNTRaM'
                      : 'https://tile.jawg.io/jawg-dark/{z}/{x}/{y}.png?'
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
          Consumer2<MapModel, ThemeProvider>(
            builder: (context, value, value2, child) => SlidingUpPanel(
              color: !value2.curTheme
                  ? value2.theme.colorScheme.background
                  : Colors.white,
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
                  asyncCtrl = AsyncBtnStatesController();
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
                value.scrollController1 = sc;
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: value2.curTheme
                            ? value2.theme.colorScheme.background
                            : Colors.white,
                      ),
                    ),
                    TabBar(
                      physics: const NeverScrollableScrollPhysics(),
                      onTap: (idx) {
                        // if (_tabController.previousIndex == idx) {
                        //   _tabController.animateTo(idx);
                        // }
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
                        link: false,
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: _tabs['tab-view'].cast<Widget>(),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
          Consumer2<ListModel, ThemeProvider>(
            builder: (context, value, value2, child) => SlidingUpPanel(
                color: !value2.curTheme
                    ? value2.theme.colorScheme.background
                    : Colors.white,
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
                    asyncCtrl = AsyncBtnStatesController();
                    viewPolyline = Polyline(points: []);
                    change = false;
                  });
                  Provider.of<MapModel>(context, listen: false).clearPolyline();
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
