import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diplom/resources/class.dart';

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
        listData.add(MapRoute.fromJson(doc.reference.path, doc.data()));
      }
    });
    return listData;
  }

  void add({List<dynamic> list = const [], dynamic el}) {
    if (list.isNotEmpty) {
      for (var elem in list) {
        collection.add(elem.toJson());
      }
    } else {
      collection.add(el.toJson());
    }
  }

  void delete(String path) {
    collection.doc(path.replaceAll('test/', '')).delete();
  }
}
