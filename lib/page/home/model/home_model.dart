class HomePageModel {
  final HomeBarModule barModule;
  final HomeCategoryModule categoryModule;
  HomePageModel(this.barModule, this.categoryModule);
  HomePageModel.fromJson(Map<String, dynamic> json)
      : barModule = HomeBarModule.fromJson(json["barModule"]),
        categoryModule = HomeCategoryModule.fromJson(json["categoryModule"]);
}

class HomeBarModule {
  final List<String> searchTextList;
  HomeBarModule(this.searchTextList);
  HomeBarModule.fromJson(Map<String, dynamic> json) : searchTextList = json["searchTextList"].cast<String>();
}

class HomeCategoryModule {
  late final List<HomeCategoryModel> category;
  late final List<HomeCategoryWebModel> web;
  HomeCategoryModule(this.category, this.web);
  HomeCategoryModule.fromJson(Map<String, dynamic> json) {
    category = (json["category"] as List).map((e) => HomeCategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    web = (json["web"] as List).map((e) => HomeCategoryWebModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}

class HomeCategoryModel {
  final String picUrl;
  final String title;
  HomeCategoryModel(this.picUrl, this.title);
  HomeCategoryModel.fromJson(Map<String, dynamic> json)
      : picUrl = json["picUrl"],
        title = json["title"];
}

class HomeCategoryWebModel {
  final String picUrl;
  final String title;
  final String url;
  HomeCategoryWebModel(this.picUrl, this.title, this.url);
  HomeCategoryWebModel.fromJson(Map<String, dynamic> json)
      : picUrl = json["picUrl"],
        title = json["title"],
        url = json["url"];
}
