import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapRoute {
  final String id;
  final String start;
  final String end;
  final Polyline polyline;
  final double distance;
  final double time;
  final Color strokeColor =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  MapRoute(
      {this.id = "",
      this.start = "",
      this.end = "",
      this.polyline = const Polyline(points: []),
      this.distance = 0,
      this.time = 0});

  static MapRoute NewMapRoute(int id, String start, String end,
      Polyline polyline, double distance, double time) {
    start = start.split(", ").sublist(2).join(", ");
    end = end.split(", ").sublist(2).join(", ");
    return MapRoute(
        id: "${start}_${end}_$id",
        start: start,
        end: end,
        distance: distance,
        polyline: polyline,
        time: time);
  }

  PolylineMapObject getPolylineObj() {
    return PolylineMapObject(
        mapId: MapObjectId(id),
        polyline: polyline,
        strokeColor: strokeColor,
        strokeWidth: 2,
        onTap: ((mapObject, point) => {print(this.toJson())}));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start': start,
      'end': end,
      'distance': distance,
      'time': time,
      'polyline': polyline.toJson(),
    };
  }

  // static MapRoute StoreMapRoute(String id, String start, String end,
  //     MapObject polyline, double distance, DateTime time) {
  //   MapRoute m = MapRoute();
  //   m.id = id;
  //   m.start = m.start;
  // }
}
