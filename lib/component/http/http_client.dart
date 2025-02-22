import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart' as getx;
import 'package:imboy/component/extension/device_ext.dart';
import 'package:imboy/component/helper/func.dart';
import 'package:imboy/component/helper/jwt.dart';
import 'package:imboy/component/http/http_exceptions.dart';
import 'package:imboy/config/const.dart';
import 'package:imboy/store/repository/user_repo_local.dart';

import 'http_config.dart';
import 'http_parse.dart';
import 'http_response.dart';
import 'http_transformer.dart';

Future<Map<String, dynamic>> defaultHeaders() async {
  return {
    'vsn': appVsn,
    'did': await DeviceExt.did,
    'cos': Platform.operatingSystem,
    'cosv': Platform.operatingSystemVersion,
  };
}

class HttpClient {
  static HttpClient get client => getx.Get.find();
  late Dio _dio;

  HttpClient({BaseOptions? options, HttpConfig? dioConfig}) {
    options ??= BaseOptions(
      baseUrl: dioConfig?.baseUrl ?? "",
      contentType: 'application/x-www-form-urlencoded',
      connectTimeout: dioConfig?.connectTimeout,
      sendTimeout: dioConfig?.sendTimeout,
      receiveTimeout: dioConfig?.receiveTimeout,
    )..headers = dioConfig?.headers;

    _dio = Dio(options);

    if (RECORD_LOG) {
      _dio.interceptors.add(LogInterceptor(
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: false,
          request: false,
          requestBody: true));
    }
    if (dioConfig?.interceptors?.isNotEmpty ?? false) {
      _dio.interceptors.addAll(dioConfig!.interceptors!);
    }
    _dio.httpClientAdapter = DefaultHttpClientAdapter();
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    if (dioConfig?.proxy?.isNotEmpty ?? false) {
      setProxy(dioConfig!.proxy!);
    }
  }

  setProxy(String proxy) {
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      // config the http client
      client.findProxy = (uri) {
        // proxy all request to localhost:8888
        return "PROXY $proxy";
      };
      return null;
      // you can also create a HttpClient to dio
      // return HttpClient();
    };
  }

  Future<void> _setDefaultConfig() async {
    if (_dio.options.baseUrl == "") {
      _dio.options.baseUrl = API_BASE_URL;
    }
    String tk = UserRepoLocal.to.accessToken;
    bool notRTK = !_dio.options.headers.containsKey(Keys.refreshtokenKey);
    if (strNoEmpty(tk) && notRTK) {
      _dio.options.headers[Keys.tokenKey] = tk;
      if (tokenExpired(tk)) {
        await UserRepoLocal.to.refreshAccessToken();
      }
    }
    Map<String, dynamic> headers = await defaultHeaders();
    _dio.options.headers.addAll(headers);
  }

  Future<IMBoyHttpResponse> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      _setDefaultConfig();
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        return handleException(NetworkException());
      }
      var response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      debugPrint("> on Exception: $e");
      return handleException(e);
    }
  }

  Future<IMBoyHttpResponse> post(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    HttpTransformer? httpTransformer,
  }) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // getx.Get.snackbar("Tips", "网络连接异常get");
      return handleException(NetworkException());
    }
    try {
      _setDefaultConfig();
      var response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<IMBoyHttpResponse> patch(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      _setDefaultConfig();
      var response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<IMBoyHttpResponse> delete(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      _setDefaultConfig();
      var response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<IMBoyHttpResponse> put(
    String uri, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      _setDefaultConfig();
      var response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return handleResponse(response, httpTransformer: httpTransformer);
    } on Exception catch (e) {
      return handleException(e);
    }
  }

  Future<Response> download(
    String urlPath,
    savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    data,
    Options? options,
    HttpTransformer? httpTransformer,
  }) async {
    try {
      _setDefaultConfig();
      var response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
        options: data,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
