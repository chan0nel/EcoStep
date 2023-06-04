// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/user.dart';

import 'map_route.dart';

class DBService {
  final _instance = FirebaseFirestore.instance;

  Future<List<dynamic>> get(String collection) async {
    List<dynamic> listData = [];
    try {
      String uid = AuthenticationService().isAnonymous
          ? ''
          : AuthenticationService().uid;
      await _instance.collection(collection).get().then((query) {
        listData = query.docs
            .map((e) {
              bool a = e.data()['block'].length >= 5;
              switch (collection) {
                case 'comments':
                  if (a) {
                    if (e.data()['uid'] != uid) break;
                  }
                  return Comment.fromJSON(e.data(), e.id);
                case 'map-routes':
                  if (a) {
                    if (e.data()['uid'] != uid) break;
                  }
                  return MapRoute.fromJSON(e.data(), e.id);
                case 'users':
                  if (a) {
                    print(e.data()['uid'] != uid);
                    if (e.id != uid) break;
                  }
                  return User.fromJSON(e.data(), e.id);
              }
            })
            .where((element) => element != null)
            .toList();
      });
    } catch (ex) {
      print('GET ERROR $ex');
    }
    return listData;
  }

  Future<bool> setUser(User us) async {
    try {
      await _instance.doc('users/${us.uid}').set(us.toJson());
      return true;
    } catch (ex) {
      print('SET USER ERROR $ex');
      return false;
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
      print(ex);
    }
    return us;
  }

  Future<bool> update(String collection, obj) async {
    try {
      await _instance.doc(collection).update({'block': obj.block});
      return true;
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  Future<bool> saveComment({required Comment obj, String id = ''}) async {
    try {
      if (id != '') {
        await _instance.doc('comments/$id').set(obj.toJson());
      } else {
        await _instance.collection('comments').add(obj.toJson());
      }

      return true;
    } catch (ex) {
      print(ex);
      return false;
    }
  }

  Future<bool> saveMapRoutes(obj) async {
    try {
      await FirebaseFirestore.instance
          .collection('map-routes')
          .add(obj.toJson());
      return true;
    } catch (ex) {
      return false;
    }
  }

  Future<bool> delete(ref) async {
    try {
      await FirebaseFirestore.instance.doc(ref).delete();
      return true;
    } catch (ex) {
      print(ex);
      return false;
    }
  }
}
