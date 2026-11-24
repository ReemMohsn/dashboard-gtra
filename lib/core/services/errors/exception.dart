import 'package:dio/dio.dart';
import 'package:gtra_dashboard/core/constants/app_strings.dart';
import 'package:gtra_dashboard/core/services/errors/errormodel.dart';

class ServerException implements Exception {
  const ServerException(this.error);

  final ErrorModel error;

  String get message => error.message;

  @override
  String toString() => message;
}

Never handleDioExceptions(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.connectionError:
      throw const ServerException(
        ErrorModel(statusCode: 0, message: AppStrings.connectionError),
      );
    case DioExceptionType.cancel:
      throw const ServerException(
        ErrorModel(statusCode: 0, message: AppStrings.requestCancelled),
      );
    case DioExceptionType.badResponse:
      throw ServerException(
        ErrorModel.fromResponse(
          error.response?.data,
          statusCode: error.response?.statusCode,
        ),
      );
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      throw const ServerException(
        ErrorModel(statusCode: 0, message: AppStrings.genericError),
      );
  }
}
