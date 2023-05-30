// ignore_for_file: file_names, avoid_print
import 'dart:convert';

import 'package:diplom/logic/database/map_route.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

class MapService {
  final List<ORSProfile> _profile = [
    ORSProfile.cyclingRoad,
    ORSProfile.cyclingElectric,
    ORSProfile.cyclingMountain,
    ORSProfile.footWalking,
    ORSProfile.footHiking,
    ORSProfile.wheelchair
  ];
  final OpenRouteService _ors = OpenRouteService(
      apiKey: '5b3ce3597851110001cf624834db9092e45f491c90ae6a9920f89d57');

  Future<List<MapRoute>> getRoute({
    required int profile,
    required List<ORSCoordinate> points,
    int preference = 0,
    bool alt = false,
  }) async {
    try {
      print('profile: $profile');
      String temp = preference == 0 ? 'recommended' : 'shortest';
      final routeJSON = await _ors.directionsMultiRouteGeoJsonPost(
        language: 'ru',
        instructions: false,
        coordinates: points,
        alternativeRoutes: alt
            ? {'target_count': 2, 'share_factor': 0.5, 'weight_factor': 1.5}
            : null,
        continueStraight: true,
        elevation: true,
        profileOverride: _profile[profile],
        preference: temp,
      );
      return routeJSON.features
          .map((e) => MapRoute.fromORS(e, profile))
          .toList();
    } catch (e) {
      print('OSR ERROR1: $e');
      return [];
    }
  }

  Future<MapRoute> getRoundedRoute({
    required int profile,
    required List<ORSCoordinate> points,
    int length = 2,
  }) async {
    try {
      final routeJSON = await _ors.directionsMultiRouteGeoJsonPost(
          coordinates: points,
          instructions: false,
          options: {
            'round_trip': {
              'length': length * 2500,
              'points': 10 * length,
              'seed': DateTime.now().microsecondsSinceEpoch / 1000,
            }
          },
          elevation: true,
          profileOverride: _profile[profile]);
      return MapRoute.fromORS(routeJSON.features[0], profile);
    } catch (e) {
      print('OSR ERROR2: $e');
      return MapRoute();
    }
  }

  Future<String> reverseSearch(
    LatLng point,
  ) async {
    try {
      final url = Uri.https('api.openrouteservice.org', '/geocode/reverse', {
        'api_key': '5b3ce3597851110001cf624834db9092e45f491c90ae6a9920f89d57',
        'point.lon': point.longitude.toString(),
        'point.lat': point.latitude.toString(),
        'size': '1',
        'layers': 'venue,neighbourhood',
        'lang': 'ru',
      });
      final response = await http.get(url);
      final searchPoint =
          jsonDecode(response.body)['features'][0]['properties'];
      return searchPoint['label']
          .split(', ')
          .map((e) => e == 'Белоруссия' ? 'Беларусь' : e)
          .join(', ');
    } catch (e) {
      print('OSR ERROR3: $e');
      return '';
    }
  }

  Future<Map<String, dynamic>> search(
    String text,
  ) async {
    try {
      final url =
          Uri.https('api.openrouteservice.org', '/geocode/autocomplete', {
        'api_key': '5b3ce3597851110001cf624834db9092e45f491c90ae6a9920f89d57',
        'text': text,
        'layers': 'venue,neighbourhood',
        'lang': 'ru',
      });
      final response = await http.get(url);
      final searchPoints = List.from(jsonDecode(response.body)['features']);
      return {
        for (var v in searchPoints)
          '${v['properties']['name']}, ${v['properties']['country'] == 'Белоруссия' ? 'Беларусь' : v['properties']['country']}':
              LatLng(v['geometry']['coordinates'][1],
                  v['geometry']['coordinates'][0])
      };
    } catch (e) {
      print('OSR ERROR4: $e');
      return {};
    }
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
