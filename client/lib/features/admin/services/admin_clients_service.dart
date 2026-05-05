import 'package:app/core/services/api_client.dart';
import 'package:dio/dio.dart';

class AdminClientModel {
  final String id;
  final String displayName;
  final String email;

  const AdminClientModel({
    required this.id,
    required this.displayName,
    required this.email,
  });

  factory AdminClientModel.fromJson(Map<String, dynamic> json) {
    return AdminClientModel(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String,
    );
  }
}

class AdminClientsService {
  final Dio _client = ApiClient.client;

  Future<List<AdminClientModel>> getClients() async {
    try {
      final response = await _client.get('/users/clients');

      if (response.data is! List) {
        return const [];
      }

      return (response.data as List)
          .map(
            (item) => AdminClientModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();
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
        if (data.containsKey('message')) return data['message'] as String;
      }
      return 'Erro na requisição: ${e.response!.statusCode}';
    }
    return 'Erro de conexão. Verifique sua internet ou tente mais tarde.';
  }
}
