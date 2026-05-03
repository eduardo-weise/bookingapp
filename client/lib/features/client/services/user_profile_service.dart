import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';

class UserProfileModel {
  final String id;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? cpf;

  UserProfileModel({
    required this.id,
    required this.email,
    this.name,
    this.phoneNumber,
    this.cpf,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      name: json['name']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      cpf: json['cpf']?.toString(),
    );
  }

  /// Returns the initials (up to 2 chars) derived from the name or email.
  String get initials {
    final source = (name?.isNotEmpty == true) ? name! : email;
    final parts = source.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return source.isNotEmpty ? source[0].toUpperCase() : '?';
  }

  /// Returns the first name or the part before '@' in the email.
  String get displayName {
    if (name?.isNotEmpty == true) {
      return name!.trim().split(RegExp(r'\s+')).first;
    }
    return email.split('@').first;
  }
}

class UserProfileService {
  final Dio _client = ApiClient.client;

  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _client.get('/users');
      return UserProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    try {
      await _client.patch(
        '/users',
        data: {'name': name, 'phoneNumber': phoneNumber},
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
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
        if (data.containsKey('message')) return data['message'];
      }
      return 'Erro na requisição: ${e.response!.statusCode}';
    }
    return 'Erro de conexão. Verifique sua internet ou tente mais tarde.';
  }
}
