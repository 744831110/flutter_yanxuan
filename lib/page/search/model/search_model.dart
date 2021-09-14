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
