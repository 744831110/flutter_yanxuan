import 'package:flutter_yanxuan/network/network.dart';
import 'package:flutter_yanxuan/page/search/model/search_model.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

const String preference_search_record = "searchRecord";

class SearchKeywordViewModel {
  StreamController<SearchModel> _controller = BehaviorSubject<SearchModel>();
  Stream<SearchModel> get homeSearchDataStream => _controller.stream;

  void requestSearchData() {
    NetWorkHelper.instance.dio.get("home/search/json").then((value) {
      final model = SearchModel.fromJson(value.data);
      _controller.add(model);
    }).catchError((error) {
      _controller.addError(error);
    });
  }

  Future<List<String>> getPreferenceData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(preference_search_record) ?? ["保温杯"];
  }

  Future<void> saveRecord(String record) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList(preference_search_record);
    if (list == null) {
      prefs.setStringList(preference_search_record, [record]);
    } else {
      list.add(record);
      prefs.setStringList(preference_search_record, list);
    }
  }

  Future<bool> removeAllRecord() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(preference_search_record);
  }
}

class FuzzySearchViewModel {
  StreamController<FuzzySearchModel> _fuzzySearchController = BehaviorSubject<FuzzySearchModel>();
  Stream<FuzzySearchModel> get fuzzySearchDataStream => _fuzzySearchController.stream;

  void requestFuzzySearchData(String prefix) {
    if (prefix.isEmpty) {
      return;
    }
    NetWorkHelper.instance.yxDio.post("xhr/search/searchAutoComplete.json", queryParameters: {"keywordPrefix": prefix}).then((value) {
      List<String> list = value.data["data"].cast<String>();
      final model = FuzzySearchModel(list.map((e) {
        int random = Random().nextInt(3);
        return FuzzySearchItemModel(e, List.generate(random, (index) => "tag$index"));
      }).toList());
      _fuzzySearchController.add(model);
      print("model $model");
    }).catchError((error) {
      print("error is $error");
      _fuzzySearchController.addError(error);
    });
  }
}
