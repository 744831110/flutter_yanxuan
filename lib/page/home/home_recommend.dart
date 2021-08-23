import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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

  @override
  void initState() {
    super.initState();
    picUrls.add(widget.picUrls.last);
    picUrls.addAll(widget.picUrls);
    picUrls.add(widget.picUrls.first);
    urls.add(widget.url.last);
    urls.addAll(widget.url);
    urls.add(widget.url.first);
    // Timer.periodic(Duration(seconds: 3), (timer) {
    //   pageController.animateToPage(pageController.page!.toInt() + 1, duration: Duration(milliseconds: 400), curve: Curves.easeInOut);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 305,
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
                      print("index == 0 picurl length ${picUrls.length}");
                    } else if (index == picUrls.length - 1) {
                      pageIndex = 1;
                      print("index == picurls.length - 1");
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
          )),
    );
  }
}

class HomeTabCountDownWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<HomeTabModel>();
    return Container(
      height: 150,
      padding: EdgeInsets.only(left: 5, right: 5),
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
          height: 80,
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "￥${model.discountPrice}", style: TextStyle(color: redColor, fontSize: 10, fontWeight: FontWeight.w500)),
              TextSpan(text: "￥${model.originPrice}", style: TextStyle(color: greyColor, decoration: TextDecoration.lineThrough, fontSize: 10, fontWeight: FontWeight.w300)),
            ],
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
  @override
  void initState() {
    super.initState();
    this.countDown = widget.countDown;
    Timer.periodic(Duration(seconds: 1), (timer) {
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
          "$time",
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w300),
        ),
      ),
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
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      shrinkWrap: true,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      itemCount: 20,
      itemBuilder: (context, index) {
        if (index == 0) {
          final swiperList = model.swiper;
          return HomeTabSwiper(
            picUrls: swiperList.map((e) => e.picUrl).toList(),
            url: swiperList.map((e) => e.url).toList(),
          );
        } else if (index == 1) {
          return HomeTabCountDownWidget();
        }
        return GestureDetector(
          onTap: () {},
          child: Container(
            height: index == 0 || index == 2
                ? 40
                : index == 1
                    ? 100
                    : 30,
            color: Colors.red,
            child: Text("$index"),
          ),
        );
      },
      staggeredTileBuilder: (index) => StaggeredTile.fit(2),
    );
  }
}
