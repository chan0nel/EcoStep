class User {
  late String uid;
  late String name;
  late String photo;
  late List<String> saves;

  User();

  User.fromJSON(Map<String, dynamic> json, String id) {
    uid = id;
    name = json['name'];
    photo = json['photo'];
    saves = json['saves'].cast<String>();
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'photo': photo,
        'saves': saves,
      };
}
