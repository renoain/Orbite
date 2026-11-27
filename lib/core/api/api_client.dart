import 'package:dio/dio.dart';

import 'package:orbite/core/api/api_config.dart';
import 'package:orbite/core/error/app_failure.dart';

class ApiClient {
  ApiClient({Dio? dio, this.tokenProvider}) : _dio = dio ?? Dio() {
    _dio.options
      ..baseUrl = ApiConfig.baseUrl
      ..connectTimeout = ApiConfig.connectTimeout
      ..receiveTimeout = ApiConfig.receiveTimeout
      ..headers = {'Accept': 'application/json'};
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final String? Function()? tokenProvider;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    try {
      final response = await _dio.get<dynamic>(path, queryParameters: query);
      return _asJsonMap(response.data);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Map<String, dynamic> _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    throw const AppFailure(
      'Format respons server tidak valid.',
      kind: FailureKind.server,
    );
  }

  AppFailure _mapError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const AppFailure(
          'Koneksi ke server timeout.',
          kind: FailureKind.timeout,
        );
      case DioExceptionType.connectionError:
        return const AppFailure(
          'Tidak dapat terhubung ke server.',
          kind: FailureKind.network,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return AppFailure(
          _messageFromResponse(error.response),
          kind: _kindFromStatus(statusCode),
          statusCode: statusCode,
        );
      case DioExceptionType.badCertificate:
        return const AppFailure(
          'Sertifikat server tidak valid.',
          kind: FailureKind.network,
        );
      case DioExceptionType.cancel:
        return const AppFailure(
          'Permintaan dibatalkan.',
          kind: FailureKind.unknown,
        );
      default:
        return AppFailure(
          error.message ?? 'Terjadi kesalahan tak terduga.',
          kind: FailureKind.unknown,
        );
    }
  }

  String _messageFromResponse(Response<dynamic>? response) {
    final data = response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Server mengembalikan status '
        '${response?.statusCode ?? 'tidak diketahui'}.';
  }

  FailureKind _kindFromStatus(int? statusCode) {
    switch (statusCode) {
      case 400:
        return FailureKind.badRequest;
      case 401:
        return FailureKind.unauthorized;
      case 404:
        return FailureKind.notFound;
      default:
        return FailureKind.server;
    }
  }
}
