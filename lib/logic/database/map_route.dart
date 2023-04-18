import 'dart:math';

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
  MapRoute.MapRoutefromORS(GeoJsonFeature geoJsonFeature, this.profile) {
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
      color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
      borderStrokeWidth: 1,
      borderColor: Colors.black45,
    );
  }

  MapRoute.fromJSON(Map<String, dynamic> json) {
    profile = ORSProfile.values[json['profile']];
    ascent = json['ascent'];
    descent = json['descent'];
    distance = json['distance'];
    duration = json['duration'];
    atlitude = List<double>.from(json['atlitude']);
    polyline = Polyline(
      points:
          List<LatLng>.from(json['polyline'].map((e) => LatLng.fromJson(e))),
      strokeWidth: 5,
      color: Color(Random().nextInt(0xffffffff)).withAlpha(0xff),
      borderStrokeWidth: 1,
      borderColor: Colors.black45,
    );
  }

  Map<String, dynamic> toJson() => {
        'polyline': polyline.points.map((e) => e.toJson()).toList(),
        'atlitude': atlitude,
        'ascent': ascent,
        'descent': descent,
        'distance': distance,
        'duration': duration,
        'profile': profile.index,
      };
}
