import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_yanxuan/page/home/model/home_model.dart';
import 'package:provider/provider.dart';

typedef SearchCallback = void Function(String searchText);

// progress -70~0为隐藏HomeAppBar 0-100为搜索栏上移 logo隐藏
class HomeAppBar extends StatelessWidget {
  final double progress;
  final VoidCallback? signInButtonAction;
  final VoidCallback? sweepButtonAction;
  final VoidCallback? messageButtonAction;
  final SearchCallback? searchAction;
  HomeAppBar({
    Key? key,
    required this.progress,
    this.signInButtonAction,
    this.sweepButtonAction,
    this.messageButtonAction,
    this.searchAction,
  }) : super(
          key: key,
        );
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _barOpacity,
      child: Container(
        color: Colors.white,
        height: _barHeight,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: MediaQuery.of(context).padding.top + 5,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Opacity(
                        opacity: _logoOpacity,
                        child: logoWidget(),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: rightItemWidget(),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 7,
              child: HomeSearchWidget(
                width: _searchButtonWidth(context),
                searchTextList: context.watch<HomePageModel>().barModule.searchTextList,
                searchAction: searchAction,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget logoWidget() {
    return Container(
      height: 30,
      child: Row(
        children: [
          Image.asset(
            "assets/images/ic_tab_home_normal.png",
            width: 30.0,
            height: 30.0,
            color: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.only(left: 5),
            child: Text(
              "网易严选",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget rightItemWidget() {
    return Container(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 7,
        children: [
          IconButton(
              onPressed: signInButtonAction,
              icon: Image(
                image: NetworkImage("https://yanxuan.nosdn.127.net/4a90fbfb67c3a3295f813ff078415362.gif"),
                width: 35,
                height: 35,
              )),
          Column(
            children: [
              Icon(
                Icons.qr_code_scanner_sharp,
                size: 20,
                color: Colors.black,
              ),
              Text(
                "扫一扫",
                style: TextStyle(fontSize: 12, color: Colors.black),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: [
                Icon(
                  Icons.alarm,
                  size: 20,
                  color: Colors.black,
                ),
                Text(
                  "消息",
                  style: TextStyle(fontSize: 12, color: Colors.black),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /**
   * 适配全面屏
   **/
  double get _barHeight {
    if (progress > 100) {
      return 73;
    } else if (progress < 0) {
      return 125;
    } else {
      return -0.52 * progress + 125;
    }
  }

  double get _barOpacity {
    if (progress >= 0) {
      return 1;
    } else if (progress <= -70.0) {
      return 0;
    } else {
      return 1 + progress / 70.0;
    }
  }

  double get _logoOpacity {
    if (progress > 100) {
      return 0;
    } else if (progress < 0) {
      return 1;
    } else {
      return 1 - progress / 100;
    }
  }

  double _searchButtonWidth(BuildContext context) {
    if (progress > 50) {
      return MediaQuery.of(context).size.width - 125;
    } else if (progress < 0) {
      return MediaQuery.of(context).size.width;
    } else {
      return MediaQuery.of(context).size.width - 125 * progress / 50;
    }
  }
}

class HomeSearchWidget extends StatefulWidget {
  final SearchCallback? searchAction;
  final List<String>? searchTextList;
  final double width;
  HomeSearchWidget({Key? key, this.searchAction, this.searchTextList, required this.width}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _HomeSearchWidgetState();
  }
}

class _HomeSearchWidgetState extends State<HomeSearchWidget> with TickerProviderStateMixin {
  int index = 0;
  late String searchText;
  late AnimationController _animationController;
  late Animation _firstUpAnimation;
  late Animation _secondUpAnimation;
  bool isSwitchAnimation = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 4));
    _animationController.addListener(() {
      setState(() {
        this.isSwitchAnimation = _secondUpAnimation.value == 0.0;
      });
    });
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isSwitchAnimation = false;
        _animationController.forward(from: 0);
        if (widget.searchTextList != null && widget.searchTextList!.length != 0) {
          index = (index + 1) % widget.searchTextList!.length;
          searchText = widget.searchTextList![index];
        } else {
          searchText = "";
        }
      }
    });
    _firstUpAnimation = Tween(begin: 0.0, end: -20.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0.95, 1)));
    _secondUpAnimation = Tween(begin: 20.0, end: 0.0).animate(CurvedAnimation(parent: _animationController, curve: Interval(0, 0.05)));
    if (widget.searchTextList != null && widget.searchTextList!.length != 0) {
      _animationController.forward(from: 0.1);
      searchText = widget.searchTextList![index];
    } else {
      searchText = "";
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        height: 36,
        width: widget.width,
        child: ClipRect(
          child: Padding(
            padding: EdgeInsets.only(left: 10.0, right: 10.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(18)),
                border: Border.all(color: Colors.red, width: 2),
                color: Colors.white,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                    ),
                    child: Image(
                      image: AssetImage("assets/images/nav_search_ic_normal.png"),
                      width: 15,
                      height: 15,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Transform.translate(
                        offset: Offset(0, isSwitchAnimation ? _firstUpAnimation.value : _secondUpAnimation.value),
                        child: Text(
                          searchText,
                          style: TextStyle(color: greyTextColor, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 32,
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)), color: Colors.red),
                    child: Center(
                      child: Text(
                        "搜索",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 17),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        if (widget.searchAction != null) {
          widget.searchAction!(showText);
        }
      },
    );
  }

  String get showText {
    return widget.searchTextList?.elementAt(index) ?? "";
  }
}
