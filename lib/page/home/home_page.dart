import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/view/drop_down_refresh.dart';
import 'package:flutter_yanxuan/page/home/home_bar.dart';
import 'package:flutter_yanxuan/page/home/home_category.dart';
import 'package:flutter_yanxuan/page/main/main_page.dart';
import 'package:provider/provider.dart';

// 签到 gif https://yanxuan.nosdn.127.net/4a90fbfb67c3a3295f813ff078415362.gif

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final scrollController = ScrollController();
  PointerDownEvent? downEvent;
  double offset = 0;
  bool isRefreshing = false;
  double get _barHeight {
    if (!scrollController.hasClients) {
      return 100;
    }
    if (scrollController.offset <= 0) {
      return 100;
    } else if (scrollController.offset >= 100) {
      return 50;
    } else {
      return 100 - scrollController.offset / 2;
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      TabbarModel model = context.read<TabbarModel>();
      if (scrollController.offset > 400 && !model.isShowHomeRecommand || scrollController.offset <= 400 && model.isShowHomeRecommand) {
        model.isShowHomeRecommand = scrollController.offset > 400;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    double scrollOffset = scrollController.hasClients ? scrollController.offset * 100 / 60 : 0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Listener(
          onPointerDown: (e) {
            downEvent = e;
          },
          onPointerMove: (e) {
            if (downEvent != null) {
              offset = e.position.dy - downEvent!.position.dy;
            }
          },
          onPointerUp: (e) {
            downEvent = null;
          },
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              CustomCupertinoSliverRefreshControl(
                refreshTriggerPullDistance: 120.0,
                refreshIndicatorExtent: 60.0,
                onRefresh: () async {
                  setState(() {});
                  isRefreshing = true;
                  await Future<void>.delayed(const Duration(seconds: 2));
                  isRefreshing = false;
                },
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 30, left: 10, right: 10),
                  child: HomeCategoryWidget(),
                ),
              ),
              SliverFixedExtentList(
                itemExtent: 200.0,
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    //创建列表项
                    return Container(
                      alignment: Alignment.center,
                      color: Colors.lightBlue[100 * (index % 9) + 100],
                      child: new Text('list item $index'),
                    );
                  },
                  childCount: 50, //50个列表项
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: HomeAppBar(
              // 处理下转换成progress
              progress: scrollOffset > 80
                  ? 100
                  : downEvent != null
                      ? -offset * 100 / 60
                      : isRefreshing
                          ? -70
                          : scrollController.hasClients
                              ? scrollController.offset * 100 / 60
                              : 0),
        ),
      ],
    );
  }
}
