import 'dart:async';
import 'package:flutter_yanxuan/network/network.dart';
import 'package:flutter_yanxuan/page/home/model/home_model.dart';

// 整体刷新页面网络请求，包括错误，loading，使用steamController
// 其他状态同步刷新，使用provider

class HomeViewModel {
  HomePageModel? _homePageModel;

  StreamController<HomePageModel> _controller = StreamController<HomePageModel>();
  Stream<HomePageModel> get homeDataStream => _controller.stream;

  void requestHomeData() {
    NetWorkHelper.instance.getDio.get("home/data/json").then((value) {
      _homePageModel = HomePageModel.fromJson(value.data);
      if (_homePageModel != null) {
        _controller.add(_homePageModel!);
      }
    }).catchError((error) {
      print(error);
      _controller.addError(error);
    });
  }
}
