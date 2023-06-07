// ignore_for_file: avoid_print

class Comment {
  late String id;
  late String uid;
  late String routeid;
  late DateTime date;
  late String text;
  late List<String> block;

  Comment({
    this.id = '',
    required this.uid,
    required this.routeid,
    required this.text,
    DateTime? newDate,
    this.block = const [],
  }) : date = newDate ?? DateTime.now();

  Comment.fromJSON(Map<String, dynamic> json, this.id) {
    try {
      uid = json['uid'];
      routeid = json['routeid'];
      text = json['text'];
      date = DateTime.parse(json['date'].toDate().toString());
      block = List<String>.from(json['block']);
    } catch (e) {
      print('comment error: $e');
    }
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'routeid': routeid,
        'text': text,
        'date': date,
        'block': block,
      };
}
