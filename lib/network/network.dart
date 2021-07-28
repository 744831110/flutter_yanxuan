import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NetWorkHelper {
  factory NetWorkHelper() => _getInstance();

  static NetWorkHelper get instance => _getInstance();

  static NetWorkHelper? _instance;

  static NetWorkHelper _getInstance() {
    if (_instance == null) {
      _instance = new NetWorkHelper._();
    }
    return _instance!;
  }

  static const String localHost = "localhost";

  final localDataMap = Map();

  late Dio _dio;
  NetWorkHelper._() {
    BaseOptions _releaseBaseOption = new BaseOptions(
      baseUrl: localHost,
      connectTimeout: 60 * 1000,
      receiveTimeout: 60 * 1000,
    );
    _dio = new Dio(_releaseBaseOption);
    _dio.interceptors.add(LocalDataInterceptor());
  }

  Dio getDio() {
    return _dio;
  }
}

class LocalDataInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.baseUrl == NetWorkHelper.localHost) {
      //读取本地json返回
      final path = options.path.replaceAll("/", "_");
      try {
        final json = await rootBundle.loadString(path);
        final response = Response(requestOptions: options, data: json);
        handler.resolve(response);
      } catch (e) {
        DioError error = DioError(requestOptions: options);
        handler.reject(error);
      }
    }
    handler.next(options);
  }
}
