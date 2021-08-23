import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_yanxuan/page/category/category_page.dart';
import 'package:flutter_yanxuan/page/home/home_page.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  final pageController = PageController();
  final homePage = HomePage();
  final categoryPage = CategoryWidget();

  List<Widget>? itemList;
  final List<_BarItemModel> modelList = [];

  int tabIndex = 0;
  bool isShowRecommend = false;

  @override
  void initState() {
    super.initState();
    modelList.add(
      _BarItemModel("首页", "assets/images/ic_tab_home_normal.png", "assets/images/ic_tab_home_active.png", 0)..isSelect = true,
    );
    modelList.add(
      _BarItemModel("分类", "assets/images/ic_tab_group_normal.png", "assets/images/ic_tab_group_active.png", 1),
    );
    modelList.add(
      _BarItemModel("选巷", "assets/images/ic_tab_xuan_normal.png", "assets/images/ic_tab_xuan_active.png", 2),
    );
    modelList.add(
      _BarItemModel("购物车", "assets/images/ic_tab_cart_normal.png", "assets/images/ic_tab_cart_active.png", 3),
    );
    modelList.add(
      _BarItemModel("个人", "assets/images/ic_tab_profile_normal.png", "assets/images/ic_tab_profile_active.png", 4),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [homePage, categoryPage],
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            tabIndex = index;
          });
        },
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: Consumer<TabbarModel>(
        builder: (context, tabbarModel, child) {
          modelList[3].redPoint = tabbarModel.cartRedPoint;
          return BottomAppBar(
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: modelList.map((model) {
                if (model.index == 0) {
                  return normalItem(model, specialWidget: model.isSelect ? homeSpecialWidget(isShowRecommend: !tabbarModel.isShowHomeRecommand) : null);
                }
                return normalItem(model);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget normalItem(_BarItemModel model, {Widget? specialWidget}) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        child: Container(
            color: Colors.white,
            height: 55,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 8,
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        model.isSelect ? model.selectImageName : model.imageName,
                        height: 22,
                        width: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Text(
                          model.title,
                          style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.normal, color: model.isSelect ? redTextColor : greyTextColor),
                        ),
                      ),
                    ],
                  ),
                ),
                specialWidget ?? Container()
              ],
            )),
        onTap: () => tapItem(model),
      ),
    );
  }

  Widget homeSpecialWidget({bool isShowRecommend = false}) {
    return Center(
      child: AnimatedOpacity(
        opacity: isShowRecommend ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              "assets/images/ic_tab_home_recommand.png",
              width: 47,
              height: 47,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "推荐",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  void tapItem(_BarItemModel model) {
    setState(() {
      modelList.forEach((element) => element.isSelect = false);
      model.isSelect = true;
      tabIndex = model.index;
      pageController.jumpToPage(model.index);
    });
  }
}

class _BarItemModel {
  String title, imageName, selectImageName;
  int index, redPoint = 0;
  bool isSelect = false;
  _BarItemModel(this.title, this.imageName, this.selectImageName, this.index);
}

class TabbarModel extends ChangeNotifier {
  bool _isShowHomeRecommand = false;
  set isShowHomeRecommand(bool isShowHomeRecommand) {
    _isShowHomeRecommand = isShowHomeRecommand;
    notifyListeners();
  }

  bool get isShowHomeRecommand => _isShowHomeRecommand;

  // 红点数
  int _cartRedPoint = 0;
  set cartRedPoint(int cartRedPoint) {
    _cartRedPoint = cartRedPoint;
    notifyListeners();
  }

  int get cartRedPoint => _cartRedPoint;
}
