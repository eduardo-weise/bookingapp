import 'package:app/core/services/api_client.dart';
import 'package:dio/dio.dart';

class ClientAppointmentModel {
  final String id;
  final String serviceName;
  final double servicePrice;
  final DateTime startTime;
  final DateTime endTime;
  final String status;

  const ClientAppointmentModel({
    required this.id,
    required this.serviceName,
    required this.servicePrice,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory ClientAppointmentModel.fromJson(Map<String, dynamic> json) {
    return ClientAppointmentModel(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      servicePrice: (json['servicePrice'] as num?)?.toDouble() ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
    );
  }
}

class ClientAppointmentsService {
  final Dio _client = ApiClient.client;

  Future<List<ClientAppointmentModel>> getAppointmentHistory() async {
    try {
      final response = await _client.get('/appointments');

      if (response.data is! List) {
        return const [];
      }

      return (response.data as List)
          .map((item) => ClientAppointmentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _client.post(
        '/appointments/$appointmentId/cancel',
        data: {},
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
            return errList.map((err) => err['reason'] ?? err['message']).join('\n');
          }
        }
        if (data.containsKey('message')) return data['message'] as String;
      }
      return 'Erro na requisição: ${e.response!.statusCode}';
    }
    return 'Erro de conexão. Verifique sua internet ou tente mais tarde.';
  }
}