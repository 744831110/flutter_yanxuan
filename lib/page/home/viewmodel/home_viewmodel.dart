import 'dart:async';
import 'dart:io';
import 'package:flutter_yanxuan/network/network.dart';
import 'package:flutter_yanxuan/page/home/model/home_model.dart';
import 'package:rxdart/rxdart.dart';

// 整体刷新页面网络请求，包括错误，loading，使用steamController
// 其他状态同步刷新，使用provider

class HomeViewModel {
  HomePageModel? _homePageModel;

  StreamController<HomePageModel> _controller = BehaviorSubject<HomePageModel>();
  Stream<HomePageModel> get homeDataStream => _controller.stream;

  List<StreamController<HomeTabModel>> _tabStreamControllers = [];
  List<int> _pageList = [];
  List<HomeTabModel?> _tabModels = [];
  List<Stream<HomeTabModel>> get homeTabStreams => _tabStreamControllers.map((e) => e.stream).toList();

  void requestHomeData() {
    NetWorkHelper.instance.dio.get("home/data/json").then((value) {
      _homePageModel = HomePageModel.fromJson(value.data);
      if (_homePageModel != null) {
        int length = _homePageModel!.recommendTabModelList.length;
        for (int i = 0; i < length; i++) {
          _tabStreamControllers.add(BehaviorSubject<HomeTabModel>());
          _pageList.add(0);
          _tabModels.add(null);
        }
        _controller.add(_homePageModel!);
        this.requestAllTabData(_homePageModel!.recommendTabModelList.map((e) => e.type).toList());
      }
    }).catchError((error) {
      _controller.addError(error);
    });
  }

  void requestAllTabData(List<int> tabType) {
    for (int i = 0; i < tabType.length; i++) {
      int type = tabType[i];
      NetWorkHelper.instance.dio.get("home/tab/json", queryParameters: {"type": type}).then((value) {
        final model = HomeTabModel.fromJson(value.data);
        _tabStreamControllers[i].add(model);
        _pageList[i] = 0;
        _tabModels[i] = model;
        _tabStreamControllers[i].add(model);
      }).catchError((error) {
        _tabStreamControllers[i].addError(error);
      });
    }
  }

  void requestTabData(int index) {
    if (_tabModels[index] != null) {
      final HomeTabModel? model = _tabModels[index];
      final items = model!.items;
      items.addAll(items.reversed);
      model.items = items;
      sleep(Duration(milliseconds: 350));
      _tabStreamControllers[index].add(model);
    }
  }
}
