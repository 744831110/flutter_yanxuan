import 'package:flutter/material.dart';

class SearchKeywordModel {
  final String searchText;
  final bool isHot;
  SearchKeywordModel(this.searchText, this.isHot);
  SearchKeywordModel.record(this.searchText) : isHot = false;
  SearchKeywordModel.fromJson(Map<String, dynamic> json)
      : searchText = json["searchText"],
        isHot = int.parse(json["isHot"]) == 1;
}

class SearchSecodeCategoryModel {
  final String picUrl;
  final String title;
  final int type;
  SearchSecodeCategoryModel(this.picUrl, this.title, this.type);
  SearchSecodeCategoryModel.fromJson(Map<String, dynamic> json)
      : picUrl = json["picUrl"],
        title = json["title"],
        type = int.parse(json["type"]);
}

class SearchModel {
  final List<SearchKeywordModel> hotSearch;
  final List<SearchSecodeCategoryModel> secondCategory;
  SearchModel(this.hotSearch, this.secondCategory);
  SearchModel.fromJson(Map<String, dynamic> json)
      : hotSearch = (json["hotSearch"] as List).map((e) => SearchKeywordModel.fromJson(e)).toList(),
        secondCategory = (json["secondCategory"] as List).map((e) => SearchSecodeCategoryModel.fromJson(e)).toList();
}

class FuzzySearchModel {
  final List<FuzzySearchItemModel> data;
  FuzzySearchModel(this.data);
  FuzzySearchModel.fromJson(Map<String, dynamic> json) : data = (json["data"] as List).map((e) => FuzzySearchItemModel.fromJson(json)).toList();
}

class FuzzySearchItemModel {
  final String title;
  final List<String> describes;
  FuzzySearchItemModel(this.title, this.describes);
  FuzzySearchItemModel.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        describes = json["describes"].cast<String>();
}

class SearchFilterTypeResult {
  final List<SearchFilterTypeModel> fliterTypes;
  SearchFilterTypeResult(this.fliterTypes);
  SearchFilterTypeResult.fromJson(Map<String, dynamic> json) : fliterTypes = (json["fliterTypes"] as List).map((e) => SearchFilterTypeModel.fromJson(e)).toList();
}

class SearchFilterTypeModel {
  final String filterType;
  final String describe;
  final List<SearchFilterSubtypeModel> filterSubtypes;
  SearchFilterTypeModel(this.filterType, this.describe, this.filterSubtypes);
  SearchFilterTypeModel.fromJson(Map<String, dynamic> json)
      : filterType = json["filterType"],
        describe = json["describe"],
        filterSubtypes = (json["filterSubtypes"] as List).map((e) => SearchFilterSubtypeModel.fromJson(e)).toList();
}

class SearchFilterSubtypeModel {
  final int subtype;
  final String describe;
  SearchFilterSubtypeModel(this.subtype, this.describe);
  SearchFilterSubtypeModel.fromJson(Map<String, dynamic> json)
      : subtype = int.parse(json["subtype"]),
        describe = json["describe"];
}

class SearchListChangeNotifer extends ChangeNotifier {
  Map<int, List<int>> _selectSubTypes = {};
  int _selectType = -1;
  SearchFilterTypeResult _result;
  SearchListChangeNotifer({required SearchFilterTypeResult result}) : _result = result;
  void removeAllSelectSubtype(int type) {
    _selectSubTypes.remove(type);
    notifyListeners();
  }

  void removeFromSelectSubtype(int type, int subType) {
    _selectSubTypes[type]?.remove(subType);
    notifyListeners();
  }

  void addSelectSubtype(int type, int subType) {
    if (!_selectSubTypes.containsKey(type)) {
      _selectSubTypes[type] = [];
    }
    _selectSubTypes[type]?.add(subType);
    notifyListeners();
  }

  Map<int, List<int>> get selectSubTypes => _selectSubTypes;

  // bool isContainerSubtype(int type, int subType) {
  //   if (_selectSubTypes.containsKey(type)) {
  //     return _selectSubTypes[type]!.contains(subType);
  //   } else {
  //     return false;
  //   }
  // }

  set selectType(int selectType) {
    _selectType = selectType;
    notifyListeners();
  }

  int get selectType => _selectType;

  set result(SearchFilterTypeResult result) {
    _result = result;
    notifyListeners();
  }

  SearchFilterTypeResult get result => _result;
}
