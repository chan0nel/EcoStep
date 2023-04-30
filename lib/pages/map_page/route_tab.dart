import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/public_route.dart';
import 'package:diplom/widgets/atlitude_chart.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:flutter/material.dart';

class RouteTab extends StatefulWidget {
  final MapRoute mp;
  const RouteTab({super.key, required this.mp});

  @override
  State<RouteTab> createState() => _RouteTabState();
}

class _RouteTabState extends State<RouteTab> {
  late TextEditingController _controller;
  bool save = true;

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
    _controller = TextEditingController(text: widget.mp.name);
    return ListView(
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
        ElevatedButton(
            onPressed: () async {
              await _save();
            },
            child: const Text('Сохранить'))
      ],
    );
  }
}
