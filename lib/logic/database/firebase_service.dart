import 'package:cloud_firestore/cloud_firestore.dart';

import 'map_route.dart';

class DBService {
  // ignore: prefer_final_fields
  late CollectionReference<Map<String, dynamic>> _collection;

  DBService(String collectionName)
      : _collection = FirebaseFirestore.instance.collection(collectionName);

  Future<List<MapRoute>> getRoutes() async {
    List<MapRoute> listData = [];
    try {
      await _collection.get().then((query) {
        listData = query.docs.map((e) => MapRoute.fromJSON(e.data())).toList();
      });
    } catch (ex) {
      // ignore: avoid_print
      print(ex);
    }
    return listData;
  }

  void saveRoute(MapRoute mapRoute, String name) async {
    try {
      _collection.add(mapRoute.toJson(name));
    } catch (ex) {
      // ignore: avoid_print
      print(ex);
    }
  }
}
