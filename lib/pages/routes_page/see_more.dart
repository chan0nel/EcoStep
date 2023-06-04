// ignore_for_file: unused_import, unused_field, unused_local_variable, use_build_context_synchronously

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/comment.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/user.dart';
import 'package:diplom/logic/provider/list_provider.dart';
import 'package:diplom/logic/provider/map_provider.dart';
import 'package:diplom/widgets/atlitude_chart.dart';
import 'package:diplom/widgets/comment_item.dart';
import 'package:diplom/widgets/confirm_dialog.dart';
import 'package:diplom/widgets/cust_text.dart';
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

  Future<void> _submit(String routeid) async {
    if (ctrl.text.trim() != '') {
      final c = Comment(
          uid: AuthenticationService().uid,
          routeid: routeid,
          text: ctrl.text.trim());
      final a = await DBService().saveComment(obj: c);
      Provider.of<ListModel>(context, listen: false).addComment(c);
      ctrl.text = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListModel, AuthenticationService>(
      builder: (context, value, value2, child) {
        if (value.seemore.isEmpty) {
          return const SizedBox.shrink();
        }
        MapRoute mr =
            value.map[value.seemore[0]][value.seemore[1]]['map'] ?? MapRoute();
        User? user = value.map[value.seemore[0]][value.seemore[1]]['user'];
        List<Comment> com = value.map[value.seemore[0]][value.seemore[1]]
                ['comment']
            .cast<Comment>();
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
            const SizedBox(height: 10),
            CustText(mr.name, bold: true),
            CustText('Тип передвижения: ${mr.profile}'),
            CustText('Протяженность: ${mr.distanceCast}'),
            CustText('Время прохождения: ${mr.timeCast}'),
            const CustText('График высот:'),
            AtlitudeChart(
              data: mr.atlitude,
              distance: mr.distance,
            ),
            CustText('Подъем: ${mr.ascent}, Спуск: ${mr.descent}'),
            const SizedBox(height: 10),
            const CustText('Комментарии:', com: true),
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
                        date: users[index][1].date,
                        comment: users[index][1].text,
                        func1: () async {
                          if (user!.block
                              .contains(AuthenticationService().uid)) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  'Вы уже пожаловались на данного пользователя'),
                            ));
                          } else {
                            final res = await showDialog(
                              context: context,
                              builder: (context) => ConfirmDialog(
                                  opt: 'пожаловаться на пользователя '
                                      '\'${user.name}\''),
                            );
                            if (res) {
                              user.block.add(AuthenticationService().uid);
                              await DBService()
                                  .update('users/${user.uid}', user);
                              if (user.block.length >= 5) {
                                setState(() {
                                  _getUser = getUsers();
                                });
                              }
                            }
                          }
                        },
                        func2: () async {
                          if (mr.block.contains(AuthenticationService().uid)) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content:
                                  Text('Вы уже пожаловались на данный маршрут'),
                            ));
                          } else {
                            final res = await showDialog(
                              context: context,
                              builder: (context) => ConfirmDialog(
                                  opt:
                                      'пожаловаться на комментарий \'${com[index].text}\''),
                            );
                            if (res) {
                              com[index].block.add(AuthenticationService().uid);
                              await DBService().update(
                                  'comments/${com[index].id}', com[index]);
                              if (com[index].block.length >= 5) {
                                setState(() {
                                  _getUser = getUsers();
                                });
                              }
                            }
                          }
                        },
                      );
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
                          await _submit(mr.id);
                        },
                        icon: const Icon(Icons.send),
                      )),
                  onSubmitted: (text) async {
                    await _submit(mr.id);
                  },
                ))
          ],
        );
      },
    );
  }
}
