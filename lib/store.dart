import 'package:cloud_firestore/cloud_firestore.dart';

class Test {
  late String name;

  Map<String, dynamic> toJson() {
    return {
      'name': name
    };
  }
  factory Test.fromJson(Map<String, dynamic> data) {
    return Test(name: data['name'].toString());
  }
  Test({required this.name});
}

class DatabaseService {
  final collection = FirebaseFirestore.instance.collection("test");

  Future<List<Test>> getData() async {
    List<Test> listData = [];
    await collection.get().then((querySnapshot){
      for (var doc in querySnapshot.docs) {
        Test test = Test( // the first issue
          name: doc.data()['name']
        );
        listData.add(test); // the second issue
      }
    });
    return listData;
  }
}