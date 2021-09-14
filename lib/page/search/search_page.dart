import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_yanxuan/common/network_stream_builder.dart';
import 'package:flutter_yanxuan/common/view/button.dart';
import 'package:flutter_yanxuan/page/home/home_bar.dart';
import 'package:flutter_yanxuan/page/search/model/search_model.dart';
import 'package:flutter_yanxuan/page/search/viewmodel/search_viewmodel.dart';
import 'package:flutter_yanxuan/router.dart';
import 'package:provider/provider.dart';

typedef SearchTextCallback = void Function(String searchText);

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
  final textEditController = TextEditingController();
  SearchPageContentState contentState = SearchPageContentState.keyword;
  bool hasEnterSearchListPage = false;
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topSearchBar(),
            _getSearchPageContent(),
          ],
        ),
      ),
    );
  }

  Widget _topSearchBar() {
    return _HomeSearchTopBar(
      textEditController: textEditController,
      hintText: widget.hintText,
      state: this.contentState,
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
        return Container();
    }
  }

  Widget _buildFuzzySearchWidget() {
    return NetworkStreamBuilder<FuzzySearchModel>(
      stream: fuzzyViewModel.fuzzySearchDataStream,
      dataBuilder: (context, data, child) {
        return _HomeFuzzySearchPage();
      },
    );
  }

  void startSearch(String searchText) {
    setState(() {
      this.contentState = SearchPageContentState.searchList;
    });
  }
}

class _HomeSearchTopBar extends StatefulWidget {
  final TextEditingController textEditController;
  final String hintText;
  final SearchPageContentState state;
  _HomeSearchTopBar({required this.textEditController, required this.hintText, required this.state});
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
                style: TextStyle(textBaseline: TextBaseline.alphabetic),
                cursorColor: YXColorBlue6,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(fontSize: 14, color: YXColorGray21),
                  hintMaxLines: 1,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onSubmitted: (searchText) {},
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget cancelButton() {
    return TextButton(
      onPressed: clickCancelButton,
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
    return CommonImageButton(
      normalImage: Image(
        fit: BoxFit.fill,
        image: AssetImage("assets/images/icon_nav_back_baritem_normal.png"),
      ),
      onTap: (isSelect) {},
    );
  }

  void clickCancelButton() {
    Navigator.pop(context);
  }

  double calculate() {
    double screenWidth = MediaQuery.of(this.context).size.width;
    double right = isShowCancelButton ? 64 : 10;
    return screenWidth - positionedLeft - right;
  }
}

class _HomeFuzzySearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FuzzySearchModel>(
      builder: (context, data, child) {
        return Expanded(
          child: ListView(
            children: data.data.map((e) => _SearchFuzzyCell(model: e)).toList(),
          ),
        );
      },
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
    print("search text is $searchText");
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
      child: CommonImageButton(
        normalImage: Image(
          image: AssetImage("assets/images/downarrow_ic_normal.png"),
          fit: BoxFit.fill,
        ),
        selectImage: Image(
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
