import 'package:flutter_yanxuan/page/good/good_model.dart';

class HomePageModel {
  final HomeBarModule barModule;
  final HomeCategoryModule categoryModule;
  final List<HomeRecommendTabModel> recommendTabModelList;
  HomePageModel(this.barModule, this.categoryModule, this.recommendTabModelList);
  HomePageModel.fromJson(Map<String, dynamic> json)
      : barModule = HomeBarModule.fromJson(json["barModule"]),
        categoryModule = HomeCategoryModule.fromJson(json["categoryModule"]),
        recommendTabModelList = (json["recommendModule"] as List).map((e) => HomeRecommendTabModel.fromJson(e)).toList();
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
    category = (json["category"] as List).map((e) => HomeCategoryModel.fromJson(e)).toList();
    web = (json["web"] as List).map((e) => HomeCategoryWebModel.fromJson(e)).toList();
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

class HomeRecommendTabModel {
  final String name;
  final int type;
  HomeRecommendTabModel(this.name, this.type);
  HomeRecommendTabModel.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        type = json["type"];
}

class HomeTabModel {
  final List<HomeTabSwiperModel> swiper;
  final HomeTabCountDownModel countDown;
  final List<String> newProduct;
  final List<HomeTabTitleItemModel> titleItems;
  final List<HomeTabWebItemModel> webItems;
  List<GoodItemModel> items;
  HomeTabModel(this.swiper, this.countDown, this.newProduct, this.titleItems, this.webItems, this.items);
  HomeTabModel.fromJson(Map<String, dynamic> json)
      : swiper = (json["swiper"] as List).map((e) => HomeTabSwiperModel.fromJson(e)).toList(),
        countDown = HomeTabCountDownModel.fromJson(json["countDown"]),
        newProduct = json["newProduct"].cast<String>(),
        titleItems = (json["titleItems"] as List).map((e) => HomeTabTitleItemModel.fromJson(e)).toList(),
        webItems = (json["webItems"] as List).map((e) => HomeTabWebItemModel.fromJson(e)).toList(),
        items = (json["items"] as List).map((e) => GoodItemModel.fromJson(e)).toList();
}

class HomeTabSwiperModel {
  final String picUrl;
  final String url;
  HomeTabSwiperModel(this.picUrl, this.url);
  HomeTabSwiperModel.fromJson(Map<String, dynamic> json)
      : picUrl = json["picUrl"],
        url = json["url"];
}

class HomeTabCountDownModel {
  final int time;
  final List<HomeTabCountDownItemModel> items;
  HomeTabCountDownModel(this.time, this.items);
  HomeTabCountDownModel.fromJson(Map<String, dynamic> json)
      : time = int.parse(json["time"]),
        items = (json["items"] as List).map((e) => HomeTabCountDownItemModel.fromJson(e)).toList();
}

class HomeTabCountDownItemModel {
  final String picUrl;
  final String originPrice;
  final String discountPrice;
  HomeTabCountDownItemModel(this.picUrl, this.originPrice, this.discountPrice);
  HomeTabCountDownItemModel.fromJson(Map<String, dynamic> json)
      : picUrl = json["picUrl"],
        originPrice = json["originPrice"],
        discountPrice = json["discountPrice"];
}

class HomeTabTitleItemModel {
  final List<HomeTabTitleItemContent> items;
  HomeTabTitleItemModel(this.items);
  HomeTabTitleItemModel.fromJson(Map<String, dynamic> json) : items = (json["items"] as List).map((e) => HomeTabTitleItemContent.fromJson(e)).toList();
}

class HomeTabTitleItemContent {
  final String title;
  final String subtitle;
  final String subtitleColor;
  final String picUrl;
  HomeTabTitleItemContent(this.title, this.subtitle, this.subtitleColor, this.picUrl);
  HomeTabTitleItemContent.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        subtitle = json["subtitle"],
        subtitleColor = json["subtitleColor"],
        picUrl = json["picUrl"];
}

class HomeTabWebItemModel {
  final String picUrl;
  final String url;
  HomeTabWebItemModel(this.picUrl, this.url);
  HomeTabWebItemModel.fromJson(Map<String, dynamic> json)
      : picUrl = json["picUrl"],
        url = json["url"];
}
