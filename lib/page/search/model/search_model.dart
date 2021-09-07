class SearchHotSeachModel {
  final String searchText;
  final bool isHot;
  SearchHotSeachModel(this.searchText, this.isHot);
  SearchHotSeachModel.fromJson(Map<String, dynamic> json)
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
  final List<SearchHotSeachModel> hotSearch;
  final List<SearchSecodeCategoryModel> secondCategory;
  SearchModel(this.hotSearch, this.secondCategory);
  SearchModel.fromJson(Map<String, dynamic> json)
      : hotSearch = (json["hotSearch"] as List).map((e) => SearchHotSeachModel.fromJson(e)).toList(),
        secondCategory = (json["secondCategory"] as List).map((e) => SearchSecodeCategoryModel.fromJson(e)).toList();
}
