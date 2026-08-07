import 'package:dio/dio.dart';

import '../constants/app_constants.dart';

/// Lightweight Dio client for the Audius API.
///
/// Audius needs NO signup and NO API key — just an `app_name` query
/// param identifying your app.
///
/// Note: Audius is decentralized (multiple discovery-node hosts exist).
/// If this host ever stops responding, fetch a fresh one from
/// https://api.audius.co and update [AppConstants.audiusBaseUrl].
class AudiusClient {
  AudiusClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.audiusBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        queryParameters: {
          'app_name': AppConstants.audiusAppName,
        },
      ),
    );
  }

  static final AudiusClient _instance = AudiusClient._internal();
  factory AudiusClient() => _instance;

  late final Dio _dio;
  Dio get dio => _dio;
}