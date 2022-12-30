import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/classes.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class Test {
  late String name;

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  factory Test.fromJson(Map<String, dynamic> data) {
    return Test(name: data['name'].toString());
  }
  Test({required this.name});
}

class DatabaseService {
  final collection = FirebaseFirestore.instance.collection("test");

  Future<List<MapRoute>> getData() async {
    List<MapRoute> listData = [];
    await collection.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        try {
          var m = MapRoute(
              start: doc.data()["start"],
              end: doc.data()["end"],
              polyline: getLine(doc.data()["polyline"]["points"]),
              distance: doc.data()["distance"],
              id: doc.data()["id"],
              time: doc.data()["time"]);
          listData.add(m);
        } catch (e) {
          print(e);
        }
      }
    });
    listData.sort((a, b) => a.id.toString().compareTo(b.id.toString()));
    return listData;
  }

  Polyline getLine(var points) {
    return Polyline(
        points: List.from(points).map((e) {
      return Point(
          latitude: Map.from(e)["latitude"],
          longitude: Map.from(e)["longitude"]);
    }).toList());
  }

  void add({List<dynamic> list = const [], dynamic el}) {
    try {
      if (list.isNotEmpty) {
        for (var elem in list) {
          collection.add(elem.toJson());
        }
      } else {
        collection.add(el.toJson());
      }
    } catch (e) {
      print(e);
    }
  }
}
