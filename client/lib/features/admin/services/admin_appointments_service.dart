import 'package:app/core/services/api_client.dart';
import 'package:dio/dio.dart';

class AdminAppointmentModel {
  final String id;
  final String clientName;
  final String serviceName;
  final DateTime startTime;
  final String status;

  const AdminAppointmentModel({
    required this.id,
    required this.clientName,
    required this.serviceName,
    required this.startTime,
    required this.status,
  });

  factory AdminAppointmentModel.fromJson(Map<String, dynamic> json) {
    return AdminAppointmentModel(
      id: json['id'] as String,
      clientName: json['clientName'] as String,
      serviceName: json['serviceName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      status: json['status'] as String,
    );
  }
}

class AdminAppointmentsService {
  final Dio _client = ApiClient.client;

  Future<List<AdminAppointmentModel>> getAppointmentsByDate(DateTime date) async {
    try {
      final response = await _client.get(
        '/appointments/by-date',
        queryParameters: {'date': date.toIso8601String()},
      );

      if (response.statusCode == 204 || response.data == null || response.data == '') {
        return const [];
      }

      if (response.data is! List) {
        return const [];
      }

      return (response.data as List)
          .map((item) => AdminAppointmentModel.fromJson(item as Map<String, dynamic>))
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