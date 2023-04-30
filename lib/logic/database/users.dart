class User {
  late String uid;
  late String name;
  late int photo;
  late List<String> saves;

  User({
    this.uid = '',
    this.name = 'user',
    this.photo = 0,
    this.saves = const [],
  });

  User.fromJSON(Map<String, dynamic> json, String id) {
    uid = id;
    name = json['name'];
    photo = json['photo'];
    saves = List<String>.from(json['saves']);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'photo': photo,
        'saves': saves,
      };
}
