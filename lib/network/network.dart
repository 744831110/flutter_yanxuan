import 'package:dio/dio.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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

  late Dio _dio;
  Dio get getDio => _dio;

  NetWorkHelper._() {
    BaseOptions _releaseBaseOption = new BaseOptions(
      baseUrl: localHost,
      connectTimeout: 60 * 1000,
      receiveTimeout: 60 * 1000,
    );
    _dio = new Dio(_releaseBaseOption);
    _dio.interceptors.add(NetworkCheckInterceptor());
    _dio.interceptors.add(LocalDataInterceptor());
    _dio.interceptors.add(NetworkErrorInterceptor());
  }
}

class NetworkCheckInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      DioError error = DioError(requestOptions: options, error: NetworkError(code: NetworkError.NetworkErrorCodeUnreachable));
      handler.reject(error);
    }
    handler.next(options);
  }
}

class LocalDataInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.baseUrl == NetWorkHelper.localHost) {
      //读取本地json返回
      String path = options.path.replaceAll("/", "_");
      path = "assets/json/$path.json";
      try {
        final jsonString = await rootBundle.loadString(path);
        final response = Response(requestOptions: options, data: json.decode(jsonString));
        handler.resolve(response);
      } catch (e) {
        DioError error = DioError(requestOptions: options);
        error.error = NetworkError(code: NetworkError.NetworkErrorCodeReadLocalJson);
        handler.reject(error);
      }
    } else {
      handler.next(options);
    }
  }
}

class NetworkErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    int code = NetworkError.NetworkErrorCodeUnknown;
    switch (err.type) {
      case DioErrorType.cancel:
        code = NetworkError.NetworkErrorCodeCancel;
        break;
      case DioErrorType.sendTimeout:
      case DioErrorType.connectTimeout:
      case DioErrorType.receiveTimeout:
        code = NetworkError.NetworkErrorCodeTimeOut;
        break;
      case DioErrorType.response:
        code = err.response?.statusCode ?? NetworkError.NetworkErrorCodeUnknown;
        break;
      default:
        break;
    }
    err.error = NetworkError(code: code);
    handler.next(err);
  }
}

class NetworkError {
  static const NetworkErrorCodeReadLocalJson = 1;
  static const NetworkErrorCodeUnreachable = 2;
  static const NetworkErrorCodeJsonSerialize = 3;
  static const NetworkErrorCodeTimeOut = 4;
  static const NetworkErrorCodeCancel = 5;
  static const NetworkErrorCodeUnknown = 6;
  final int code;
  NetworkError({required this.code});
}
