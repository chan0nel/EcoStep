//import 'package:flutter/cupertino.dart';
import 'dart:math';

import 'package:diplom/classes.dart';
import 'package:diplom/store.dart';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as maps;
import 'package:yandex_geocoder/yandex_geocoder.dart' as geo;

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'EcoStep',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<MapRoute> list;
  List<maps.MapObject> mapObjects = [];
  bool route = false;
  bool newRoute = false;
  maps.Point p1 = const maps.Point(latitude: 0, longitude: 0);
  maps.Point p2 = const maps.Point(latitude: 0, longitude: 0);
  String text1 = "";
  String text2 = "";
  int s = -1;
  final geo.YandexGeocoder geocoder =
      geo.YandexGeocoder(apiKey: '49eef4cf-d91e-4cb0-9c7b-576ef4761aae');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Expanded(
            child: maps.YandexMap(
                mapObjects: mapObjects,
                onMapTap: (argument) async {
                  setState(
                    () {
                      if (s == 0) {
                        p1 = maps.Point(
                            latitude: argument.latitude,
                            longitude: argument.longitude);
                      } else {
                        if (s == 1) {
                          p2 = maps.Point(
                              latitude: argument.latitude,
                              longitude: argument.longitude);
                        }
                      }
                    },
                  );
                  if (s == 0) {
                    final geo.GeocodeResponse g =
                        await geocoder.getGeocode(geo.GeocodeRequest(
                      geocode: geo.PointGeocode(
                          latitude: p1.latitude, longitude: p1.longitude),
                    ));
                    setState(() {
                      text1 = g.firstFullAddress.formattedAddress ?? "";
                    });
                  } else if (s == 1) {
                    final geo.GeocodeResponse g =
                        await geocoder.getGeocode(geo.GeocodeRequest(
                      geocode: geo.PointGeocode(
                          latitude: p2.latitude, longitude: p2.longitude),
                    ));
                    setState(() {
                      text2 = g.firstFullAddress.formattedAddress ?? '';
                    });
                    print(text2);
                  }
                },
                onMapCreated: (controller) {
                  const start = maps.BoundingBox(
                      northEast: maps.Point(
                          latitude: 51.3195034857, longitude: 23.1994938494),
                      southWest: maps.Point(
                          latitude: 56.1691299506, longitude: 32.6936430193));
                  controller.moveCamera(maps.CameraUpdate.newBounds(start));
                })),
        route
            ? Expanded(
                child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: list.length,
                itemBuilder: (context, index) => ListTile(
                    title: Text(list[index].id.toString()),
                    onTap: () {
                      setState(() {
                        mapObjects.contains(list[index].getPolylineObj())
                            ? mapObjects.remove(list[index].getPolylineObj())
                            : mapObjects.add(list[index].getPolylineObj());
                      });
                    }),
              ))
            : const SizedBox.shrink(),
        newRoute
            ? Expanded(
                child: Column(children: [
                  Expanded(
                      child: Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            s = 0;
                          });
                        },
                        child: Text("1"),
                      )),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            s = 1;
                          });
                        },
                        child: Text("1"),
                      )),
                      Expanded(
                          child: TextButton(
                              onPressed: () async {
                                var a = await _requestRoutes(p1, p2);
                                setState(() {
                                  mapObjects = [];
                                  list = a;
                                  s = -1;
                                });
                              },
                              child: const Text("Найти"))),
                    ],
                  )),
                  list.isNotEmpty
                      ? Expanded(
                          flex: 3,
                          child: ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) => ListTile(
                                title: Text(list[index].id.toString()),
                                onTap: () {
                                  setState(() {
                                    mapObjects.contains(
                                            list[index].getPolylineObj())
                                        ? mapObjects.remove(
                                            list[index].getPolylineObj())
                                        : mapObjects
                                            .add(list[index].getPolylineObj());
                                  });
                                },
                                onLongPress: () {
                                  DatabaseService().add(el: list[index]);
                                  var sb = const SnackBar(
                                      content: Text("Сохранено"));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(sb);
                                }),
                          ))
                      : const SizedBox.shrink(),
                ]),
              )
            : const SizedBox.shrink(),
      ]),
      bottomSheet: BottomAppBar(
          child: Row(
        children: [
          Expanded(
              child: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      newRoute = !newRoute;
                      route = false;
                      list = [];
                      mapObjects = [];
                    });
                  })),
          Expanded(
              child: IconButton(
                  icon: const Icon(Icons.route),
                  onPressed: () async {
                    var a = await DatabaseService().getData();
                    setState(() {
                      route = !route;
                      newRoute = false;
                      mapObjects = [];
                      list = a;
                    });
                  })),
        ],
      )),
    );
  }

  Future<List<MapRoute>> _requestRoutes(maps.Point p1, maps.Point p2) async {
    List<MapRoute> mapObjects = [];

    var result = await maps.YandexBicycle.requestRoutes(
        bicycleVehicleType: maps.BicycleVehicleType.bicycle,
        points: [
          maps.RequestPoint(
              point: p1, requestPointType: maps.RequestPointType.wayPoint),
          maps.RequestPoint(
              point: p2, requestPointType: maps.RequestPointType.wayPoint),
        ]).result;
    print(result.routes!.length);
    result.routes!.asMap().forEach((i, route) {
      mapObjects.add(MapRoute.NewMapRoute(
          i,
          text1,
          text2,
          maps.Polyline(points: route.geometry),
          route.weight.distance.value ?? 0,
          route.weight.time.value ?? 0));
    });
    return mapObjects;
  }
}
