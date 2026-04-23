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
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data != null && data['accessToken'] != null) {
        final token = data['accessToken'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        
        final decodedToken = JwtDecoder.decode(token);
        final role = decodedToken['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? decodedToken['role'] ?? 'Client';
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['accessToken']);
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
      await _client.post('/auth/validate-reset-token', data: {
        'email': email,
        'token': token,
      });
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
      await _client.post('/auth/reset-password', data: {
        'email': email,
        'token': token,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      // Backend pode mandar erros de validação customizados
      final data = e.response!.data;
      if (data is Map) {
        if (data.containsKey('errors') && data['errors'] is List) {
          final errList = data['errors'] as List;
          if (errList.isNotEmpty) {
            return errList.map((err) => err['reason'] ?? err['message']).join('\n');
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
