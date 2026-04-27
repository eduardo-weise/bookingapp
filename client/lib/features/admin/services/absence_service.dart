import 'package:dio/dio.dart';
import '../../../core/services/api_client.dart';

class AbsenceDayModel {
  final String id;
  final DateTime date;

  const AbsenceDayModel({required this.id, required this.date});

  factory AbsenceDayModel.fromJson(Map<String, dynamic> json) {
    return AbsenceDayModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class AbsenceService {
  final Dio _client = ApiClient.client;

  /// Returns upcoming absences (today and future).
  Future<List<AbsenceDayModel>> getFutureAbsences() async {
    try {
      final response = await _client.get(
        '/absences',
        queryParameters: {'future': true},
      );
      return (response.data as List)
          .map((e) => AbsenceDayModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Returns past absences with pagination (10 per page).
  Future<List<AbsenceDayModel>> getPastAbsences({int page = 1}) async {
    try {
      final response = await _client.get(
        '/absences',
        queryParameters: {'future': false, 'page': page, 'pageSize': 10},
      );
      return (response.data as List)
          .map((e) => AbsenceDayModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Creates absence days for the given date range.
  Future<void> createAbsence({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _client.post(
        '/absences',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  /// Deletes a single absence day by ID.
  Future<void> deleteAbsence(String id) async {
    try {
      await _client.delete('/absences/$id');
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
