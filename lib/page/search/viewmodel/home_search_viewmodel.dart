import 'package:flutter_yanxuan/network/network.dart';
import 'package:flutter_yanxuan/page/search/model/home_search_model.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class HomeSearchViewModel {
  StreamController<HomeSearchModel> _controller = BehaviorSubject<HomeSearchModel>();
  Stream<HomeSearchModel> get homeSearchDataStream => _controller.stream;

  void requestSearchData() {
    NetWorkHelper.instance.dio.get("home/search/json").then((value) {
      final model = HomeSearchModel.fromJson(value.data);
      _controller.add(model);
    }).catchError((error) {
      _controller.addError(error);
    });
  }

  Future<List<String>> getPreferenceData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList("searchRecord") ?? ["保温杯"];
  }
}
