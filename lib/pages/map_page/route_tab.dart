import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/database/public_route.dart';
import 'package:diplom/logic/database/users.dart';
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
    print(widget.pr.toString());
    return ListView(
      padding: const EdgeInsets.all(10),
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
        widget.pr == null
            ? Consumer<AuthenticationService>(
                builder: (context, value, child) => ElevatedButton(
                  onPressed: () async {
                    if (value.isAnonymous ||
                        !value.isAuthenticated ||
                        !value.isVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Вам не доступна данная функция')));
                    } else {
                      await _save();
                    }
                  },
                  child: const Text('Сохранить'),
                ),
              )
            : const SizedBox.shrink(),
        // widget.pr != null
        //     ? ListView.builder(
        //         shrinkWrap: true,
        //         itemCount: widget.pr!.comments.length,
        //         itemBuilder: (context, index) {
        //           return FutureBuilder(
        //             builder: (context, snapshot) {
        //               if (snapshot.connectionState == ConnectionState.waiting)
        //                 return CircularProgressIndicator();
        //               if (snapshot.connectionState == ConnectionState.done)
        //                 return Text(snapshot.data.toString());
        //               return SizedBox.shrink();
        //             },
        //             future: DBService().getUser(widget.pr!.uid),
        //           );
        //         })
        //     : const SizedBox.shrink(),
      ],
    );
  }
}
