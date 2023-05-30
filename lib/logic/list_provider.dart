import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ListModel extends ChangeNotifier {
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

  UnmodifiableMapView<String, dynamic> get search =>
      UnmodifiableMapView(_mapSearch);
  UnmodifiableMapView<String, dynamic> get map => UnmodifiableMapView(_map);

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
    //notifyListeners();
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
