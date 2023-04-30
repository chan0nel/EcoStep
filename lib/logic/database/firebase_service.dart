import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/logic/database/public_route.dart';
import 'package:diplom/logic/database/users.dart';

import 'map_route.dart';

class DBService {
  final _instance = FirebaseFirestore.instance;

  Future<List<dynamic>> get(String collection) async {
    List<dynamic> listData = [];
    try {
      await _instance.collection(collection).get().then((query) {
        listData = query.docs.map((e) {
          switch (collection) {
            case 'public-routes':
              return PublicRoute.fromJSON(e.data(), e.id);
            case 'map-routes':
              return MapRoute.fromJSON(e.data(), e.id);
            case 'users':
              return User.fromJSON(e.data(), e.id);
          }
        }).toList();
      });
    } catch (ex) {
      // ignore: avoid_print
      print('GET ERROR $ex');
    }
    return listData;
  }

  Future<void> setUser(User us) async {
    try {
      await _instance.doc('users/${us.uid}').set(us.toJson());
    } catch (ex) {
      // ignore: avoid_print
      print('SET USER ERROR $ex');
    }
  }

  Future<User> getUser(String uid) async {
    User us = User();
    try {
      await _instance.doc('users/$uid').get().then((query) {
        if (query.data() == null) {
          throw Exception();
        } else {
          us = User.fromJSON(query.data() ?? {}, uid);
        }
      });
    } catch (ex) {
      // ignore: avoid_print
      print(ex);
    }
    return us;
  }

  Future<String> savePublicRoute(obj, String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('public-routes')
          .doc(id)
          .set(obj.toJson());
      return id;
    } catch (ex) {
      return ex.toString();
    }
  }

  Future<String> saveMapRoutes(obj) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('map-routes')
          .add(obj.toJson());
      return doc.id;
    } catch (ex) {
      return ex.toString();
    }
  }
}
