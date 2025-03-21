// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

class MapRoute {
  late String id;
  late String uid;
  late String name;
  late Polyline polyline;
  late List<double> atlitude;
  late double ascent;
  late double descent;
  late double distance;
  late double duration;
  late int inxProfile;
  late List<String> block;

  LatLngBounds get bbox => LatLngBounds.fromPoints(polyline.points);
  String get profile => [
        'Обычный велосипед',
        'Электрический велосипед',
        'Горный велосипед',
        'Прогулка',
        'Туризм',
        'Инвалидная коляска',
      ][inxProfile];

  String get distanceCast => distance / 1000 < 1
      ? '${distance.toStringAsFixed(0)} м'
      : '${(distance / 1000).toStringAsFixed(1)} км';

  String get timeCast {
    final temp = Duration(seconds: (duration).round());
    String hour = temp.inHours == 0 ? '' : '${temp.inHours} ч ';
    String min = temp.inMinutes == 0
        ? ''
        : '${(temp.inMinutes / (temp.inHours != 0 ? (60 * temp.inHours) : 1)).toStringAsFixed(0)} мин ';
    String sec = temp.inSeconds == 0
        ? ''
        : '${(temp.inSeconds / (temp.inMinutes != 0 ? (60 * temp.inMinutes) : 1)).toStringAsFixed(0)} с';
    return '$hour$min$sec';
  }

  Polyline get accentPolyline => Polyline(
        points: polyline.points,
        strokeWidth: 5,
        color: const Color.fromARGB(255, 255, 136, 0),
        borderStrokeWidth: 5,
        borderColor: Colors.black26,
      );

  MapRoute();

  MapRoute.fromORS(GeoJsonFeature geoJsonFeature, this.inxProfile) {
    ascent = geoJsonFeature.properties['ascent'];
    descent = geoJsonFeature.properties['descent'];
    distance = geoJsonFeature.properties['summary']['distance'];
    duration = geoJsonFeature.properties['summary']['duration'];
    atlitude = geoJsonFeature.geometry.coordinates
        .expand((e) => e)
        .map((el) => el.altitude ?? -1)
        .toList();
    final points = geoJsonFeature.geometry.coordinates
        .expand((e) => e)
        .map((el) => LatLng(el.latitude, el.longitude))
        .toList();
    polyline = Polyline(
      points: points,
      strokeWidth: 5,
      color: const Color.fromARGB(255, 255, 208, 0),
      borderStrokeWidth: 3,
      borderColor: Colors.black45,
    );
    uid = '';
    block = [];
  }

  MapRoute.fromJSON(Map<String, dynamic> json, this.id) {
    try {
      uid = json['uid'];
      name = json['name'];
      inxProfile = json['inxProfile'];
      ascent = json['ascent'];
      descent = json['descent'];
      distance = json['distance'];
      duration = json['duration'];
      atlitude = List<double>.from(json['atlitude']);
      polyline = Polyline(
        points:
            List<LatLng>.from(json['polyline'].map((e) => LatLng.fromJson(e))),
        strokeWidth: 5,
        color: const Color.fromARGB(255, 255, 208, 0),
        borderStrokeWidth: 3,
        borderColor: Colors.black45,
      );
      block = List<String>.from(json['block']);
    } catch (e) {
      print('map error: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'polyline': polyline.points.map((e) => e.toJson()).toList(),
        'atlitude': atlitude,
        'ascent': ascent,
        'descent': descent,
        'distance': distance,
        'duration': duration,
        'inxProfile': inxProfile,
        'block': block,
      };
}
