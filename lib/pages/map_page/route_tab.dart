// ignore_for_file: avoid_init_to_null

import 'package:async_button/async_button.dart';
import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/provider/map_provider.dart';
import 'package:diplom/widgets/atlitude_chart.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:diplom/widgets/cust_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteTab extends StatefulWidget {
  final MapRoute mp;
  const RouteTab({super.key, required this.mp});

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
    widget.mp.uid = Provider.of<AuthenticationService>(context).uid;
    await service.saveMapRoutes(widget.mp);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(10),
      primary: false,
      controller:
          Provider.of<MapModel>(context, listen: false).scrollController1,
      children: [
        const CustText('Название:'),
        CustomField(
          ctrl: _controller,
        ),
        const SizedBox(height: 10),
        CustText('Тип передвижения: ${widget.mp.profile}'),
        CustText('Протяженность: ${widget.mp.distanceCast}'),
        CustText('Время прохождения: ${widget.mp.timeCast}'),
        const CustText('График высот:'),
        AtlitudeChart(
          data: widget.mp.atlitude,
          distance: widget.mp.distance,
        ),
        CustText('Подъем: ${widget.mp.ascent}, спуск: ${widget.mp.descent}'),
        Visibility(
          visible: widget.mp.uid == '',
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
      ],
    );
  }
}
