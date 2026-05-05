import 'package:app/core/services/api_client.dart';
import 'package:dio/dio.dart';

class ClientDebtModel {
  final String id;
  final String appointmentId;
  final double amount;
  final String status;
  final DateTime createdAt;

  const ClientDebtModel({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory ClientDebtModel.fromJson(Map<String, dynamic> json) {
    return ClientDebtModel(
      id: json['id'] as String,
      appointmentId: json['appointmentId'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'Pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class ClientDebtService {
  final Dio _client = ApiClient.client;

  Future<List<ClientDebtModel>> getDebts() async {
    try {
      final response = await _client.get('/payments/debts');

      if (response.data is! List) {
        return const [];
      }

      return (response.data as List)
          .map((item) => ClientDebtModel.fromJson(item as Map<String, dynamic>))
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
