import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_yanxuan/page/good/good_model.dart';
import 'package:flutter_yanxuan/page/home/model/home_model.dart';
import 'package:provider/provider.dart';

class HomeTabSwiper extends StatefulWidget {
  final List<String> picUrls;
  final List<String> url;

  HomeTabSwiper({required this.picUrls, required this.url});

  @override
  State<StatefulWidget> createState() {
    return _HomeTabSwiperState();
  }
}

class _HomeTabSwiperState extends State<HomeTabSwiper> {
  int pageIndex = 1;
  final pageController = PageController(initialPage: 1);
  List<String> picUrls = [];
  List<String> urls = [];

  bool isPauseTimer = true;

  @override
  void initState() {
    super.initState();
    picUrls.add(widget.picUrls.last);
    picUrls.addAll(widget.picUrls);
    picUrls.add(widget.picUrls.first);
    urls.add(widget.url.last);
    urls.addAll(widget.url);
    urls.add(widget.url.first);
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (isPauseTimer) {
        pageController.animateToPage(pageController.page!.toInt() + 1, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        isPauseTimer = false;
      },
      onPointerCancel: (event) {
        isPauseTimer = true;
      },
      onPointerUp: (event) {
        isPauseTimer = true;
      },
      child: Container(
        height: 325,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView(
                controller: pageController,
                children: picUrls
                    .map((e) => GestureDetector(
                          onTap: () {},
                          child: Image(
                            image: NetworkImage(e),
                            fit: BoxFit.fitWidth,
                          ),
                        ))
                    .toList(),
                onPageChanged: (index) {
                  if (index == 0) {
                    pageController.jumpToPage(picUrls.length - 2);
                  } else if (index == picUrls.length - 1) {
                    pageController.jumpToPage(1);
                  }
                  setState(() {
                    if (index == 0) {
                      pageIndex = picUrls.length - 2;
                    } else if (index == picUrls.length - 1) {
                      pageIndex = 1;
                    } else {
                      pageIndex = index;
                    }
                  });
                },
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Text(
                  " $pageIndex/${picUrls.length - 2} ",
                  style: TextStyle(
                    backgroundColor: greyColor1,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTabCountDownWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeTabModel>();
    return Container(
      height: 160,
      padding: EdgeInsets.only(left: 10, right: 5, top: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        gradient: LinearGradient(
          colors: [pinkColor, Colors.white],
          begin: Alignment.topCenter,
          end: FractionalOffset(0.5, 0.35),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "每日抄底",
                style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.normal),
              ),
              HomeTabCountDownText(countDown: model.countDown.time),
            ],
          ),
          Text(
            "全站底价 放心买",
            style: TextStyle(color: redColor, fontSize: 13, fontWeight: FontWeight.w300),
          ),
          Padding(
            padding: EdgeInsets.only(top: 5),
            child: Row(
              children: model.countDown.items
                  .map(
                    (e) => Expanded(
                      flex: 1,
                      child: itemWidget(e),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget itemWidget(HomeTabCountDownItemModel model) {
    return Column(
      children: [
        Image(
          image: NetworkImage(model.picUrl),
          height: 75,
        ),
        Padding(
          padding: EdgeInsets.only(top: 3),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: "￥${model.discountPrice}", style: TextStyle(color: redColor, fontSize: 10, fontWeight: FontWeight.w500)),
                TextSpan(text: "￥${model.originPrice}", style: TextStyle(color: YXColorGray7, decoration: TextDecoration.lineThrough, fontSize: 10, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class HomeTabCountDownText extends StatefulWidget {
  final int countDown;
  HomeTabCountDownText({required this.countDown});
  @override
  State<StatefulWidget> createState() {
    return _HomeTabCountDownTextState();
  }
}

class _HomeTabCountDownTextState extends State<HomeTabCountDownText> {
  late int countDown;
  int hours = 0;
  int min = 0;
  int seconds = 0;
  late Timer timer;
  @override
  void initState() {
    super.initState();
    this.countDown = widget.countDown;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countDown--;
        hours = countDown ~/ 3600;
        min = countDown % 3600 ~/ 60;
        seconds = countDown % 3600 % 60;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 5),
      child: Row(
        children: [
          timeText(hours),
          Text(" : ", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          timeText(min),
          Text(" : ", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
          timeText(seconds),
        ],
      ),
    );
  }

  Widget timeText(int time) {
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Colors.black),
      child: Center(
        child: Text(
          time ~/ 10 == 0 ? "0$time" : "$time",
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    timer.cancel();
    super.deactivate();
  }
}

class HomeTabNewProductWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeTabModel>();
    return Container(
      height: 160,
      padding: EdgeInsets.only(left: 10, right: 5, top: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(2)),
          gradient: LinearGradient(
            colors: [cyanColor, Colors.white],
            begin: Alignment.topCenter,
            end: FractionalOffset(0.5, 0.35),
          ),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "新品首发",
                style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.normal),
              ),
              Padding(
                padding: EdgeInsets.only(left: 5),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: orangeColor),
                  child: Text(
                    " 低价尝鲜 ",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Text(
              "999+款上新",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300, color: orangeColor),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 5),
              child: Row(
                children: model.newProduct
                    .map((e) => Expanded(
                          child: Image(
                            height: 75,
                            image: NetworkImage(e),
                          ),
                          flex: 1,
                        ))
                    .toList(),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HomeTabTitleItemCombinationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeTabModel>();
    return Container(
      height: 325,
      color: greyColor2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: model.titleItems.map((e) => HomeTabTitleItemWidget(model: e)).toList(),
      ),
    );
  }
}

class HomeTabTitleItemWidget extends StatelessWidget {
  final HomeTabTitleItemModel model;
  HomeTabTitleItemWidget({required this.model});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)), color: Colors.white),
      child: Row(
        children: model.items
            .map(
              (e) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 10, top: 10),
                  child: HomeTabTitleItem(
                    title: e.title,
                    subtitle: e.subtitle,
                    picUrl: e.picUrl,
                    subTitleHexColor: e.subtitleColor,
                  ),
                ),
                flex: 1,
              ),
            )
            .toList(),
      ),
    );
  }
}

class HomeTabTitleItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String picUrl;
  final String subTitleHexColor;
  HomeTabTitleItem({required this.title, required this.subtitle, required this.picUrl, required this.subTitleHexColor});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title",
          style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w400),
        ),
        Text(
          "$subtitle",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: HexColor(subTitleHexColor),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            child: Image(
              image: NetworkImage(picUrl),
              fit: BoxFit.fitWidth,
            ),
          ),
        )
      ],
    );
  }
}

