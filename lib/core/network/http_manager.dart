// ignore_for_file: public_member_api_docs, sort_constructors_first
// Flutter imports:
// ignore_for_file: strict_raw_type

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import 'http_operation.dart';


// Project imports:

enum HttpManagerUtilError { error }

class HttpManager {
  BaseOptions _dioOptions(
    String endpoint,
    Map<String, dynamic>? customHeader,
    String? clientCode,
  ) {
    final repositoryHeader = customHeader ?? <String, dynamic>{};
    const timeout = Duration(seconds: 30);

    final options = BaseOptions(
      responseType: ResponseType.plain,
      headers: repositoryHeader,
      contentType: 'application/json',
      validateStatus: (status) => true,
      connectTimeout: timeout,
      receiveTimeout: timeout,
    );

    return options;
  }

  static const _source = 'HttpManagerUtil';

  /// Creates and executes an HTTP request.
  ///
  /// The `endpoint` and `operation` type is the type of operation to be performed.
  ///
  ///
  Future<Response> request({
    required String endpoint,
    HttpOperation method = HttpOperation.get,
    Map<String, dynamic>? body,
    Map<String, dynamic>? customHeader,
    String? clientCode,
  }) async {
    final setDioOptions = _dioOptions(endpoint, customHeader, clientCode);

    final dio = Dio(setDioOptions);

    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      return client;
    };

    Response? response;

    final data = json.encode(body ?? {});

    try {
      switch (method) {
        case HttpOperation.get:
          response = await dio.get(endpoint);
          break;
        case HttpOperation.post:
          response = await dio.post(endpoint, data: data);
          break;
        case HttpOperation.put:
          if (body != null) {
            response = await dio.put(endpoint, data: data);
          } else {
            response = await dio.put(endpoint);
          }
          break;
        case HttpOperation.delete:
          if (body != null) {
            response = await dio.delete(endpoint, data: data);
          } else {
            response = await dio.delete(endpoint);
          }
          break;
        case HttpOperation.patch:
          response = await dio.patch(endpoint, data: data);
          break;
        case HttpOperation.options:
          response =
              await dio.request(endpoint, options: Options(method: 'OPTIONS'));
          break;
        case HttpOperation.head:
          response =
              await dio.request(endpoint, options: Options(method: 'HEAD'));
          break;
      }

      dio.close();

      return response;
    } catch (e, s) {
      log(
        '❌ HTTP request failed',
        name: '$_source.request',
        error: e,
        stackTrace: s,
      );

      rethrow;
    }
  }
}
