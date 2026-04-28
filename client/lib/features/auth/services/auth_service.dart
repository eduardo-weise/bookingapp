import 'package:app/core/config/api_config.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../core/services/api_client.dart';

class AuthService {
  final Dio _client = ApiClient.client;

  Future<String> login(String email, String password) async {
    try {
      final response = await _client.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data != null && data['accessToken'] != null) {
        final token = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userId = data['userId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
        }
        if (userId != null) await prefs.setString('user_id', userId);

        final decodedToken = JwtDecoder.decode(token);
        final role =
            decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ??
            decodedToken['role'] ??
            'Client';
        return role.toString();
      } else {
        throw Exception('Token not found in response.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('E-mail ou senha incorretos.');
      }
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Ocorreu um erro ao tentar fazer login: $e');
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String cpf,
  }) async {
    try {
      final response = await _client.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'cpf': cpf,
        },
      );

      final data = response.data;
      if (data != null && data['accessToken'] != null) {
        final token = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userId = data['userId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        if (refreshToken != null) {
          await prefs.setString('refresh_token', refreshToken);
        }
        if (userId != null) {
          await prefs.setString('user_id', userId);
        }
      } else {
        throw Exception('Token not found in response.');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    } catch (e) {
      throw Exception('Ocorreu um erro ao tentar criar a conta: $e');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _client.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> validateResetToken({
    required String email,
    required String token,
  }) async {
    try {
      await _client.post(
        '/auth/validate-reset-token',
        data: {'email': email, 'token': token},
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      await _client.post(
        '/auth/reset-password',
        data: {'email': email, 'token': token, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
  }

  Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    final userId = prefs.getString('user_id');

    if (refreshToken == null || userId == null) {
      return false;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          headers: {'Accept': 'application/json'},
        ),
      );

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'userId': userId, 'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        await prefs.setString('access_token', data['accessToken']);
        if (data['refreshToken'] != null) {
          await prefs.setString('refresh_token', data['refreshToken']);
        }
        return true;
      }
    } catch (_) {
      await logout();
    }
    return false;
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      // Backend pode mandar erros de validação customizados
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('errors') && data['errors'] is List) {
          final errList = data['errors'] as List;
          if (errList.isNotEmpty) {
            return errList
                .map((err) => err['reason'] ?? err['message'])
                .join('\n');
          }
        }
        if (data.containsKey('message')) {
          return data['message'];
        }
      }
      return 'Erro na requisção: ${e.response!.statusCode}';
    } else {
      return 'Erro de conexão. Verifique sua internet ou tente mais tarde.';
    }
  }
}
