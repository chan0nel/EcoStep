class User {
  late String uid;
  late String name;
  late int photo;
  late List<String> saves;
  late List<String> block;

  User({
    this.uid = '',
    this.name = 'user',
    this.photo = 0,
    this.saves = const [],
    this.block = const [],
  });

  User.fromJSON(Map<String, dynamic> json, this.uid) {
    name = json['name'];
    photo = json['photo'];
    saves = List<String>.from(json['saves']);
    block = List<String>.from(json['block']);
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'photo': photo,
        'saves': saves,
        'block': block,
      };
}
