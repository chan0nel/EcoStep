// ignore_for_file: file_names
import 'package:diplom/database/map_route.dart';
import 'package:open_route_service/open_route_service.dart';

class MapService {
  final OpenRouteService _ors = OpenRouteService(
      apiKey: '5b3ce3597851110001cf624834db9092e45f491c90ae6a9920f89d57');

  Future<List<MapRoute>> getRoute({
    required ORSProfile profile,
    required List<ORSCoordinate> points,
    String preference = 'recommended',
  }) async {
    final routeJSON = await _ors.directionsMultiRouteGeoJsonPost(
      instructions: false,
      coordinates: points,
      alternativeRoutes: preference != 'recommended'
          ? {'target_count': 3, 'share_factor': 0.5, 'weight_factor': 1.5}
          : null,
      continueStraight: true,
      elevation: true,
      profileOverride: profile,
      preference: preference,
    );
    print(routeJSON.bbox);
    return routeJSON.features
        .map((e) => MapRoute.MapRoutefromORS(e, profile))
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
    return MapRoute.MapRoutefromORS(routeJSON.features[0], profile);
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
}
