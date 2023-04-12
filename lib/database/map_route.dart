import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

class MapRoute {
  late Polyline polyline;
  late List<double> atlitude;
  late double ascent;
  late double descent;
  late double distance;
  late double duration;
  late ORSProfile profile;

  // ignore: non_constant_identifier_names
  static MapRoute MapRoutefromORS(
      GeoJsonFeature geoJsonFeature, ORSProfile profile) {
    MapRoute mapRoute = MapRoute();
    mapRoute.profile = profile;
    mapRoute.ascent = geoJsonFeature.properties['ascent'];
    mapRoute.descent = geoJsonFeature.properties['descent'];
    mapRoute.distance = geoJsonFeature.properties['summary']['distance'];
    mapRoute.duration = geoJsonFeature.properties['summary']['duration'];
    mapRoute.atlitude = geoJsonFeature.geometry.coordinates
        .expand((e) => e)
        .map((el) => el.altitude ?? -1)
        .toList();
    final points = geoJsonFeature.geometry.coordinates
        .expand((e) => e)
        .map((el) => LatLng(el.latitude, el.longitude))
        .toList();
    mapRoute.polyline = Polyline(
      points: points,
      strokeWidth: 5,
      color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
      borderStrokeWidth: 1,
      borderColor: Colors.black45,
    );
    return mapRoute;
  }

  static MapRoute fromJSON(Map<String, dynamic> json) {
    MapRoute mapRoute = MapRoute();
    mapRoute.profile = ORSProfile.values[json['profile']];
    mapRoute.ascent = json['ascent'];
    mapRoute.descent = json['descent'];
    mapRoute.distance = json['distance'];
    mapRoute.duration = json['duration'];
    mapRoute.atlitude = List<double>.from(json['atlitude']);
    mapRoute.polyline = Polyline(
      points:
          List<LatLng>.from(json['polyline'].map((e) => LatLng.fromJson(e))),
      strokeWidth: 5,
      color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
      borderStrokeWidth: 1,
      borderColor: Colors.black45,
    );
    return mapRoute;
  }

  Map<String, dynamic> toJson() {
    return {
      'polyline': polyline.points.map((e) => e.toJson()).toList(),
      'atlitude': atlitude,
      'ascent': ascent,
      'descent': descent,
      'distance': distance,
      'duration': duration,
      'profile': profile.index,
    };
  }
}
