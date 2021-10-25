import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_yanxuan/common/network_stream_builder.dart';
import 'package:flutter_yanxuan/common/view/button.dart';
import 'package:flutter_yanxuan/page/home/home_bar.dart';
import 'package:flutter_yanxuan/page/home/home_recommend.dart';
import 'package:flutter_yanxuan/page/search/model/search_model.dart';
import 'package:flutter_yanxuan/page/search/viewmodel/search_viewmodel.dart';
import 'package:flutter_yanxuan/router.dart';
import 'package:provider/provider.dart';

typedef SearchTextCallback = void Function(String searchText);
typedef SortTypeCallback = void Function(int sortType);
typedef RefreshSearchListCallback = void Function(Map<int, List<int>> subType);

enum SearchPageContentState {
  keyword,
  fuzzySearch,
  searchList,
}

class SearchPage extends StatefulWidget {
  final String hintText;
  SearchPage({required this.hintText});
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  final fuzzyViewModel = FuzzySearchViewModel();
  final searchListViewModel = SerchListViewModel();
  final textEditController = TextEditingController();
  String? searchText;
  SearchPageContentState contentState = SearchPageContentState.keyword;
  @override
  void initState() {
    super.initState();
    textEditController.addListener(() {
      setState(() {
        if (textEditController.text.isNotEmpty) {
          this.contentState = SearchPageContentState.fuzzySearch;
        }
      });
      fuzzyViewModel.requestFuzzySearchData(textEditController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    SearchPageRouter route = ModalRoute.of(context) as SearchPageRouter;
    route.isCupertinoPop = true;
    return ChangeNotifierProvider(
      create: (_) => SearchListChangeNotifer(),
      child: Scaffold(
        endDrawer: SearchDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              _topSearchBar(),
              _getSearchPageContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topSearchBar() {
    return _HomeSearchTopBar(
      textEditController: textEditController,
      searchCallback: startSearch,
      hintText: widget.hintText,
      state: this.contentState,
      backButtonCallback: () {
        Navigator.pop(context);
      },
      cancelButtonCallback: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _getSearchPageContent() {
    switch (contentState) {
      case SearchPageContentState.keyword:
        return _HomeKeywordPage(
          searchCallback: startSearch,
        );
      case SearchPageContentState.fuzzySearch:
        return _buildFuzzySearchWidget();
      case SearchPageContentState.searchList:
        return _buildSearchListWidget();
    }
  }

  Widget _buildFuzzySearchWidget() {
    return NetworkStreamBuilder<FuzzySearchModel>(
      stream: fuzzyViewModel.fuzzySearchDataStream,
      dataBuilder: (context, data, child) {
        return _HomeFuzzySearchPage(
          searchCallback: startSearch,
        );
      },
    );
  }

  Widget _buildSearchListWidget() {
    return _HomeSearchListPage(
      listStream: this.searchListViewModel.searchListModelStream,
      filterTypeStream: this.searchListViewModel.searchFilterTypeStream,
      refreshListCallback: (Map<int, List<int>> subtypes) {
        if (this.searchText != null) {
          searchListViewModel.requestSearchFilterTypes(this.searchText!, subtypes: subtypes);
        }
      },
    );
  }

  void startSearch(String searchText) {
    setState(() {
      this.searchText = searchText;
      textEditController.text = searchText;
      this.searchListViewModel.requestSearchFilterTypes(searchText);
      this.searchListViewModel.requestSearchList(searchText);
      this.contentState = SearchPageContentState.searchList;
    });
  }
}

class _HomeSearchTopBar extends StatefulWidget {
  final TextEditingController textEditController;
  final String hintText;
  final SearchPageContentState state;
  final VoidCallback? backButtonCallback;
  final VoidCallback? cancelButtonCallback;
  final SearchCallback searchCallback;
  _HomeSearchTopBar({required this.textEditController, required this.hintText, required this.state, this.backButtonCallback, this.cancelButtonCallback, required this.searchCallback});
  @override
  State<StatefulWidget> createState() {
    return _HomeSearchTopBarState();
  }
}

class _HomeSearchTopBarState extends State<_HomeSearchTopBar> {
  double positionedLeft = 15.0;
  bool isShowCancelButton = true;
  EdgeInsets cancelButtonPadding = EdgeInsets.zero;

  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        isShowCancelButton = widget.state == SearchPageContentState.keyword || widget.state == SearchPageContentState.fuzzySearch;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.state == SearchPageContentState.searchList) {
      positionedLeft = 40.0;
    }
    isShowCancelButton = widget.state == SearchPageContentState.keyword || widget.state == SearchPageContentState.fuzzySearch;
    return Container(
      height: 46,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: YXColorGray1, width: 0.7))),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 5.0,
            child: backButton(),
          ),
          AnimatedPositioned(
            left: positionedLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                searchTextField(),
                Container(
                  width: 64,
                  child: AnimatedPadding(
                    padding: EdgeInsets.zero,
                    child: cancelButton(),
                    duration: Duration(milliseconds: 300),
                  ),
                )
              ],
            ),
            duration: Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget searchTextField() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: 30,
      width: calculate(),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: YXColorGray16),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Image(
              image: AssetImage("assets/images/nav_search_ic_normal.png"),
              width: 15,
              height: 15,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 5, right: 10, bottom: 2),
              child: TextField(
                controller: widget.textEditController,
                maxLines: 1,
                focusNode: _focusNode,
                style: TextStyle(textBaseline: TextBaseline.alphabetic, fontSize: 14),
                cursorColor: YXColorBlue6,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(fontSize: 14, color: YXColorGray21),
                  hintMaxLines: 1,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (searchText) {
                  if (searchText.isEmpty) {
                    widget.searchCallback(widget.hintText);
                  } else {
                    widget.searchCallback(searchText);
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget cancelButton() {
    return TextButton(
      onPressed: () {
        if (widget.cancelButtonCallback != null) {
          widget.cancelButtonCallback!();
        }
      },
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
      ),
      child: Text(
        "取消",
        style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w300),
      ),
    );
  }

  Widget backButton() {
    return CommonButton(
      child: Image(
        fit: BoxFit.fill,
        image: AssetImage("assets/images/icon_nav_back_baritem_normal.png"),
      ),
      onTap: (isSelect) {
        if (widget.backButtonCallback != null) {
          widget.backButtonCallback!();
        }
      },
    );
  }

  double calculate() {
    double screenWidth = MediaQuery.of(this.context).size.width;
    double right = isShowCancelButton ? 64 : 10;
    return screenWidth - positionedLeft - right;
  }
}

class SearchDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final result = context.read<SearchListChangeNotifer>().result;
    return SizedBox(
      width: MediaQuery.of(context).size.width - 100,
      child: Drawer(
        child: ListView.builder(
          itemBuilder: (context, index) {
            if (index == 0) {
              return SearchDrawerPriceCell();
            } else {
              return SearchDrawerExpandCell(model: result.fliterTypes[index - 1]);
            }
          },
          itemCount: result.fliterTypes.length + 1,
        ),
      ),
    );
  }
}

class SearchDrawerPriceCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double textfieldWidth = (MediaQuery.of(context).size.width - 100 - 40 - 15) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "价格区间",
            style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w300),
          ),
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            priceTextField("最低价", textfieldWidth),
            Container(width: 15, height: 1, color: Colors.black),
            priceTextField("最高价", textfieldWidth),
          ],
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  Widget priceTextField(String hintText, double width) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.all(Radius.circular(2)),
      ),
      width: width,
      padding: EdgeInsets.symmetric(vertical: 3),
      child: TextField(
        textAlign: TextAlign.center,
        style: TextStyle(textBaseline: TextBaseline.alphabetic, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 14, color: YXColorGray21),
          hintMaxLines: 1,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class SearchDrawerExpandCell extends StatefulWidget {
  SearchDrawerExpandCell({required this.model});
  final SearchFilterTypeModel model;
  @override
  State<StatefulWidget> createState() {
    return SearchDrawerExpandCellState();
  }
}

class SearchDrawerExpandCellState extends State<SearchDrawerExpandCell> {
  bool isExpand = false;
  @override
  Widget build(BuildContext context) {
    List<SearchFilterSubtypeModel> list = widget.model.filterSubtypes;
    final selectSubtypeList = context.read<SearchListChangeNotifer>().selectSubTypes[widget.model.filterType];
    if (!isExpand && widget.model.filterSubtypes.length > 3) {
      list = widget.model.filterSubtypes.sublist(0, 3);
    }

    final itemWidth = (MediaQuery.of(context).size.width - 100 - 40) / 3;

    final selectString = widget.model.filterSubtypes
        .where((e) {
          return selectSubtypeList?.contains(e.subtype) ?? false;
        })
        .map((e) => e.describe)
        .toList()
        .join("，");

    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 15),
                  child: Text(
                    "${widget.model.describe} ${selectString.isEmpty ? "" : "($selectString)"}",
                    style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w300),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              widget.model.filterSubtypes.length > 3
                  ? SizedBox(
                      height: 30,
                      child: CommonButton(
                        child: Text("up"),
                        onTap: (_) {
                          setState(() {
                            isExpand = !isExpand;
                          });
                        },
                      ))
                  : Container()
            ],
          ),
          Wrap(
            spacing: 10,
            children: list
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      final notifer = context.read<SearchListChangeNotifer>();
                      if (!(selectSubtypeList?.contains(e.subtype) ?? false)) {
                        notifer.addSelectSubtype(widget.model.filterType, e.subtype);
                      } else {
                        notifer.removeFromSelectSubtype(widget.model.filterType, e.subtype);
                      }
                      setState(() {});
                    },
                    child: Container(
                      width: itemWidth,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), borderRadius: BorderRadius.all(Radius.circular(2))),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: Center(
                        child: Text(
                          "${(selectSubtypeList?.contains(e.subtype) ?? false) ? "✓ " : ""}${e.describe}",
                          style: TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _HomeKeywordPage extends StatefulWidget {
  final SearchCallback searchCallback;
  _HomeKeywordPage({required this.searchCallback});
  @override
  State<StatefulWidget> createState() {
    return _HomeKeywordPageState();
  }
}

class _HomeKeywordPageState extends State<_HomeKeywordPage> {
  final viewModel = SearchKeywordViewModel();
  List<String> searchRecordList = [];
  int maxRow = 1;

  @override
  void initState() {
    super.initState();
    viewModel.getPreferenceData().then((value) {
      setState(() {
        searchRecordList = value;
      });
    });
    viewModel.requestSearchData();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: NetworkStreamBuilder<SearchModel>(
          stream: viewModel.homeSearchDataStream,
          snapShotBuilder: (context, snapshot, child) {
            return CustomScrollView(
              slivers: [
                _buildHistoricalRecord(this.searchRecordList),
                SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
                _hotSearchWidget(snapshot.data),
                _hotCategoryTitle(),
                _hotCategoryWidget(snapshot.data),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoricalRecord(List<String> searchRecordList) {
    if (searchRecordList.length > 0) {
      return SliverToBoxAdapter(
        child: _HomeSearchKeywordWidget(
          title: "历史记录",
          keywordList: searchRecordList.map((e) => SearchKeywordModel.record(e)).toList(),
          searchTextCallback: startSearch,
          expandCallback: (isselect) {
            setState(() {
              maxRow = isselect ? 10 : 1;
            });
          },
          maxRow: maxRow,
          deleteCallback: () {},
        ),
      );
    } else {
      return SliverToBoxAdapter(child: Container());
    }
  }

  Widget _hotSearchWidget(SearchModel? model) {
    return SliverToBoxAdapter(
      child: model == null
          ? Container()
          : _HomeSearchKeywordWidget(
              title: "热门搜索",
              keywordList: model.hotSearch,
              isShowDeleteButton: false,
              isShowExpandButton: false,
              searchTextCallback: startSearch,
              maxRow: 10,
            ),
    );
  }

  SliverPadding _hotCategoryTitle() {
    return SliverPadding(
      padding: EdgeInsets.only(top: 10),
      sliver: SliverToBoxAdapter(
        child: Text(
          "热门分类",
          style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _hotCategoryWidget(SearchModel? model) {
    if (model == null) {
      return SliverToBoxAdapter(child: Container());
    }
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final categoryModel = model.secondCategory[index];
          return GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Image(image: NetworkImage(categoryModel.picUrl)),
                Text(
                  "${categoryModel.title}",
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),
          );
        },
        childCount: model.secondCategory.length,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
    );
  }

  void deleteHistoricalRecord() {
    setState(() {
      this.searchRecordList = [];
    });
    viewModel.removeAllRecord();
  }

  void startSearch(String searchText) {
    widget.searchCallback(searchText);
  }
}

class _HomeSearchKeywordWidget extends StatelessWidget {
  final String title;
  final void Function(bool isSelect)? expandCallback;
  final VoidCallback? deleteCallback;
  final SearchTextCallback? searchTextCallback;
  final List<SearchKeywordModel> keywordList;
  final bool isShowExpandButton;
  final bool isShowDeleteButton;
  final int maxRow;

  _HomeSearchKeywordWidget(
      {required this.title, this.expandCallback, this.deleteCallback, this.searchTextCallback, required this.keywordList, this.isShowDeleteButton = true, this.isShowExpandButton = true, this.maxRow = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w400),
            ),
            _buildDeleteButton()
          ],
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: double.infinity,
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              _buildKeyword(),
              Positioned(
                right: 0,
                top: 0,
                child: _buildExpandButton(),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDeleteButton() {
    return Visibility(
      visible: isShowDeleteButton,
      child: Container(
        width: 30,
        child: TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            padding: MaterialStateProperty.all(EdgeInsets.zero),
          ),
          child: Image(
            image: AssetImage("assets/images/commodityorder_icon_delete_normal.png"),
          ),
          onPressed: () {
            if (this.deleteCallback != null) {
              this.deleteCallback!();
            }
          },
        ),
      ),
    );
  }

  Widget _buildExpandButton() {
    return Visibility(
      visible: isShowExpandButton,
      child: CommonButton(
        child: Image(
          image: AssetImage("assets/images/downarrow_ic_normal.png"),
          fit: BoxFit.fill,
        ),
        selectChild: Image(
          image: AssetImage("assets/images/uparrow_ic_normal.png"),
          fit: BoxFit.fill,
        ),
        width: 20,
        height: 20,
        margin: EdgeInsets.only(right: 5, top: 3),
        onTap: (isSelect) {
          if (this.expandCallback != null) {
            this.expandCallback!(isSelect);
          }
        },
      ),
    );
  }

  Widget _buildKeyword() {
    return Padding(
      padding: EdgeInsets.only(right: 30),
      child: RichText(
        maxLines: maxRow,
        text: TextSpan(
          children: keywordList
              .map(
                (e) => WidgetSpan(
                  child: _SearchWidgetSpanContent(
                    isHot: e.isHot,
                    text: e.searchText,
                    callback: didSelectRecord,
                  ),
                ),
              )
              .toList(),
          style: TextStyle(height: 2),
        ),
      ),
    );
  }

  void didSelectRecord(String content) {
    if (this.searchTextCallback != null) {
      this.searchTextCallback!(content);
    }
  }
}

class _HomeFuzzySearchPage extends StatelessWidget {
  final SearchCallback searchCallback;
  _HomeFuzzySearchPage({required this.searchCallback});
  @override
  Widget build(BuildContext context) {
    return Consumer<FuzzySearchModel>(
      builder: (context, data, child) {
        return Expanded(
          child: ListView(
            children: data.data
                .map(
                  (e) => GestureDetector(
                    onTap: () {
                      searchCallback(e.title);
                    },
                    child: _SearchFuzzyCell(model: e),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}

class _SearchFuzzyCell extends StatelessWidget {
  final FuzzySearchItemModel model;
  _SearchFuzzyCell({required this.model});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: YXColorGray1, width: 0.7))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${model.title}", style: TextStyle(fontSize: 14, color: Colors.black)),
          Wrap(
            spacing: 5,
            children: model.describes.map(
              (describe) {
                return ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 55),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(14)), color: YXColorGray12),
                    height: 28,
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "$describe",
                          style: TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          )
        ],
      ),
    );
  }
}

class _SearchWidgetSpanContent extends StatelessWidget {
  final bool isHot;
  final SearchTextCallback? callback;
  final String text;
  _SearchWidgetSpanContent({this.isHot = false, this.callback, this.text = ""});

  @override
  Widget build(BuildContext context) {
    List<Widget> rowChildren = [];
    if (isHot) {
      rowChildren.add(Padding(
        padding: EdgeInsets.only(right: 2),
        child: Image(
          image: AssetImage("assets/images/icon_hot_normal.png"),
        ),
      ));
    }
    rowChildren.add(Text(
      "$text",
      style: TextStyle(color: isHot ? redTextColor : Colors.black, fontSize: 14, backgroundColor: YXColorGray12, fontWeight: FontWeight.w300),
    ));
    return GestureDetector(
      onTap: didselect,
      child: Container(
        padding: EdgeInsets.only(left: isHot ? 7 : 10, right: 10),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: rowChildren,
        ),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(13)), color: YXColorGray12),
        height: 26,
      ),
    );
  }

  void didselect() {
    if (this.callback != null) {
      this.callback!(text);
    }
  }
}

class _HomeSearchListPage extends StatefulWidget {
  final Stream<SearchFilterTypeResult> filterTypeStream;
  final Stream<SearchListModel> listStream;
  final RefreshSearchListCallback refreshListCallback;
  _HomeSearchListPage({required this.filterTypeStream, required this.refreshListCallback, required this.listStream});
  @override
  State<StatefulWidget> createState() {
    return _HomeSearchListPageState();
  }
}

class _HomeSearchListPageState extends State<_HomeSearchListPage> {
  @override
  Widget build(BuildContext context) {
    return NetworkStreamBuilder<SearchFilterTypeResult>(
      stream: widget.filterTypeStream,
      needProvider: false,
      dataBuilder: (ctx, result, _) {
        context.read<SearchListChangeNotifer>().setFilterTypeResult(result);
        return Expanded(
          child: Container(
            child: Stack(
              children: [
                Positioned.fill(
                    top: 83,
                    child: NetworkStreamBuilder<SearchListModel>(
                      stream: widget.listStream,
                      needProvider: false,
                      dataBuilder: (c, listResult, _) {
                        return StaggeredGridView.countBuilder(
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          itemCount: listResult.items.length,
                          itemBuilder: (context, index) {
                            return HomeTabItemWidget(model: listResult.items[index]);
                          },
                          staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                        );
                      },
                    )),
                _HomeSearchListConditionWidget(
                  confirmCallback: widget.refreshListCallback,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeSearchListConditionWidget extends StatefulWidget {
  final RefreshSearchListCallback confirmCallback;
  _HomeSearchListConditionWidget({required this.confirmCallback});
  @override
  State<StatefulWidget> createState() {
    return _HomeSearchListConditionWidgetState();
  }
}

class _HomeSearchListConditionWidgetState extends State<_HomeSearchListConditionWidget> {
  @override
  Widget build(BuildContext context) {
    return alignmentWithFill(
      context.watch<SearchListChangeNotifer>().selectType != -1,
      child: Column(
        children: [
          _HomeSearchListSortWidget(
            filterCallback: () {
              Scaffold.of(context).openEndDrawer();
            },
            sortTypeCallback: (type) {},
          ),
          searchFilterWidget(context.watch<SearchListChangeNotifer>().selectType != -1),
        ],
      ),
    );
  }

  void changeSortType(int sortType) {}

  Widget alignmentWithFill(bool isFill, {required Widget child}) {
    if (isFill) {
      return Positioned.fill(
        left: 0,
        top: 0,
        child: child,
      );
    } else {
      return Align(
        alignment: Alignment.topCenter,
        widthFactor: 1,
        child: child,
      );
    }
  }

  Widget searchFilterWidget(bool isFill) {
    if (isFill) {
      return Expanded(
        child: _HomeSearchFilterWidget(
          confirmCallBack: didClickConfirm,
        ),
      );
    } else {
      return _HomeSearchFilterWidget(
        confirmCallBack: didClickConfirm,
      );
    }
  }

  void didClickConfirm() {
    final notifer = context.read<SearchListChangeNotifer>();
    widget.confirmCallback(notifer.selectSubTypes);
  }
}

class _HomeSearchListSortWidget extends StatefulWidget {
  final SortTypeCallback sortTypeCallback;
  final VoidCallback filterCallback;
  _HomeSearchListSortWidget({required this.sortTypeCallback, required this.filterCallback});
  @override
  State<StatefulWidget> createState() {
    return _HomeSearchListSortWidgetState();
  }
}

class _HomeSearchListSortWidgetState extends State<_HomeSearchListSortWidget> {
  List<bool> sortButtonSelect = [true, false, false, false, false];
  List<bool> isDownSortButton = [false, false];
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildSortWidget("综合", index: 0),
        _buildSortWidget("销量", index: 1),
        _buildUpDownSortWidget("价格", index: 2, isDownIndex: 0),
        _buildUpDownSortWidget("上新", index: 3, isDownIndex: 1),
        _buildFilterButton(4),
      ],
    );
  }

  Widget _buildSortWidget(String title, {required int index}) {
    return Expanded(
      flex: 1,
      child: TextButton(
        onPressed: () {
          setState(() {
            if (!sortButtonSelect[index]) {
              sortButtonSelect.fillRange(0, sortButtonSelect.length, false);
              sortButtonSelect[index] = true;
              changeSortType(index);
            }
          });
        },
        child: Text(
          title,
          style: TextStyle(fontSize: 14, color: sortButtonSelect[index] ? redTextColor : Colors.black, fontWeight: FontWeight.normal),
        ),
      ),
    );
  }

  Widget _buildUpDownSortWidget(String title, {required int index, required int isDownIndex}) {
    String imageUrl = sortButtonSelect[index]
        ? isDownSortButton[isDownIndex]
            ? "assets/images/ic_search_arrow_down_normal.png"
            : "assets/images/ic_search_arrow_up_normal.png"
        : "assets/images/ic_search_arrow_normal.png";
    return Expanded(
      flex: 1,
      child: TextButton(
        onPressed: () {
          setState(() {
            if (sortButtonSelect[index]) {
              isDownSortButton[isDownIndex] = !isDownSortButton[isDownIndex];
            } else {
              sortButtonSelect.fillRange(0, sortButtonSelect.length, false);
              sortButtonSelect[index] = true;
              isDownSortButton[isDownIndex] = false;
            }
            changeSortType(index + (isDownSortButton[isDownIndex] ? 1 : 0));
          });
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, color: sortButtonSelect[index] ? redTextColor : Colors.black, fontWeight: FontWeight.normal),
            ),
            SizedBox(width: 5),
            Image(image: AssetImage(imageUrl))
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(int index) {
    String imageUrl = sortButtonSelect[index] ? "assets/images/ic_search_screen_select.png" : "assets/images/ic_search_screen_select.png";
    return Expanded(
      flex: 1,
      child: TextButton(
        onPressed: didClickFilterButton,
        child: Row(
          children: [
            Text(
              "筛选",
              style: TextStyle(fontSize: 14, color: sortButtonSelect[index] ? redTextColor : Colors.black, fontWeight: FontWeight.normal),
            ),
            Image(image: AssetImage(imageUrl))
          ],
        ),
      ),
    );
  }

  void changeSortType(int type) {
    widget.sortTypeCallback(type);
  }

  void didClickFilterButton() {
    widget.filterCallback();
  }
}

class _HomeSearchFilterWidget extends StatefulWidget {
  final VoidCallback confirmCallBack;
  _HomeSearchFilterWidget({required this.confirmCallBack});
  @override
  State<StatefulWidget> createState() {
    return _HomeSearchFilterWidgetState();
  }
}

class _HomeSearchFilterWidgetState extends State<_HomeSearchFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildContent(),
    );
  }

  List<Widget> _buildContent() {
    final notifer = context.watch<SearchListChangeNotifer>();
    final selectType = notifer.selectType;
    final result = notifer.result;
    final typeList = result.fliterTypes.map((e) => e.describe).toList();
    if (notifer.selectSubTypes.isNotEmpty) {
      notifer.selectSubTypes.forEach((type, subtypes) {
        final typeModel = result.fliterTypes.where((element) => element.filterType == type).first;
        final describeList = typeModel.filterSubtypes.where((element) => subtypes.contains(element.subtype)).map((e) => e.describe);
        if (describeList.isNotEmpty) {
          final describe = describeList.join(",");
          final index = typeList.indexOf(typeModel.describe);
          typeList.replaceRange(index, index + 1, [describe]);
        }
      });
    }
    List<Widget> widgets = [];
    widgets.add(Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        children: typeList.sublist(0, 3).asMap().keys.map((e) {
          return _typeItemWidget(typeList[e], result.fliterTypes[e].filterType);
        }).toList(),
      ),
    ));
    if (selectType != -1) {
      widgets.add(_buildSubtypeWidget(selectType, result.fliterTypes[selectType].filterSubtypes));
      widgets.add(_buildSubtypeControlButton());
      widgets.add(_maskWidget());
    }
    return widgets;
  }

  Widget _typeItemWidget(String title, int type) {
    bool isExpand = type == context.watch<SearchListChangeNotifer>().selectType;
    return Expanded(
      flex: 1,
      child: Container(
        height: 35,
        child: GestureDetector(
          onTap: () {
            didSelectItem(type);
          },
          child: Container(
            margin: EdgeInsets.only(left: 5, right: 5, bottom: isExpand ? 0 : 10),
            height: 25,
            decoration: BoxDecoration(
              color: YXColorGray16,
              borderRadius: isExpand ? BorderRadius.only(topLeft: Radius.circular(12.5), topRight: Radius.circular(12.5)) : BorderRadius.all(Radius.circular(12.5)),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 90),
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 12, color: isExpand ? redTextColor : Colors.black, fontWeight: FontWeight.normal),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Image(
                      image: AssetImage(isExpand ? "assets/images/icon_common_arrow_up.png" : "assets/images/icon_common_arrow_down.png"),
                      width: 12,
                      height: 12,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtypeWidget(int selectType, List<SearchFilterSubtypeModel> subtypeList) {
    final list = context.read<SearchListChangeNotifer>().selectSubTypes[selectType];
    return Container(
      width: double.infinity,
      color: YXColorGray16,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        direction: Axis.horizontal,
        children: subtypeList.map((e) {
          return CommonButton(
            isInnerControlSelectState: false,
            isSelect: list?.contains(e.subtype) ?? false,
            width: (MediaQuery.of(context).size.width - 40) / 2,
            height: 50,
            onTap: (isSelecct) {
              didSelectSubtype(isSelecct, selectType, e.subtype);
            },
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                e.describe,
                style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.normal),
              ),
            ),
            selectChild: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(image: AssetImage("assets/images/icon_search_check_normal.png"), width: 12, height: 12),
                  SizedBox(width: 5),
                  Text(
                    e.describe,
                    style: TextStyle(fontSize: 12, color: redTextColor, fontWeight: FontWeight.normal),
                  )
                ],
              ),
            ),
            initIsSelect: list == null ? false : list.contains(e.subtype),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubtypeControlButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 1,
          child: CommonButton(
            height: 40,
            decoration: BoxDecoration(color: Colors.white),
            onTap: (_) => didSelectReset(),
            child: Center(
              child: Text(
                "重置",
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: CommonButton(
            height: 40,
            decoration: BoxDecoration(color: Colors.red),
            onTap: (_) => didSelectConfirm(),
            child: Center(
              child: Text(
                "确定",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _maskWidget() {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: Container(color: YXColorBlackAlpha50),
        onTap: () {
          final notifer = context.read<SearchListChangeNotifer>();
          notifer.selectType = -1;
        },
      ),
    );
  }

  void didSelectItem(int type) {
    final notifier = context.read<SearchListChangeNotifer>();
    if (notifier.selectType == type) {
      notifier.selectType = -1;
    } else {
      notifier.selectType = type;
    }
  }

  void didSelectSubtype(bool isSelect, int type, int subType) {
    final notifer = context.read<SearchListChangeNotifer>();
    if (!isSelect) {
      notifer.addSelectSubtype(type, subType);
    } else {
      notifer.removeFromSelectSubtype(type, subType);
    }
  }

  void didSelectReset() {
    final notifier = context.read<SearchListChangeNotifer>();
    notifier.removeAllSelectSubtype(notifier.selectType);
  }

  void didSelectConfirm() {
    widget.confirmCallBack();
    final notifer = context.read<SearchListChangeNotifer>();
    notifer.selectType = -1;
  }
}
