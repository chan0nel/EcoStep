import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  const CommentItem(
      {required this.title,
      required this.photo,
      required this.comment,
      super.key});

  final String title;
  final int photo;
  final String comment;

  @override
  Widget build(BuildContext context) {
    var borderRadius = const BorderRadius.only(
        topRight: Radius.circular(32), bottomRight: Radius.circular(32));
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      isThreeLine: true,
      leading: Image.asset(
        'images/photo ($photo).png',
        width: 45,
        height: 45,
      ),
      title: Text(title),
      subtitle: Text(comment),
    );
  }
}
