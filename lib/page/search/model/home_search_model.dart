class HomeHotSeachModel {
  final String searchText;
  final bool isHot;
  HomeHotSeachModel(this.searchText, this.isHot);
  HomeHotSeachModel.fromJson(Map<String, dynamic> json)
      : searchText = json["searchText"],
        isHot = int.parse(json["isHot"]) == 1;
}

class HomeSecodeCategoryModel {
  final String picUrl;
  final String title;
  final int type;
  HomeSecodeCategoryModel(this.picUrl, this.title, this.type);
  HomeSecodeCategoryModel.fromJson(Map<String, dynamic> json)
      : picUrl = json["picUrl"],
        title = json["title"],
        type = int.parse(json["type"]);
}

class HomeSearchModel {
  final List<HomeHotSeachModel> hotSearch;
  final List<HomeSecodeCategoryModel> secondCategory;
  HomeSearchModel(this.hotSearch, this.secondCategory);
  HomeSearchModel.fromJson(Map<String, dynamic> json)
      : hotSearch = (json["hotSearch"] as List).map((e) => HomeHotSeachModel.fromJson(e)).toList(),
        secondCategory = (json["secondCategory"] as List).map((e) => HomeSecodeCategoryModel.fromJson(e)).toList();
}
