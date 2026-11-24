import 'package:dio/dio.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/services/API/api_response.dart';
import 'package:gtra_dashboard/core/services/errors/errormodel.dart';
import 'package:gtra_dashboard/core/services/errors/exception.dart';

Future<ApiResponse<T>> requestHandler<T>(
  Future<Response<dynamic>> Function() request, {
  T Function(Object? data)? fromJson,
}) async {
  try {
    final response = await request();
    final responseBody = response.data;

    if (responseBody == null ||
        (responseBody is String && responseBody.trim().isEmpty)) {
      return ApiResponse<T>(
        data: null,
        message: AppStrings.operationCompleted,
      );
    }

    if (responseBody is List) {
      final parsedData = fromJson != null
          ? fromJson(responseBody)
          : responseBody as T?;
      return ApiResponse<T>(
        data: parsedData,
        message: AppStrings.operationCompleted,
      );
    }

    if (responseBody is Map) {
      final json = Map<String, dynamic>.from(responseBody);
      final rawMessage = json['message'] ?? json['Message'];
      final message = rawMessage is String && rawMessage.trim().isNotEmpty
          ? rawMessage
          : AppStrings.operationCompleted;

      final rawData = json.containsKey('data')
          ? json['data']
          : json.containsKey('Data')
          ? json['Data']
          : json;

      final parsedData = fromJson != null ? fromJson(rawData) : rawData as T?;
      return ApiResponse<T>(data: parsedData, message: message);
    }

    throw ServerException(
      ErrorModel(
        message: AppStrings.unsupportedServerFormat,
        statusCode: response.statusCode ?? 0,
      ),
    );
  } on DioException catch (error) {
    handleDioExceptions(error);
  }
}
