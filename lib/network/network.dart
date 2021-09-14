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
  Dio get dio => _dio;

  late Dio _yxDio;
  Dio get yxDio => _yxDio;

  NetWorkHelper._() {
    BaseOptions _releaseBaseOption = new BaseOptions(baseUrl: localHost, connectTimeout: 60 * 1000, receiveTimeout: 60 * 1000, headers: {
      "Cookie":
          "yx_aui=ad574a64-cdca-43aa-ab18-dc0048a37884; yx_stat_seesionId=ad574a64-cdca-43aa-ab18-dc0048a378841624592226597; yx_stat_seqList=v_a175ec6d43%7Cv_a175ec6d43%3B-1; yx_s_device=cb18109-401a-2a1e-9b3e-3ec9b3ee77; yx_s_tid=tid_web_389c13839ab6457793060c597e23651b_e9d6823eb_1; mail_psc_fingerprint=a154cdec1427352a1f94d126b5c08065; yx_but_id=4a1698afcb5048c4b092bf75ecd667928f1e9528e3696fa1_v1_nl;"
    });
    _dio = new Dio(_releaseBaseOption);
    _dio.interceptors.add(NetworkCheckInterceptor());
    _dio.interceptors.add(LocalDataInterceptor());
    _dio.interceptors.add(NetworkErrorInterceptor());

    BaseOptions _yxBaseOption = new BaseOptions(baseUrl: "https://m.you.163.com/", connectTimeout: 60 * 1000, receiveTimeout: 60 * 1000, headers: {
      "Cookie":
          "yx_aui=ad574a64-cdca-43aa-ab18-dc0048a37884; yx_stat_seesionId=ad574a64-cdca-43aa-ab18-dc0048a378841624592226597; yx_stat_seqList=v_a175ec6d43%7Cv_a175ec6d43%3B-1; yx_s_device=cb18109-401a-2a1e-9b3e-3ec9b3ee77; yx_s_tid=tid_web_389c13839ab6457793060c597e23651b_e9d6823eb_1; mail_psc_fingerprint=a154cdec1427352a1f94d126b5c08065; yx_but_id=4a1698afcb5048c4b092bf75ecd667928f1e9528e3696fa1_v1_nl;"
    });
    _yxDio = new Dio(_yxBaseOption);
    _yxDio.interceptors.add(NetworkCheckInterceptor());
    _yxDio.interceptors.add(NetworkErrorInterceptor());
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
