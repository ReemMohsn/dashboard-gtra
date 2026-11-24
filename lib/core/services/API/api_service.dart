import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gtra_dashboard/core/constants/api_end_points.dart';

class ApiService {
  ApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiEndPoints.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              sendTimeout: const Duration(seconds: 30),
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              receiveDataWhenStatusError: true,
            ),
          ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
  }

  final Dio _dio;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Duration? receiveTimeout,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: receiveTimeout != null
          ? Options(receiveTimeout: receiveTimeout)
          : null,
    );
  }

  Future<Response<dynamic>> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}
