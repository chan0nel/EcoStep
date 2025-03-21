// ignore_for_file: prefer_function_declarations_over_variables

import 'dart:collection';

import 'package:diplom/logic/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ListModel extends ChangeNotifier {
  Function refresh = () => {};
  final PanelController panelController = PanelController();

  final Map<String, bool> _mapSearch = {
    'название': true,
    'пользователь': false,
    'тип передвижения': false,
    'с подъемом': false,
    'со спуском': false,
  };

  final Map<String, dynamic> _map = {
    'yours': [],
    'saves': [],
    'default': [],
    'other': []
  };

  final Map<String, bool> shown = {
    'yours': true,
    'saves': true,
    'default': true,
    'other': true
  };

  final List<dynamic> _seemore = [];

  UnmodifiableMapView<String, dynamic> get search =>
      UnmodifiableMapView(_mapSearch);
  UnmodifiableMapView<String, dynamic> get map => UnmodifiableMapView(_map);
  UnmodifiableListView<dynamic> get seemore => UnmodifiableListView(_seemore);

  void changeRoute(key, value) {
    _seemore.clear();
    _seemore.add(key);
    _seemore.add(value);
    notifyListeners();
  }

  void updateBlock(what, {ind = -1}) {
    if (ind == -1) {
      _map[seemore[0]][seemore[1]][what].block.add(AuthenticationService().uid);
      if (_map[seemore[0]][seemore[1]][what].block.length >= 5) {
        refresh();
        notifyListeners();
      }
    } else {
      _map[seemore[0]][seemore[1]][what][ind]
          .block
          .add(AuthenticationService().uid);
      if (_map[seemore[0]][seemore[1]][what][ind].block.length >= 5) {
        refresh();
        notifyListeners();
      }
    }
  }

  void addComment(text) {
    _map[seemore[0]][seemore[1]]['comment'].add(text);
    notifyListeners();
  }

  void changeSearch(key, value) {
    _mapSearch[key] = value;
    bool flag = false;
    _mapSearch.forEach((key, value) {
      if (value != false) {
        flag = true;
      }
    });
    if (!flag) _mapSearch['название'] = true;
    notifyListeners();
  }

  void changeShown(name) {
    shown[name] = !shown[name]!;
    notifyListeners();
  }

  void setMap(mapp) {
    mapp.forEach(
      (key, value) => _map[key] = value,
    );
  }

  void clearMap(key, val) {
    _map.clear();
    notifyListeners();
  }

  void clearSearch() {
    _mapSearch.updateAll((key, value) => false);
    _mapSearch['название'] = true;
    notifyListeners();
  }
}
