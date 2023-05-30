// ignore_for_file: non_constant_identifier_names, must_be_immutable, use_build_context_synchronously

import 'package:diplom/logic/database/map_route.dart';
import 'package:diplom/logic/map_provider.dart';
import 'package:diplom/logic/map_service.dart';
import 'package:diplom/pages/map_page/route_tab.dart';
import 'package:diplom/widgets/cust_field.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:async_button/async_button.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';

class AddRouteTabView extends StatefulWidget {
  final Function upd;
  const AddRouteTabView({super.key, required this.upd});

  @override
  State<AddRouteTabView> createState() => _AddRouteTabViewState();
}

class _AddRouteTabViewState extends State<AddRouteTabView> {
  final asyncCtrl = AsyncBtnStatesController();
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
    'round-length': 1,
    'alt': 0
  };

  void searchSubmit(text, index) async {
    final s = await MapService().search(text);
    Provider.of<MapModel>(context, listen: false).setSearchPoint(index, s);
  }

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
          child: Consumer<MapModel>(builder: (context, value, child) {
            String text = value.points[index]['ctrl'].text;
            return value.points[index]['search'].isEmpty
                ? CustomField(
                    ctrl: value.points[index]['ctrl'],
                    onSubm: searchSubmit,
                    index: index,
                  )
                : DropDownTextField(
                    dropdownRadius: 5,
                    initialValue: value.points[index]['ctrl'].text,
                    textFieldDecoration: InputDecoration(hintText: text),
                    padding: const EdgeInsets.all(10),
                    listTextStyle: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                    onChanged: (v) {
                      if (v == '') {
                        value.setSearchPoint(index, {});
                        return;
                      }
                      if (v.value is LatLng) {
                        value.addPoint2(v.value, index, v.name);
                        value.mapController.move(v.value, 12);
                      }
                    },
                    dropDownItemCount: 4,
                    dropDownList: value.points[index]['search'].entries
                        .map((e) =>
                            DropDownValueModel(name: e.key, value: e.value))
                        .toList()
                        .cast<DropDownValueModel>());
          }),
        ),
        Visibility(
            visible: del,
            child: Consumer<MapModel>(
              builder: (context, value, child) => IconButton(
                onPressed: () {
                  value.removeCtrl(index);
                },
                icon: const Icon(Icons.wrong_location),
              ),
            )),
      ],
    );
    return row;
  }

  void onTapTab(index) {
    if (index > 0) {}
  }

  Widget _choiceRowChips(List<String> list, IconData? icon) {
    if (icon != null) list.insert(0, '');
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5.0,
      children: List.generate(
        list.length,
        (index) => icon != null && index == 0
            ? Icon(icon, size: 20)
            : ChoiceChip(
                padding: const EdgeInsets.all(3),
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
              padding: const EdgeInsets.all(0),
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
          Visibility(
              visible: value.points.length < 5 &&
                  option['alt'] == 0 &&
                  option['round'] == 0,
              child: ElevatedButton(
                onPressed: () {
                  value.addCtrl();
                },
                child: const Text('Добавить точку'),
              )),
          const SizedBox(height: 10),
          const Text('Дополнительные параметры:'),
          CheckboxListTile(
            contentPadding: const EdgeInsets.all(0),
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Круиз'),
            value: option['round'] == 1,
            onChanged: (e) {
              setState(() {
                option['alt'] = 0;
                option['round'] = option['round'] == 1 ? 0 : 1;
              });
              if (option['round'] == 1) {
                value.changeCtrl(2);
              } else {
                value.changeCtrl(0);
              }
            },
          ),
          option['round'] == 1
              ? const Text('Предпочтительная длина маршрута:')
              : const SizedBox.shrink(),
          option['round'] == 1
              ? Slider(
                  min: 1,
                  max: 3,
                  divisions: 2,
                  value: option['round-length']!.toDouble(),
                  label: [
                    'короткий',
                    'средний',
                    'длинный'
                  ][option['round-length']! - 1],
                  onChanged: (val) {
                    setState(() {
                      option['round-length'] = val.toInt();
                    });
                  })
              : const SizedBox.shrink(),
          CheckboxListTile(
            contentPadding: const EdgeInsets.all(0),
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('Несколько вариаций маршрута'),
            value: option['alt'] == 1,
            onChanged: (e) {
              setState(() {
                option['round'] = 0;
                option['alt'] = option['alt'] == 1 ? 0 : 1;
              });
              if (option['alt'] == 1) {
                value.changeCtrl(1);
              } else {
                value.changeCtrl(0);
              }
            },
          ),
          const Text('Тип передвижения:'),
          const SizedBox(height: 10.0),
          _choiceRowChips(profileNames.sublist(0, 3), Icons.pedal_bike),
          _choiceRowChips(profileNames.sublist(3, 5), Icons.directions_walk),
          _choiceRowChips([profileNames[5]], Icons.accessible),
          option['round'] == 0
              ? const Text('Тип маршрута:')
              : const SizedBox.shrink(),
          option['round'] == 0
              ? const SizedBox(height: 10.0)
              : const SizedBox.shrink(),
          option['round'] == 0
              ? _choiceRowChips(['рекомендованный', 'короткий'], null)
              : const SizedBox.shrink(),
          const SizedBox(height: 10),
          AsyncElevatedBtn(
            failureStyle: const AsyncBtnStateStyle(
                widget: Text(
              'Ошибка. Попробуйте еще раз',
              style: TextStyle(color: Colors.red, fontSize: 16),
            )),
            loadingStyle: const AsyncBtnStateStyle(
                widget: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            )),
            asyncBtnStatesController: asyncCtrl,
            onPressed: () async {
              asyncCtrl.update(AsyncBtnState.loading);
              value.setEditPoint(null);
              if (option['round'] == 0) {
                lis = await MapService().getRoute(
                    profile: option['profile'] ?? 0,
                    points: value.pointList,
                    preference: option['preference'] ?? 0,
                    alt: option['alt'] == 1);
              } else {
                lis.clear();
                MapRoute m = await MapService().getRoundedRoute(
                    profile: option['profile'] ?? 0,
                    points: value.pointList,
                    length: option['round-length'] ?? 1);
                lis.add(m);
              }
              if (lis.isEmpty) {
                asyncCtrl.update(AsyncBtnState.failure);
                return;
              } else {
                value.addAllPolylines(lis.map((e) => e.polyline).toList());
                value.addAllViewPolylines(
                    lis.map((e) => e.accentPolyline).toList());
                for (var i = 0; i < lis.length; i++) {
                  lis[i].name = 'Маршрут ${i + 1}';
                  value.addTab(lis[i].name, RouteTab(mp: lis[i]));
                  widget.upd();
                }
                value.mapController.move(lis[0].bbox.center, 12);
              }
              asyncCtrl.update(AsyncBtnState.idle);
            },
            child: const Text('Составить маршрут'),
          )
        ],
      ),
    );
  }
}
