class Comment {
  late String id;
  late String uid;
  late String routeid;
  late String text;
  late List<String> block;

  Comment({
    required this.id,
    required this.uid,
    required this.routeid,
    required this.text,
  });

  Comment.fromJSON(Map<String, dynamic> json, this.id) {
    uid = json['uid'];
    text = json['text'];
    block = List<String>.from(json['block']);
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'routeid': routeid,
        'text': text,
        'block': block,
      };
}
