import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_yanxuan/common/network_stream_builder.dart';
import 'package:flutter_yanxuan/page/search/model/search_model.dart';
import 'package:flutter_yanxuan/page/search/viewmodel/search_viewmodel.dart';

typedef SearchTextCallback = void Function(String searchText);

class SearchPage extends StatefulWidget {
  final String hintText;
  SearchPage({required this.hintText});
  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  List<String> searchRecordList = [];
  final viewModel = SearchViewModel();
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _topSearchBar(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: NetworkStreamBuilder<SearchModel>(
                  stream: viewModel.homeSearchDataStream,
                  errorView: searchContent(),
                  emptyView: searchContent(),
                  builder: (context, data) {
                    return searchContent(model: data);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget searchContent({SearchModel? model}) {
    List<Widget> slivers = [];
    if (searchRecordList.length > 0) {
      slivers.add(
        SliverToBoxAdapter(
          child: HomeSearchHistoricalRecordWidget(
            update: () {
              setState(() {});
            },
            didSelectSearchText: startSearch,
          ),
        ),
      );
    }
    if (model != null) {
      List<Widget> list = [
        SliverPadding(padding: EdgeInsets.symmetric(vertical: 5)),
        _hotSearchWidget(model),
        _hotCategoryTitle(),
        _hotCategoryWidget(model),
      ];
      slivers.addAll(list);
    }
    return CustomScrollView(
      slivers: slivers,
    );
  }

  Widget _hotSearchWidget(SearchModel model) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "热门搜索",
            style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 10,
          ),
          RichText(
              text: TextSpan(
            children: model.hotSearch
                .map(
                  (e) => WidgetSpan(
                    child: _SearchWidgetSpanContent(
                      text: e.searchText,
                      callback: startSearch,
                      isHot: e.isHot,
                    ),
                  ),
                )
                .toList(),
            style: TextStyle(height: 2),
          )),
        ],
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

  SliverGrid _hotCategoryWidget(SearchModel model) {
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

  Widget _topSearchBar() {
    return Container(
      height: 46,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: YXColorGray30))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 15),
              height: 30,
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
                        maxLines: 1,
                        style: TextStyle(textBaseline: TextBaseline.alphabetic),
                        decoration: InputDecoration(border: InputBorder.none, hintText: widget.hintText, hintMaxLines: 1, isDense: true, contentPadding: EdgeInsets.zero),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.transparent),
            ),
            child: Text(
              "取消",
              style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  void startSearch(String searchText) {
    print("search text is $searchText");
  }
}

class HomeSearchHistoricalRecordWidget extends StatefulWidget {
  final VoidCallback update;
  final SearchTextCallback? didSelectSearchText;

  HomeSearchHistoricalRecordWidget({required this.update, this.didSelectSearchText});
  @override
  State<StatefulWidget> createState() {
    return _HomeSearchHistoricalRecordWidgetState();
  }
}

class _HomeSearchHistoricalRecordWidgetState extends State<HomeSearchHistoricalRecordWidget> {
  String recordButtonImagePath = "assets/images/downarrow_ic_normal.png";
  int maxRow = 1;
  List<String> dataList = ["保温杯", "保温", "保温杯", "保温杯", "保", "保温杯", "保温杯", "保温", "保温杯", "保温", "保温杯", "保温" "保温杯", "保温"];
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "历史记录",
              style: TextStyle(fontSize: 17, color: Colors.black, fontWeight: FontWeight.w400),
            ),
            Container(
              width: 30,
              child: TextButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                ),
                child: Image(
                  image: AssetImage("assets/images/commodityorder_icon_delete_normal.png"),
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 30),
              child: RichText(
                maxLines: maxRow,
                text: TextSpan(
                  children: dataList
                      .map(
                        (e) => WidgetSpan(
                          child: _SearchWidgetSpanContent(
                            text: e,
                            callback: didSelectRecord,
                          ),
                        ),
                      )
                      .toList(),
                  style: TextStyle(height: 2),
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  if (recordButtonImagePath == "assets/images/downarrow_ic_normal.png") {
                    recordButtonImagePath = "assets/images/uparrow_ic_normal.png";
                    maxRow = 10;
                  } else {
                    recordButtonImagePath = "assets/images/downarrow_ic_normal.png";
                    maxRow = 1;
                  }
                  widget.update();
                },
                child: Container(
                  width: 20,
                  height: 20,
                  margin: EdgeInsets.only(right: 5, top: 3),
                  child: Image(
                    image: AssetImage(recordButtonImagePath),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  void didSelectRecord(String content) {
    if (widget.didSelectSearchText != null) {
      widget.didSelectSearchText!(content);
    }
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

class CustomWrapDelegate extends FlowDelegate {
  final double lineSpacing; // 行间距
  final double columnSpacing; // 列间距
  final int maxRow; // 最大行数

  CustomWrapDelegate({this.lineSpacing = 0, this.columnSpacing = 0, this.maxRow = 0}); // 最大行

  @override
  void paintChildren(FlowPaintingContext context) {
    double x = 0;
    double y = 0;
    int row = 0;
    //计算每一个子widget的位置
    for (int i = 0; i < context.childCount; i++) {
      var size = context.getChildSize(i) ?? Size.zero;
      var w = x + size.width;
      if (w <= context.size.width) {
        context.paintChild(
          i,
          transform: Matrix4.translationValues(x, y, 0.0),
        );
        x = w + columnSpacing;
      } else {
        row += 1;
        if (maxRow != 0 && row >= maxRow) {
          return;
        }
        x = 0;
        y += size.height + lineSpacing;
        //绘制子widget(有优化)
        context.paintChild(
          i,
          transform: Matrix4.translationValues(x, y, 0.0), //位移
        );
        x = size.width + columnSpacing;
      }
    }
  }

  @override
  Size getSize(BoxConstraints constraints) {
    return Size(double.infinity, 40);
  }

  @override
  bool shouldRepaint(CustomWrapDelegate oldDelegate) {
    return oldDelegate != this || this.maxRow != oldDelegate.maxRow;
  }
}
