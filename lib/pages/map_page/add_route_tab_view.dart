// ignore_for_file: non_constant_identifier_names, must_be_immutable

import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/map_service.dart';
import 'package:diplom/logic/providers.dart';
import 'package:diplom/pages/map_page/route_tab.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddRouteTabView extends StatefulWidget {
  final Function upd;
  const AddRouteTabView({super.key, required this.upd});

  @override
  State<AddRouteTabView> createState() => _AddRouteTabViewState();
}

class _AddRouteTabViewState extends State<AddRouteTabView> {
  List<MapRoute> lis = [];
  List<String> profileNames = [
    'Обычный',
    'Электрический',
    'Горный',
    'Прогулка',
    'Туризм',
    'Инвалидное кресло'
  ];
  Map<String, int> option = {
    'profile': 0,
    'preference': 0,
    'round': 0,
    'alt': 0
  };

  Widget _PointField(int index, bool del) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Consumer<MapModel>(
          builder: (context, value, child) => IconButton(
            onPressed: () {
              value.setEditPoint(index);
            },
            icon: const Icon(Icons.edit_location_alt),
          ),
        ),
        Flexible(
          child: Consumer<MapModel>(
            builder: (context, value, child) =>
                CustomField(ctrl: value.points[index]['ctrl']),
          ),
        ),
        del
            ? Consumer<MapModel>(
                builder: (context, value, child) => IconButton(
                  onPressed: () {
                    value.removeCtrl(index);
                  },
                  icon: const Icon(Icons.wrong_location),
                ),
              )
            : SizedBox.fromSize(
                size: const Size(50, 0),
              ),
      ],
    );
    return row;
  }

  Widget _choiceRowChips(List<String> list, IconData? icon) {
    if (icon != null) list.insert(0, '');
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5.0,
      children: List.generate(
        list.length,
        (index) => icon != null && index == 0
            ? Icon(icon, size: 25)
            : ChoiceChip(
                label: Text(list[index]),
                selected: icon != null
                    ? option['profile'] == profileNames.indexOf(list[index])
                    : option['preference'] == index,
                onSelected: (bool selected) {
                  setState(() {
                    if (icon != null) {
                      option['profile'] =
                          profileNames.indexOf(list[index]) != option['profile']
                              ? profileNames.indexOf(list[index])
                              : 0;
                    } else {
                      option['preference'] =
                          index != option['preference'] ? index : 0;
                    }
                  });
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MapModel>(
      builder: (context, value, child) => ListView(
        padding: const EdgeInsets.all(10),
        controller: value.scrollController,
        children: <Widget>[
          const Text('Точки маршрута:'),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: value.points.length,
              itemBuilder: ((BuildContext ctxt, int index) {
                return _PointField(
                    index,
                    value.points.length > 2 &&
                        index > 0 &&
                        index < value.points.length - 1);
              })),
          const SizedBox(height: 10),
          value.points.length < 5
              ? ElevatedButton(
                  onPressed: () {
                    value.addCtrl();
                  },
                  child: const Text('Добавить точку'),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 10),
          const Text('Дополнительные параметры:'),
          Row(
            children: [
              Checkbox(
                value: option['round'] == 1,
                onChanged: (e) {
                  setState(() {
                    option['round'] = option['round'] == 1 ? 0 : 1;
                  });
                },
              ),
              const Text('Круиз (круговой маршрут)')
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: option['alt'] == 1,
                onChanged: (e) {
                  setState(() {
                    option['alt'] = option['alt'] == 1 ? 0 : 1;
                  });
                },
              ),
              const Text('Несколько вариаций маршрута')
            ],
          ),
          const Text('Тип передвижения:'),
          const SizedBox(height: 10.0),
          _choiceRowChips(profileNames.sublist(0, 3), Icons.pedal_bike),
          _choiceRowChips(profileNames.sublist(3, 5), Icons.directions_walk),
          _choiceRowChips([profileNames[5]], Icons.accessible),
          const Text('Тип маршрута:'),
          const SizedBox(height: 10.0),
          _choiceRowChips(['рекомендованный', 'короткий'], null),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              lis = await MapService().getRoute(
                  profile: option['profile'] ?? 0,
                  points: value.pointList,
                  preference: option['preference'] ?? 0,
                  alt: true);
              value.addAllPolylines(lis.map((e) => e.polyline).toList());
              for (var i = 0; i < lis.length; i++) {
                lis[i].name = 'Маршрут ${i + 1}';
                value.addTab(lis[i].name, RouteTab(mp: lis[i]));
                widget.upd();
              }
            },
            child: const Text('Составить маршрут'),
          ),
        ],
      ),
    );
  }
}
