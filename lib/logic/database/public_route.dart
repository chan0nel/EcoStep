class PublicRoute {
  late String uid;
  late String routeid;
  List<Map<String, dynamic>> comments = [];

  PublicRoute({
    required this.uid,
    required this.routeid,
  });

  PublicRoute.fromJSON(Map<String, dynamic> json) {
    uid = json['uid'];
    routeid = json['routeid'];
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'routeid': routeid,
        'comments': comments,
      };
}