class HomeTabItemWidget extends StatefulWidget {
  final GoodItemModel model;
  HomeTabItemWidget({required this.model});
  @override
  State<StatefulWidget> createState() {
    return _HomeTabItemWidgetState();
  }
}

class _HomeTabItemWidgetState extends State<HomeTabItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          HomeTabItemImageWidget(
            model: widget.model,
          ),
          Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${widget.model.title}",
                  style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                  maxLines: 2,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Text(
                    "${widget.model.subtitle}",
                    style: TextStyle(color: YXColorGray7, fontSize: 13),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: widget.model.tags
                        .map((e) => HomeTabItemPriceTagWidget(
                              type: e.type,
                              content: e.content,
                            ))
                        .toList(),
                    direction: Axis.horizontal,
                    spacing: 5,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: HomeTabPriceWidget(
                    originPrice: widget.model.originPrice,
                    discountPrice: widget.model.discountPrice,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class HomeTabItemImageWidget extends StatelessWidget {
  final GoodItemModel model;
  HomeTabItemImageWidget({required this.model});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2))),
      height: 220,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image(image: NetworkImage(model.picUrl)),
          Positioned(
            right: 5,
            top: 10,
            child: model.isHot
                ? hotTag()
                : model.isLiving
                    ? livingTag()
                    : Container(),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: model.speciaDescribeType == 0
                ? describeWidget(model.describe)
                : HomeTabItemSpeciaDescribeWidget(
                    describe: model.speciaDescribe,
                    describeTitle: model.speciaDescribeTitle,
                    discountPrice: model.discountPrice,
                    describeType: model.speciaDescribeType,
                  ),
          )
        ],
      ),
    );
  }

  Widget hotTag() {
    return Text(
      " HOT ",
      style: TextStyle(
        backgroundColor: redColor,
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget livingTag() {
    return Text(
      " Live ",
      style: TextStyle(
        backgroundColor: redColor,
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget describeWidget(String content) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(2)),
        color: yellowColor1,
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Text(
          content,
          style: TextStyle(color: YXColorYellow5, fontSize: 12, fontWeight: FontWeight.w400),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}

class HomeTabItemSpeciaDescribeWidget extends StatelessWidget {
  final String describeTitle;
  final String? discountPrice;
  final String describe;
  final int describeType;

  HomeTabItemSpeciaDescribeWidget({required this.describe, required this.discountPrice, required this.describeTitle, required this.describeType});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: getColorFromType(describeType),
              height: 26,
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            top: 0,
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(getDecorationImageFromType(describeType)), centerSlice: Rect.fromLTWH(10, 0, 3, 5)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child: Column(
                      children: [
                        Text(
                          describeTitle,
                          style: TextStyle(color: getTextColorFromType(describeType), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        discountPrice == null
                            ? Container()
                            : Text(
                                discountPrice!,
                                style: TextStyle(color: getTextColorFromType(describeType), fontSize: 12, fontWeight: FontWeight.w600),
                              )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5, top: 5),
                  child: Text(
                    describe,
                    style: TextStyle(color: getTextColorFromType(describeType), fontSize: 11, fontWeight: FontWeight.w400),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Color getTextColorFromType(int type) {
    if (type == 2) {
      return Colors.black;
    } else if (type == 1) {
      return Colors.white;
    }
    return Colors.white;
  }

  String getDecorationImageFromType(int type) {
    if (type == 2) {
      return "assets/images/common_list_nor_foreshow_bg_normal.png";
    } else if (type == 1) {
      return "assets/images/common_list_nor_official_bg_normal.png";
    }
    return "assets/images/common_list_nor_official_bg_normal.png";
  }

  Color getColorFromType(int type) {
    if (type == 2) {
      return YXColorYellow25;
    } else if (type == 1) {
      return YXColorOrange;
    }
    return YXColorOrange;
  }
}

class HomeTabItemPriceTagWidget extends StatelessWidget {
  final int type;
  final String content;
  HomeTabItemPriceTagWidget({required this.type, this.content = ""});
  @override
  Widget build(BuildContext context) {
    if (type == 0) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          color: YXColorPink5,
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 2),
          child: Text(
            "$content",
            style: TextStyle(color: YXColorRed19, fontSize: 9, fontWeight: FontWeight.normal),
          ),
        ),
      );
    } else if (type == 1) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/common_list_discount_pro_ic_normal.png"), centerSlice: Rect.fromLTWH(35, 0, 3, 10), fit: BoxFit.fill),
        ),
        height: 14,
        child: Padding(
          padding: EdgeInsets.only(left: 34, right: 5),
          child: Text(
            content,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.normal),
          ),
        ),
      );
    } else if (type == 2) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
          border: Border.all(color: YXColorGreen, width: 1),
          color: lightGreedColor,
        ),
        child: UnconstrainedBox(
          child: Row(
            children: [
              SizedBox(width: 3),
              Image(image: AssetImage("assets/images/common_list_order_0pay.png")),
              SizedBox(width: 2),
              Text(
                content,
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.normal),
              ),
              SizedBox(width: 5),
            ],
          ),
        ),
      );
    } else {
      return Container();
    }
  }
}

