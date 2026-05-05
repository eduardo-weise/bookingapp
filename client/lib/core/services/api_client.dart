import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../../features/auth/services/auth_service.dart';
import '../../../main.dart';

class ApiClient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );

  static void initInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attempt to get token
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final authService = AuthService();
            final refreshed = await authService.refreshToken();

            if (refreshed) {
              final prefs = await SharedPreferences.getInstance();
              final newAccessToken = prefs.getString('access_token');

              if (newAccessToken != null) {
                // Retry the original request with cloned options
                final clonedHeaders = Map<String, dynamic>.from(
                  e.requestOptions.headers,
                );
                clonedHeaders.remove('authorization');
                clonedHeaders.remove('Authorization');
                clonedHeaders['Authorization'] = 'Bearer $newAccessToken';

                final options = Options(
                  method: e.requestOptions.method,
                  headers: clonedHeaders,
                  contentType: e.requestOptions.contentType,
                  responseType: e.requestOptions.responseType,
                  sendTimeout: e.requestOptions.sendTimeout,
                  receiveTimeout: e.requestOptions.receiveTimeout,
                  extra: e.requestOptions.extra,
                );

                final retryResponse = await _dio.request(
                  e.requestOptions.path,
                  options: options,
                  data: e.requestOptions.data,
                  queryParameters: e.requestOptions.queryParameters,
                );
                return handler.resolve(retryResponse);
              }
            } else {
              // Refresh token failed or is expired. Logout and redirect to login.
              navigatorKey.currentState?.pushNamedAndRemoveUntil(
                '/',
                (route) => false,
              );
              scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text(
                    'Sessão expirada. Por favor, faça login novamente.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  static Dio get client => _dio;
}
