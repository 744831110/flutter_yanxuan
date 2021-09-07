import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_yanxuan/common/network_stream_builder.dart';
import 'package:flutter_yanxuan/common/view/drop_down_refresh.dart';
import 'package:flutter_yanxuan/common/view/empty_widget.dart';
import 'package:flutter_yanxuan/common/view/error_widget.dart';
import 'package:flutter_yanxuan/page/home/home_bar.dart';
import 'package:flutter_yanxuan/page/home/home_category.dart';
import 'package:flutter_yanxuan/page/home/home_recommend.dart';

import 'package:flutter_yanxuan/page/home/model/home_model.dart';
import 'package:flutter_yanxuan/page/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_yanxuan/page/main/main_page.dart';
import 'package:flutter_yanxuan/page/search/search_page.dart';
import 'package:flutter_yanxuan/router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final scrollController = ScrollController();
  final pageController = PageController();
  late TabController tabController;
  bool isPageViewCanChange = true;

  bool isRefreshing = false;
  double refreshExtend = 0;
  int pageIndex = 0;

  final homeViewModel = HomeViewModel();

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
    tabController = TabController(length: 0, vsync: this);
    homeViewModel.requestHomeData();
    homeViewModel.homeDataStream.listen((event) {
      tabController = TabController(length: event.recommendTabModelList.length, vsync: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    double scrollOffset = scrollController.hasClients ? scrollController.offset * 100 / 60 + this.refreshExtend : 0;
    return NetworkStreamBuilder<HomePageModel>(
      stream: homeViewModel.homeDataStream,
      errorView: CustomErrorWidget(),
      emptyView: CustomEmptyWidget(),
      builder: (context, data) {
        return Stack(
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
                // debug 模式下有溢出，忽略。
                // 后续看怎么改
                FixedPersistentHeader(
                  FixedPersistentHeaderDelegate(
                    isNeedTransform: true,
                    max: 230,
                    min: 73,
                    child: Container(
                      height: 230,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30, left: 10, right: 10),
                        child: HomeCategoryWidget(),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  delegate: FixedPersistentHeaderDelegate(
                    max: 50,
                    min: 50,
                    child: Container(
                      height: 50,
                      color: Colors.white,
                      child: Theme(
                        data: ThemeData(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: TabBar(
                          labelStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                          unselectedLabelStyle: TextStyle(color: greyColor, fontSize: 14, fontWeight: FontWeight.normal),
                          labelColor: Colors.black,
                          unselectedLabelColor: greyColor,
                          indicator: BoxDecoration(),
                          controller: tabController,
                          isScrollable: true,
                          tabs: data.recommendTabModelList.map((e) => Tab(text: e.name)).toList(),
                          onTap: (index) async {
                            isPageViewCanChange = false;
                            await pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOut);
                            isPageViewCanChange = true;
                          },
                        ),
                      ),
                    ),
                  ),
                  pinned: true,
                  floating: false,
                ),
                SliverToBoxAdapter(
                  child: Container(
                    height: 500,
                    child: PageView(
                      onPageChanged: (index) {
                        setState(() {
                          if (isPageViewCanChange) {
                            tabController.animateTo(index);
                          }
                        });
                      },
                      controller: pageController,
                      children: homeViewModel.homeTabStreams
                          .map(
                            (e) => NetworkStreamBuilder(
                              stream: e,
                              builder: (context, model) {
                                return HomeTabGridWidget();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: HomeAppBar(
                  searchAction: clickSearchButton,
                  // 处理下转换成progress
                  progress: scrollOffset > 80
                      ? 100
                      : isRefreshing
                          ? -70
                          : scrollOffset),
            ),
          ],
        );
      },
    );
  }

  void clickSearchButton(String searchText) {
    Navigator.push(context, FadeRoute(builder: (ocntext) {
      return SearchPage(
        hintText: searchText,
      );
    }));
  }
}

class FixedPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double max;
  final double min;
  final bool isNeedTransform;

  Widget? child;

  FixedPersistentHeaderDelegate({this.max = 0, this.min = 0, this.child, this.isNeedTransform = false});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return isNeedTransform ? Transform.translate(offset: Offset(0, -shrinkOffset), child: child) : child ?? child ?? Container();
  }

  @override
  double get maxExtent => max;

  @override
  double get minExtent => min;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class FixedPersistentHeader extends SliverPersistentHeader {
  FixedPersistentHeader(FixedPersistentHeaderDelegate delegate) : super(pinned: true, floating: false, delegate: delegate);
}
