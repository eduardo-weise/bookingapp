import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';
import '../models/service_model.dart';

class BookingService {
  final Dio _client = ApiClient.client;

  /// Fetches all available services from [GET /services].
  Future<List<ServiceModel>> getServices() async {
    try {
      final response = await _client.get('/services');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => ServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Fetches available time slots for [date] and [serviceId].
  /// Returns a list of "HH:mm" formatted strings.
  /// [GET /appointments/available-slots?Date=&ServiceId=]
  Future<List<String>> getAvailableSlots({
    required DateTime date,
    required String serviceId,
    String? clientId,
  }) async {
    try {
      final response = await _client.get(
        '/appointments/available-slots',
        queryParameters: {
          'Date': date.toIso8601String(),
          'ServiceId': serviceId,
          'ClientId': clientId,
        },
      );
      final list = response.data as List<dynamic>;
      // Each item is a TimeSpan string like "09:00:00"; format as "HH:mm".
      return list.map((raw) => _formatSlot(raw as String)).toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Books an appointment. Combines [date] and [timeSlot] ("HH:mm") into
  /// a full ISO 8601 DateTime and sends [POST /appointments].
  Future<void> bookAppointment({
    required String serviceId,
    required DateTime date,
    required String timeSlot,
    String? clientId,
  }) async {
    try {
      final parts = timeSlot.split(':');
      final startTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      await _client.post(
        '/appointments',
        data: {
          'serviceId': serviceId,
          'startTime': startTime.toIso8601String(),
          'clientId': clientId,
        },
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Converts a TimeSpan string like "09:00:00" to "09:00".
  String _formatSlot(String raw) {
    final parts = raw.split(':');
    if (parts.length < 2) return raw;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
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
