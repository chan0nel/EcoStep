class Comment {
  late String id;
  late String uid;
  late String routeid;
  late String text;
  late List<String> block;

  Comment({
    this.id = '',
    required this.uid,
    required this.routeid,
    required this.text,
    this.block = const [],
  });

  Comment.fromJSON(Map<String, dynamic> json, this.id) {
    try {
      uid = json['uid'];
      routeid = json['routeid'];
      text = json['text'];
      block = List<String>.from(json['block']);
    } catch (e) {
      print('comment error: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'routeid': routeid,
        'text': text,
        'block': block,
      };
}
