// ignore_for_file: import_of_legacy_library_into_null_safe, use_build_context_synchronously

import 'dart:async';

import 'package:async_button/async_button.dart';
import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:diplom/widgets/password_field.dart';
import 'package:extended_tabs/extended_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AuthenticationPage extends StatefulWidget {
  final Function upd;
  const AuthenticationPage({super.key, required this.upd});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  bool hide = false;
  final async1 = AsyncBtnStatesController();
  final async2 = AsyncBtnStatesController();
  final async3 = AsyncBtnStatesController();
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
      if (mounted) {
        Timer(const Duration(milliseconds: 50), () {
          setState(() {
            hide = visible;
          });
        });
      }
    });
  }

  @override
  void dispose() {
    keyboardSubscription.cancel();
    async1.dispose();
    async2.dispose();
    async3.dispose();
    super.dispose();
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
                title: const Text('Аутентификация'),
                bottom: const TabBar(tabs: [
                  Tab(
                    icon: Icon(Icons.how_to_reg_rounded, size: 44),
                  ),
                  Tab(icon: Icon(Icons.person_add_alt_rounded, size: 44)),
                ]),
              )
            : null,
        body: ExtendedTabBarView(
          cacheExtent: 2,
          children: [
            Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomField(
                      type: TextInputType.emailAddress,
                      hintText: 'email',
                      ctrl: signInCtrl[0],
                    ),
                    PasswordField(
                      helperText: false,
                      ctrl: signInCtrl[1],
                    ),
                    Flexible(
                        child: AsyncTextBtn(
                      asyncBtnStatesController: async3,
                      failureStyle: const AsyncBtnStateStyle(
                          widget: Text(
                        'Нет аккаунта с такой почтой',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      )),
                      loadingStyle: const AsyncBtnStateStyle(
                          widget: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )),
                      onPressed: () async {
                        async3.update(AsyncBtnState.loading);
                        final text = signInCtrl[0].text;
                        final mes = await AuthenticationService()
                            .resetPass(email: text);
                        if (!mes) {
                          async3.update(AsyncBtnState.failure);
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Письмо на смену пароля отправлено: ${signInCtrl[0].text}')));
                      },
                      child: const Text(
                        'Я не помню пароль',
                        style: TextStyle(fontSize: 16),
                      ),
                    )),
                    Flexible(
                        child: AsyncElevatedBtn(
                      asyncBtnStatesController: async1,
                      failureStyle: const AsyncBtnStateStyle(
                          widget: Text(
                        'Ошибка',
                        style: TextStyle(color: Colors.red, fontSize: 18),
                      )),
                      loadingStyle: const AsyncBtnStateStyle(
                          widget: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(),
                      )),
                      onPressed: () async {
                        async1.update(AsyncBtnState.loading);
                        final mes = await AuthenticationService().signIn(
                            email: signInCtrl[0].text,
                            password: signInCtrl[1].text);
                        if (!mes) {
                          async1.update(AsyncBtnState.failure);
                          return;
                        }
                        async1.update(AsyncBtnState.idle);
                        Navigator.pop(context);
                        widget.upd();
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
                      type: TextInputType.emailAddress,
                      hintText: 'email',
                      ctrl: signUpCtrl[0],
                    ),
                    CustomField(
                      hintText: 'никнейм',
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
                    AsyncElevatedBtn(
                        asyncBtnStatesController: async2,
                        failureStyle: const AsyncBtnStateStyle(
                            widget: Text(
                          'Ошибка',
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        )),
                        loadingStyle: const AsyncBtnStateStyle(
                            widget: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(),
                        )),
                        onPressed: () async {
                          async2.update(AsyncBtnState.loading);
                          final auth = AuthenticationService();
                          final mes = await auth.signUp(
                              email: signUpCtrl[0].text,
                              password: signUpCtrl[2].text,
                              nickname: signUpCtrl[1].text);
                          if (!mes) {
                            async2.update(AsyncBtnState.failure);
                            return;
                          }
                          await auth.verificate();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('Не забудьте подтвердить почту.'),
                          ));
                          Navigator.pop(context);
                          widget.upd();
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