class HomeTabPriceWidget extends StatelessWidget {
  final String originPrice;
  final String? discountPrice;
  HomeTabPriceWidget({required this.originPrice, required this.discountPrice});
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(text: "￥", style: TextStyle(fontSize: 10, color: redColor)),
        TextSpan(text: originPrice, style: TextStyle(fontSize: 18, color: redColor, fontWeight: FontWeight.w500)),
        TextSpan(text: discountPrice == null ? "" : "￥$discountPrice", style: TextStyle(fontSize: 10, decoration: TextDecoration.lineThrough, color: YXColorGray7))
      ]),
    );
  }
}

class HomeTabGridWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeTabGridWidgetState();
  }
}

class _HomeTabGridWidgetState extends State<HomeTabGridWidget> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeTabModel>();
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(color: greyColor2),
      child: StaggeredGridView.countBuilder(
        crossAxisCount: 4,
        shrinkWrap: true,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        itemCount: 13,
        itemBuilder: (context, index) {
          if (index == 0) {
            final swiperList = model.swiper;
            return HomeTabSwiper(
              picUrls: swiperList.map((e) => e.picUrl).toList(),
              url: swiperList.map((e) => e.url).toList(),
            );
          } else if (index == 1) {
            return HomeTabCountDownWidget();
          } else if (index == 2) {
            return HomeTabNewProductWidget();
          } else if (index == 3) {
            return HomeTabTitleItemCombinationWidget();
          }
          return HomeTabItemWidget(
            model: model.items[index - 4],
          );
        },
        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
      ),
    );
  }
}
