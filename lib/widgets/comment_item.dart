import 'package:diplom/logic/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class CommentItem extends StatelessWidget {
  const CommentItem({
    required this.uid,
    required this.title,
    required this.photo,
    required this.comment,
    required this.date,
    required this.func1,
    required this.func2,
    super.key,
  });
  final String uid;
  final String title;
  final int photo;
  final DateTime date;
  final String comment;
  final Function func1;
  final Function func2;

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('ru');
    String temp = DateFormat('hh:mm').format(date);
    if (DateTime.now().difference(date).inHours >= 24) {
      temp = DateFormat('d MMM yyг.', 'ru').format(date);
    }
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 5),
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              func1();
            },
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            temp,
            style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black38
                    : Colors.white38),
          ),
        ],
      ),
      subtitle: Text(
        comment,
      ),
      trailing: Consumer<AuthenticationService>(
        builder: (context, value, child) {
          if (value.isAnonymous || value.uid == uid) {
            return const SizedBox.shrink();
          }
          return IconButton(
              onPressed: () {
                if (!value.isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Аккаунт не верифицирован')));
                  return;
                }
                func2();
              },
              icon: const Icon(Icons.block));
        },
      ),
    );
  }
}
