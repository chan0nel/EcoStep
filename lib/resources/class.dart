import 'dart:math';
import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class MapRoute {
  final String path;
  final String id;
  final String start;
  final String end;
  final Polyline polyline;
  final double distance;
  final double time;
  final Color strokeColor =
      Colors.primaries[Random().nextInt(Colors.primaries.length)];

  MapRoute(
      {this.path = "",
      this.id = "",
      this.start = "",
      this.end = "",
      this.polyline = const Polyline(points: []),
      this.distance = 0,
      this.time = 0});

  static MapRoute newMapRoute(String id, String start, String end,
      Polyline polyline, double distance, double time) {
    start = start.split(", ").sublist(1).join(", ");
    end = end.split(", ").sublist(1).join(", ");
    return MapRoute(
        id: "${start}_${end}_$id",
        start: start,
        end: end,
        distance: distance,
        polyline: polyline,
        time: time);
  }

  String getRange() {
    return distance > 1000
        ? "${(distance / 1000).toStringAsFixed(1)} км"
        : "$distance м";
  }

  String getTime() {
    return time > 3600
        ? "${(time / 60 / 60).floor()} ч ${(time / 60 % 60).ceil()} мин"
        : "${(time / 60).ceil()} мин";
  }

  String getStartPoint() {
    return "${(polyline.points.first.latitude).toStringAsFixed(2)}, ${(polyline.points.first.longitude).toStringAsFixed(2)}";
  }

  String getEndPoint() {
    return "${(polyline.points.last.latitude).toStringAsFixed(2)}, ${(polyline.points.last.longitude).toStringAsFixed(2)}";
  }

  PolylineMapObject getPolylineObj() {
    return PolylineMapObject(
      mapId: MapObjectId(id),
      polyline: polyline,
      strokeColor: strokeColor,
      strokeWidth: 2,
      outlineWidth: 1,
      outlineColor: Colors.black54,
      onTap: (mapObject, point) {},
    );
  }

  static Polyline getLine(var points) {
    return Polyline(
        points: List.from(points).map((e) {
      return Point(
          latitude: Map.from(e)["latitude"],
          longitude: Map.from(e)["longitude"]);
    }).toList());
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

  static MapRoute fromJson(String path, Map<String, dynamic> json) {
    return MapRoute(
      path: path,
      id: json["id"],
      start: json["start"],
      end: json["end"],
      polyline: getLine(json["polyline"]["points"]),
      distance: json["distance"],
      time: json["time"],
    );
  }

  @override
  String toString() {
    return 'Точка старта: $start (${getStartPoint()})\n'
        'Точка конца: $end (${getEndPoint()})\n'
        'Дистанция: ${getRange()}\n'
        'Время на маршрут: ${getTime()}';
  }
}
