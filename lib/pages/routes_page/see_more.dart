// ignore_for_file: unused_import, unused_field, unused_local_variable

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/user.dart';
import 'package:diplom/logic/map-provider.dart';
import 'package:diplom/widgets/atlitude_chart.dart';
import 'package:diplom/widgets/comment_item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeMorePanel extends StatefulWidget {
  final ScrollController scrollController;
  const SeeMorePanel({super.key, required this.scrollController});

  @override
  State<SeeMorePanel> createState() => _SeeMorePanelState();
}

class _SeeMorePanelState extends State<SeeMorePanel> {
  TextEditingController ctrl = TextEditingController();
  late Future<List<dynamic>> _getUser;
  Future<List<dynamic>> getUsers() async {
    return DBService().get('users');
  }

  @override
  void initState() {
    _getUser = getUsers();
    super.initState();
  }

  Future<void> _submit(String routeid, List<Comment> com) async {
    if (ctrl.text.trim() != '') {
      final c = Comment(
          uid: Provider.of<AuthenticationService>(context, listen: false).uid,
          routeid: routeid,
          text: ctrl.text);
      setState(() {
        com.add(c);
      });
      await DBService().saveComment(obj: c);
      ctrl.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<MapModel, AuthenticationService>(
      builder: (context, value, value2, child) {
        if (value.route['map'] == null) {
          return const SizedBox.shrink();
        }
        MapRoute mr = value.route['map'] ?? MapRoute();
        User? user = value.route['user'];
        List<Comment> com = value.route['comment'].cast<Comment>();
        return ListView(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 100),
          controller: widget.scrollController,
          children: [
            UnconstrainedBox(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black26,
                ),
              ),
            ),
            const Text('Название:'),
            Text(mr.name),
            Text('Тип передвижения: ${mr.profile}'),
            Text('Протяженность: ${mr.distanceCast}'),
            Text('Время прохождения: ${mr.timeCast}'),
            const Text('График высот:'),
            AtlitudeChart(
              data: mr.atlitude,
              distance: mr.distance,
            ),
            Text('Подъем: ${mr.ascent}'),
            Text('Спуск: ${mr.descent}'),
            const Divider(),
            const Text('Комментарии:'),
            FutureBuilder(
              future: _getUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  List<dynamic> users = [];
                  for (var element in com) {
                    for (var elem in snapshot.data!) {
                      if (element.uid == elem.uid) {
                        users.add([elem, element]);
                      }
                    }
                  }
                  if (users.isEmpty) {
                    final theme = Theme.of(context);
                    return SizedBox(
                      height: 50,
                      child: Center(
                          child: Text(
                        'Комментариев пока нет. Будьте первым!',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.brightness == Brightness.light
                              ? theme.disabledColor
                              : theme.splashColor,
                        ),
                      )),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      return CommentItem(
                          title: users[index][0].name,
                          photo: users[index][0].photo,
                          comment: users[index][1].text);
                    },
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 30,
                    child: Center(
                      child:
                          UnconstrainedBox(child: CircularProgressIndicator()),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Visibility(
                visible: !value2.isAnonymous || value2.isVerified,
                child: TextField(
                  controller: ctrl,
                  maxLength: 50,
                  textAlignVertical: TextAlignVertical.bottom,
                  style: const TextStyle(fontSize: 18),
                  scrollPhysics: const BouncingScrollPhysics(),
                  decoration: InputDecoration(
                      hintText: 'Введите комментарий',
                      suffixIcon: IconButton(
                        onPressed: () async {
                          await _submit(mr.id, com);
                        },
                        icon: const Icon(Icons.send),
                      )),
                  onSubmitted: (text) async {
                    await _submit(mr.id, com);
                  },
                ))
          ],
        );
      },
    );
  }
}
