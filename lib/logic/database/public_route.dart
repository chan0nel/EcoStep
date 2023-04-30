class PublicRoute {
  late String uid;
  late String routeid;
  List<dynamic> comments = [];

  PublicRoute({required this.uid, this.routeid = '', this.comments = const []});

  PublicRoute.fromJSON(Map<String, dynamic> json, String id) {
    uid = json['uid'];
    routeid = id;
    comments = List<dynamic>.from(json['comments']);
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'comments': comments,
      };
}
