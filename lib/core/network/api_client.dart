import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';
import 'api_exceptions.dart';

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: AppConstants.tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  Dio get dio => _dio;

  /// Unwraps the backend's standard envelope: { success, data, error }
  Future<T> request<T>(
    Future<Response> Function() call,
    T Function(dynamic data) parser,
  ) async {
    try {
      final response = await call();
      final body = response.data;
      if (body is Map && body['success'] == true) {
        return parser(body['data']);
      }
      final err = body is Map ? body['error'] : null;
      throw ApiException(
        code: err?['code'] ?? 'UNKNOWN_ERROR',
        message: err?['message'] ?? 'Something went wrong',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['error'] != null) {
        throw ApiException(
          code: data['error']['code'] ?? 'UNKNOWN_ERROR',
          message: data['error']['message'] ?? 'Something went wrong',
          statusCode: e.response?.statusCode,
        );
      }
      throw ApiException(
        code: 'NETWORK_ERROR',
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}