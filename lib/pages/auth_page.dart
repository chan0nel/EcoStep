// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/widgets/custom_field.dart';
import 'package:diplom/widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool hide = false;
  late StreamSubscription<bool> keyboardSubscription;

  List<TextEditingController> signInCtrl = [
    TextEditingController(),
    TextEditingController()
  ];
  List<TextEditingController> signUpCtrl = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void initState() {
    super.initState();

    final keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      Timer(const Duration(milliseconds: 50), () {
        setState(() {
          hide = visible;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: !hide
            ? AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: const Text('Аутенфикация'),
                bottom: const TabBar(tabs: [
                  Tab(
                    icon: Icon(Icons.how_to_reg_rounded, size: 44),
                  ),
                  Tab(icon: Icon(Icons.person_add_alt_rounded, size: 44)),
                ]),
              )
            : null,
        body: TabBarView(
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomField(
                      textInputType: TextInputType.emailAddress,
                      hintText: 'email',
                      ctrl: signInCtrl[0],
                    ),
                    PasswordField(
                      helperText: false,
                      ctrl: signInCtrl[1],
                    ),
                    Flexible(
                        child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Я не помню пароль',
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                    Flexible(
                        child: ElevatedButton(
                      onPressed: () async {
                        final mes = await AuthenticationService().signIn(
                            email: signInCtrl[0].text,
                            password: signInCtrl[1].text);
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(mes)));
                      },
                      child: const Text(
                        'ВОЙТИ',
                        style: TextStyle(fontSize: 18),
                      ),
                    )),
                  ],
                )),
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomField(
                      textInputType: TextInputType.emailAddress,
                      hintText: 'email',
                      ctrl: signUpCtrl[0],
                    ),
                    CustomField(
                      textInputType: TextInputType.text,
                      hintText: 'nickname',
                      ctrl: signUpCtrl[1],
                    ),
                    PasswordField(
                      helperText: true,
                      ctrl: signUpCtrl[2],
                    ),
                    PasswordField(
                      helperText: false,
                      ctrl: signUpCtrl[3],
                      dop: signUpCtrl[2],
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          final auth = AuthenticationService();
                          //auth.signUpAnon();
                          final mes = await auth.signUp(
                              email: signUpCtrl[0].text,
                              password: signUpCtrl[2].text);
                          await auth.updateInfo(nickname: signUpCtrl[1].text);
                          await auth.verificate();
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(mes)));
                        },
                        child: const Text(
                          'ЗАРЕГИСТРИРОВАТЬСЯ',
                          style: TextStyle(fontSize: 18),
                        )),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
