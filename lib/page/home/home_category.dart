import 'package:flutter/material.dart';
import 'package:flutter_yanxuan/common/colors.dart';
import 'package:flutter_yanxuan/page/home/model/home_model.dart';
import 'package:provider/provider.dart';

class HomeCategoryWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeCategoryWidgetState();
  }
}

class _HomeCategoryWidgetState extends State<HomeCategoryWidget> {
  double scrollBarLeft = 0;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() {
        double maxScrollExtent = scrollController.position.maxScrollExtent;
        scrollBarLeft = scrollController.offset / maxScrollExtent * 18;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final module = context.select<HomePageModel, HomeCategoryModule>((value) => value.categoryModule);
    return Column(
      children: [
        categoryWidget(context, module),
        Container(
          height: 20,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(2)),
              child: Container(
                width: 36,
                height: 2,
                color: greyColor,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Transform.translate(
                    offset: Offset(scrollBarLeft, 0),
                    child: Container(
                      width: 18,
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget categoryWidget(BuildContext context, HomeCategoryModule module) {
    return ClipRRect(
      borderRadius: BorderRadius.all(
        Radius.circular(10),
      ),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          controller: scrollController,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180 / 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 15,
            mainAxisExtent: (MediaQuery.of(context).size.width - 20 - 4 * 20) / 5,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: Container(
                child: Column(
                  children: [
                    Image.network(
                      index % 2 == 0 ? module.category[index ~/ 2].picUrl : module.web[(index - 1) ~/ 2].picUrl,
                      width: 45,
                      height: 65,
                    ),
                    Text(
                      index % 2 == 0 ? module.category[index ~/ 2].title : module.web[(index - 1) ~/ 2].title,
                      style: TextStyle(color: Colors.black, fontSize: 11),
                    )
                  ],
                ),
              ),
              onTap: () {
                if (index % 2 == 0) {
                  jumpToCategoryView("1");
                } else {
                  jumpToWebView(module.web[(index - 1) ~/ 2].url);
                }
              },
            );
          },
        ),
      ),
    );
  }

  void jumpToWebView(String url) {
    print("jump to webview url $url");
  }

  void jumpToCategoryView(String categoryId) {
    print("jump to category view $categoryId");
  }
}
