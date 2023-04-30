class PublicRoute {
  late String uid;
  late String routeid;
  List<dynamic> comments = [];

  PublicRoute({
    required this.uid,
    required this.routeid,
  });

  PublicRoute.fromJSON(Map<String, dynamic> json, String id) {
    uid = json['uid'];
    routeid = id;
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'comments': comments,
      };
}
