// ignore_for_file: use_build_context_synchronously

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/user.dart';
import 'package:diplom/pages/auth_page/auth_page.dart';
import 'package:diplom/widgets/confirm_dialog.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:diplom/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/provider/theme_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<bool> isSelected = [true, false];
  late Future<User> _user;

  @override
  void initState() {
    super.initState();
    _user = AuthenticationService().my;
  }

  Widget _dialogPhoto(context, User user) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
            itemCount: 15,
            itemBuilder: (context, index) => InkWell(
              onTap: () async {
                user.photo = index + 1;
                DBService().setUser(user);
                _update();
              },
              child: Image.asset(
                'images/photo (${index + 1}).png',
                height: 50,
                width: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogName(context, User user) {
    final ctrl = TextEditingController(text: user.name);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 150),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomField(
                  ctrl: ctrl,
                ),
                ElevatedButton(
                    onPressed: () {
                      user.name = ctrl.text;
                      DBService().setUser(user);
                      _update();
                    },
                    child: const Text('Сохранить'))
              ],
            )),
      ),
    );
  }

  void _update() {
    setState(() {
      _user = AuthenticationService().my;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ваш профиль'),
        centerTitle: true,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, value, child) {
              return IconButton(
                  onPressed: () {
                    value.toggleTheme();
                  },
                  icon: value.curTheme
                      ? const Icon(Icons.light_mode)
                      : const Icon(Icons.dark_mode));
            },
          )
        ],
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.connectionState == ConnectionState.done) {
            final user = snapshot.data ?? User();
            if (user.uid == 'anonymous') {
              return Center(
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    const Text(
                      'АНОНИМНЫЙ ПОЛЬЗОВАТЕЛЬ',
                      style: TextStyle(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox.fromSize(size: const Size.fromHeight(10)),
                    const Text(
                      'Желаете зарегистрироваться или войти в аккаунт?',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox.fromSize(size: const Size.fromHeight(10)),
                    const Text(
                      'Это предоставит вам возможность сохранения'
                      ' маршрута и комментирования.',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox.fromSize(size: const Size.fromHeight(20)),
                    ElevatedButton(
                      child: const Text('Перейти'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthenticationPage(
                              upd: _update,
                            ),
                          ),
                        );
                      },
                    ),
                    const Divider(
                      height: 30,
                      color: Colors.black38,
                      indent: 20,
                      endIndent: 20,
                    ),
                    TextButton(
                        onPressed: () async {},
                        child: const CustText(
                          'Справка',
                        )),
                    const Divider(
                      height: 30,
                      color: Colors.black38,
                      indent: 20,
                      endIndent: 20,
                    ),
                    TextButton(
                        onPressed: () async {},
                        child: const CustText(
                          'О приложении',
                        )),
                  ],
                ),
              ));
            } else {
              return Consumer<AuthenticationService>(
                  builder: (context, value, child) {
                return Center(
                  child: ListView(children: [
                    GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _dialogPhoto(context, user);
                          }),
                      child: Image.asset(
                        'images/photo (${user.photo}).png',
                        width: 200,
                        height: 200,
                      ),
                    ),
                    SizedBox.fromSize(size: const Size.fromHeight(10)),
                    GestureDetector(
                      onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return _dialogName(context, user);
                          }),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${user.name} ',
                              style: const TextStyle(fontSize: 20),
                            ),
                            const Icon(
                              Icons.edit,
                              size: 20,
                            )
                          ]),
                    ),
                    ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Visibility(
                            visible: !value.isVerified,
                            child: const CustText('Аккаунт не верифицирован')),
                        Visibility(
                          visible: !value.isVerified,
                          child: ElevatedButton(
                              onPressed: () async {
                                await value.verificate();
                              },
                              child: const Text('Верифицировать')),
                        ),
                        const Divider(
                          height: 30,
                          color: Colors.black38,
                          indent: 20,
                          endIndent: 20,
                        ),
                        TextButton(
                            onPressed: () async {
                              await value.resetPass();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Письмо на смену пароля отправлено: ${value.user!.email}')));
                            },
                            child: const CustText(
                              'Поменять пароль',
                            )),
                        const Divider(
                          height: 30,
                          color: Colors.black38,
                          indent: 20,
                          endIndent: 20,
                        ),
                        TextButton(
                            onPressed: () async {},
                            child: const CustText(
                              'Справка',
                            )),
                        const Divider(
                          height: 30,
                          color: Colors.black38,
                          indent: 20,
                          endIndent: 20,
                        ),
                        TextButton(
                            onPressed: () async {},
                            child: const CustText(
                              'О приложении',
                            )),
                        const Divider(
                          height: 30,
                          color: Colors.black38,
                          indent: 20,
                          endIndent: 20,
                        ),
                        Container(
                            height: 40,
                            width: 75,
                            alignment: Alignment.center,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white),
                                onPressed: () async {
                                  final res = await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          const ConfirmDialog(opt: 'выйти'));
                                  if (res) {
                                    await value.signOut();
                                    _update();
                                  }
                                },
                                child: const Text('Выйти'))),
                      ],
                    ),
                  ]),
                );
              });
            }
          } else {
            return const Center(child: Text('dont found'));
          }
        },
        future: _user,
      ),
    );
  }
}
