import 'package:flutter/material.dart';

class CommentItem extends StatelessWidget {
  const CommentItem(
      {required this.title,
      required this.photo,
      required this.comment,
      required this.func1,
      required this.func2,
      super.key});

  final String title;
  final int photo;
  final String comment;
  final Function func1;
  final Function func2;

  @override
  Widget build(BuildContext context) {
    var borderRadius = const BorderRadius.only(
        topRight: Radius.circular(32), bottomRight: Radius.circular(32));
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      isThreeLine: true,
      leading: GestureDetector(
        onTap: () {
          func1();
        },
        child: Image.asset(
          'images/photo ($photo).png',
          width: 45,
          height: 45,
        ),
      ),
      title: GestureDetector(
        onTap: () {
          func1();
        },
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
      subtitle: Text(
        comment,
      ),
      trailing: IconButton(
          onPressed: () {
            func2();
          },
          icon: const Icon(Icons.block)),
    );
  }
}
