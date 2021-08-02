import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/view/drop_down_refresh.dart';
import 'package:flutter_yanxuan/common/view/empty_widget.dart';
import 'package:flutter_yanxuan/common/view/error_widget.dart';
import 'package:flutter_yanxuan/page/home/home_bar.dart';
import 'package:flutter_yanxuan/page/home/home_category.dart';
import 'package:flutter_yanxuan/page/home/model/home_model.dart';
import 'package:flutter_yanxuan/page/home/viewmodel/home_view_model.dart';
import 'package:flutter_yanxuan/page/main/main_page.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  final scrollController = ScrollController();
  final homeViewModel = HomeViewModel();
  bool isRefreshing = false;
  double refreshExtend = 0;

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
    print("start request");
    homeViewModel.requestHomeData();
  }

  @override
  Widget build(BuildContext context) {
    double scrollOffset = scrollController.hasClients ? scrollController.offset * 100 / 60 + this.refreshExtend : 0;
    return StreamBuilder<HomePageModel>(
      stream: homeViewModel.homeDataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return CustomErrorWidget();
        } else {
          if (!snapshot.hasData) {
            return CustomEmptyWidget();
          }
          final model = snapshot.data;
          return Provider<HomePageModel>.value(
            value: snapshot.data!,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    CustomCupertinoSliverRefreshControl(
                      refreshIndicatorExtendCallback: (isRefreshExtend, extend) {
                        this.refreshExtend = isRefreshExtend ? extend : 0;
                      },
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
                            child: new Text('$model'),
                          );
                        },
                        childCount: 50, //50个列表项
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: HomeAppBar(
                      // 处理下转换成progress
                      progress: scrollOffset > 80
                          ? 100
                          : isRefreshing
                              ? -70
                              : scrollOffset),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
