class GoodItemModel {
  final bool isHot;
  final bool isLiving;
  final String picUrl;
  final String giftUrl;
  final String describe;
  final String speciaDescribeTitle;
  final String speciaDescribe;
  final int speciaDescribeType;
  final String leftDescribe;
  final String title;
  final String subtitle;
  final List<GoodItemTagModel> tags;
  final String originPrice;
  final String? discountPrice;
  GoodItemModel(this.isHot, this.isLiving, this.picUrl, this.giftUrl, this.describe, this.speciaDescribe, this.speciaDescribeTitle, this.speciaDescribeType, this.leftDescribe, this.title, this.subtitle, this.tags,
      this.originPrice, this.discountPrice);
  GoodItemModel.fromJson(Map<String, dynamic> json)
      : isHot = int.parse(json["isHot"]) == 1,
        isLiving = int.parse(json["isLiving"]) == 1,
        picUrl = json["picUrl"],
        giftUrl = json["giftUrl"],
        describe = json["describe"],
        speciaDescribeTitle = json["speciaDescribeTitle"],
        speciaDescribe = json["speciaDescribe"],
        speciaDescribeType = int.parse(json["speciaDescribeType"]),
        leftDescribe = json["leftDescribe"],
        title = json["title"],
        subtitle = json["subtitle"],
        tags = (json["tags"] as List).map((e) => GoodItemTagModel.fromJson(e)).toList(),
        originPrice = double.parse(json["originPrice"]).toString(),
        discountPrice = json["discountPrice"].toString().isEmpty ? null : double.parse(json["discountPrice"]).toString() {}
}

class GoodItemTagModel {
  final int type;
  final String content;
  GoodItemTagModel(this.type, this.content);
  GoodItemTagModel.fromJson(Map<String, dynamic> json)
      : type = int.parse(json["type"]),
        content = json["content"];
}
