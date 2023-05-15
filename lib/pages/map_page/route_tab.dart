// ignore_for_file: avoid_init_to_null

import 'package:async_button/async_button.dart';
import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/public_route.dart';
import 'package:diplom/widgets/atlitude_chart.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteTab extends StatefulWidget {
  final MapRoute mp;
  final PublicRoute? pr;
  const RouteTab({super.key, required this.mp, this.pr = null});

  @override
  State<RouteTab> createState() => _RouteTabState();
}

class _RouteTabState extends State<RouteTab> {
  AsyncBtnStatesController asyncCtrl = AsyncBtnStatesController();
  late TextEditingController _controller;
  bool save = true;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.mp.name);
  }

  Future<void> _save() async {
    final DBService service = DBService();
    widget.mp.name = _controller.text;
    final id = await service.saveMapRoutes(widget.mp);
    await service.savePublicRoute(
        PublicRoute(uid: AuthenticationService().uid), id);
  }

  @override
  Widget build(BuildContext context) {
    //ScrollController ctrl = Provider.of<MapModel>(context).scrollController;
    return ListView(
      padding: const EdgeInsets.all(10),
      //controller: ctrl,
      primary: false,
      children: [
        const Text('Название:'),
        CustomField(
          ctrl: _controller,
        ),
        Text('Тип передвижения: ${widget.mp.profile}'),
        Text('Протяженность: ${widget.mp.distanceCast}'),
        Text('Время прохождения: ${widget.mp.timeCast}'),
        const Text('График высот:'),
        AtlitudeChart(
          data: widget.mp.atlitude,
          distance: widget.mp.distance,
        ),
        Text('Подъем: ${widget.mp.ascent}'),
        Text('Спуск: ${widget.mp.descent}'),
        Visibility(
          visible: widget.pr == null,
          child: Consumer<AuthenticationService>(
            builder: (context, value, child) => AsyncElevatedBtn(
              asyncBtnStatesController: asyncCtrl,
              switchBackAfterCompletion: !isSaved,
              failureStyle: const AsyncBtnStateStyle(
                  widget: Text(
                'Ошибка. У вас нет доступа',
                style: TextStyle(color: Colors.red, fontSize: 16),
              )),
              loadingStyle: const AsyncBtnStateStyle(
                  widget: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              )),
              successStyle: AsyncBtnStateStyle(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).disabledColor),
                  widget:
                      const Text('Сохранено', style: TextStyle(fontSize: 16))),
              onPressed: () async {
                if (isSaved) return;
                asyncCtrl.update(AsyncBtnState.loading);
                if (value.isAnonymous || !value.isVerified) {
                  asyncCtrl.update(AsyncBtnState.failure);
                } else {
                  setState(() {
                    isSaved = true;
                  });
                  try {
                    await _save();
                  } catch (ex) {
                    setState(() {
                      isSaved = false;
                    });
                    asyncCtrl.update(AsyncBtnState.failure);
                  }
                  asyncCtrl.update(AsyncBtnState.success);
                }
              },
              child: const Text('Сохранить'),
            ),
          ),
        ),
        // Visibility(
        //   visible: widget.pr == null,
        //   child: Consumer<AuthenticationService>(
        //     builder: (context, value, child) => ElevatedButton(
        //       onPressed: () async {
        //         if (value.isAnonymous ||
        //             !value.isAuthenticated ||
        //             !value.isVerified) {
        //           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //               content: Text('Вам не доступна данная функция')));
        //         } else {
        //           await _save();
        //         }
        //       },
        //       child: const Text('Сохранить'),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
