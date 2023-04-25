class PublicRoute {
  late String uid;
  late String routeid;
  late DateTime date;
  late List<Map<String, dynamic>> comments;

  PublicRoute();

  PublicRoute.fromJSON(Map<String, dynamic> json) {
    date = json['date'];
    uid = json['uid'];
    routeid = json['routeid'];
    comments = json['comments'];
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'uid': uid,
        'routeid': routeid,
        'comments': comments,
      };
}
