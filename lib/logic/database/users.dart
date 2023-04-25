class PublicRoute {
  late String uid;
  late String name;
  late String photo;

  PublicRoute();

  PublicRoute.fromJSON(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'photo': photo,
      };
}
