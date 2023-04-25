// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'package:diplom/logic/auth_service.dart';
import 'package:diplom/logic/database/firebase_service.dart';
import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/map_service.dart';
import 'package:diplom/logic/providers.dart';
import 'package:diplom/widgets/atlitude_chart.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBottomSheet extends StatefulWidget {
  List<TextEditingController> ctrl;
  CustomBottomSheet({super.key, required this.ctrl});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  List<MapRoute> lis = [];
  List<String> profileNames = [
    'Обычный',
    'Электрический',
    'Горный',
    'Прогулка',
    'Туризм',
    'Инвалидное кресло'
  ];
  Map<String, int> chips = {'profile': 0, 'preference': 0};

  @override
  void initState() {
    super.initState();
  }

  Widget _PointField(int index) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<MapModel>(
          builder: (context, value, child) => IconButton(
            onPressed: () {
              value.setEditPoint(index);
            },
            icon: const Icon(Icons.add_location_alt),
          ),
        ),
        Flexible(
          child: Consumer<MapModel>(
            builder: (context, value, child) =>
                CustomField(ctrl: value.points[index]['ctrl']),
          ),
        ),
      ],
    );
    return row;
  }

  void addPointField() {
    setState(() {
      widget.ctrl.insert(widget.ctrl.length - 1, TextEditingController());
    });
  }

  Size getSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  Widget _choiceRowChips(List<String> list, IconData? icon) {
    if (icon != null) list.insert(0, '');
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5.0,
      children: List.generate(
        list.length,
        (index) => icon != null && index == 0
            ? Icon(
                icon,
                size: 25,
              )
            : ChoiceChip(
                label: Text(list[index]),
                selected: icon != null
                    ? chips['profile'] == profileNames.indexOf(list[index])
                    : chips['preference'] == index,
                onSelected: (bool selected) {
                  setState(() {
                    if (icon != null) {
                      chips['profile'] =
                          profileNames.indexOf(list[index]) != chips['profile']
                              ? profileNames.indexOf(list[index])
                              : 0;
                    } else {
                      chips['preference'] =
                          index != chips['preference'] ? index : 0;
                    }
                  });
                },
              ),
      ),
    );
  }

  Widget _routeView(MapRoute route) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        CustomField(
          ctrl: TextEditingController(text: 'Маршрут 1'),
        ),
        Text('Тип: ${route.profile}'),
        const Text('График высоты: '),
        AtlitudeChart(data: route.atlitude),
        Text('Наименьшая высота: ${route.descent}'
            'наибольшая высота ${route.ascent}'),
        Text('Дистанция: ${route.distance},'
            'время прохождения: ${route.duration}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapModel>(
      builder: (context, value, child) => value.states['hideSheet'] != false
          ? SizedBox.expand(
              child: DraggableScrollableSheet(
                  minChildSize: 0.075,
                  maxChildSize: 0.8,
                  initialChildSize: 0.8,
                  builder: (BuildContext context,
                          ScrollController scrollController) =>
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(30.0),
                            topLeft: Radius.circular(30.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5.0,
                              spreadRadius: 10.0,
                              offset: const Offset(0.0, 5.0),
                              color: Colors.black.withOpacity(0.1),
                            )
                          ],
                          color: Colors.white,
                        ),
                        child: ListView(
                          controller: scrollController,
                          children: <Widget>[
                            const Text('Выберите тип передвижения:'),
                            const SizedBox(height: 10.0),
                            _choiceRowChips(
                                profileNames.sublist(0, 3), Icons.pedal_bike),
                            _choiceRowChips(profileNames.sublist(3, 5),
                                Icons.directions_walk),
                            _choiceRowChips(
                                [profileNames[5]], Icons.accessible),
                            const Text('Выберите тип маршрута:'),
                            const SizedBox(height: 10.0),
                            _choiceRowChips([
                              'рекомендованный',
                              'короткий (до 3-х вариантов)'
                            ], null),
                            const Text('Точки маршрута:'),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: value.points.length,
                                itemBuilder: ((BuildContext ctxt, int index) {
                                  return _PointField(index);
                                })),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                value.addCtrl();
                              },
                              child: const Text('Добавить точку'),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                lis = await MapService().getRoute(
                                    profile: chips['profile'] ?? 0,
                                    points: value.pointList,
                                    preference: chips['preference'] ?? 0);
                                for (var element in lis) {
                                  value.addPolyline(element.polyline);
                                }
                              },
                              child: const Text('Составить маршрут'),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: lis.length,
                                itemBuilder: ((BuildContext ctxt, int index) {
                                  return ListTile(
                                    trailing: Consumer<AuthenticationService>(
                                      builder: (context, value2, child) =>
                                          IconButton(
                                        icon: const Icon(Icons.save),
                                        onPressed: () async {
                                          if (!value2.isAnonymous &&
                                              value2.isVerified) {
                                            DBService('map-routes').saveRoute(
                                                lis[index], 'Маршрут $index');
                                          }
                                        },
                                      ),
                                    ),
                                    title: Text('Маршрут $index'),
                                    subtitle: Row(children: [
                                      const Icon(Icons.timer),
                                      Text(lis[index].duration.toString()),
                                      const Icon(Icons.straight),
                                      Text(lis[index].distance.toString()),
                                    ]),
                                  );
                                })),
                          ],
                        ),
                      )))
          : const SizedBox.shrink(),
    );
  }
}
