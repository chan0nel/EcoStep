// ignore_for_file: file_names
import 'package:diplom/logic/database/map_route.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:geolocator/geolocator.dart';

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
  }) async {
    String temp = preference == 0 ? 'recommended' : 'shortest';
    final routeJSON = await _ors.directionsMultiRouteGeoJsonPost(
      instructions: false,
      coordinates: points,
      alternativeRoutes: preference != 0 && points.length < 3
          ? {'target_count': 3, 'share_factor': 0.5, 'weight_factor': 1.5}
          : null,
      continueStraight: true,
      elevation: true,
      profileOverride: _profile[profile],
      preference: temp,
    );
    return routeJSON.features
        .map((e) => MapRoute.fromORS(e, _profile[profile]))
        .toList();
  }

  Future<MapRoute> getRoundedRoute({
    required ORSProfile profile,
    required List<ORSCoordinate> points,
    int length = 2000,
    int pointsNum = 10,
  }) async {
    final routeJSON = await _ors.directionsMultiRouteGeoJsonPost(
        coordinates: points,
        instructions: false,
        options: {
          'round_trip': {
            'length': length,
            'points': pointsNum,
            'seed': DateTime.now().microsecondsSinceEpoch / 1000,
          }
        },
        elevation: true,
        profileOverride: profile);
    return MapRoute.fromORS(routeJSON.features[0], profile);
  }

  Future<List<Map<String, dynamic>>> search({required text}) async {
    final searchPoints = await _ors.geocodeAutoCompleteGet(text: text);
    return searchPoints.features
        .map((e) => {
              'label': e.properties['label'],
              'point': e.geometry.coordinates,
            })
        .toList();
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
