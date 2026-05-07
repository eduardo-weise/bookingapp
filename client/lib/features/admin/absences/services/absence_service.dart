import 'package:app/core/services/api_client.dart';
import 'package:app/core/extensions/date_time_extensions.dart';
import 'package:dio/dio.dart';

class AbsenceDayModel {
  final String id;
  final DateTime startDate;
  final DateTime endDate;

  const AbsenceDayModel({
    required this.id,
    required this.startDate,
    required this.endDate,
  });

  factory AbsenceDayModel.create({
    required String id,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return AbsenceDayModel(
      id: id,
      startDate: startDate,
      endDate: endDate,
    );
  }

  factory AbsenceDayModel.fromJson(Map<String, dynamic> json) {
    return AbsenceDayModel(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );
  }

  bool get isSingleDayWithTime {
    return startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day &&
        (startDate.hour != 0 ||
            startDate.minute != 0 ||
            endDate.hour != 0 ||
            endDate.minute != 0);
  }

  bool get isSingleDay {
    return startDate.year == endDate.year &&
        startDate.month == endDate.month &&
        startDate.day == endDate.day;
  }

  String _formatDate(DateTime date) {
    return date.formatLocal('dd/MM/yyyy');
  }

  String _formatDateWithWeekday(DateTime date) {
    final weekday = date.formatLocal('EEE').substring(0, 3);
    return '$weekday, ${_formatDate(date)}';
  }

  String _formatTime(DateTime date) {
    return date.displayTime;
  }

  String get formattedDate {
    // Single day with time: "seg, 29/04/2026 (08:00 - 16:55)"
    if (isSingleDayWithTime) {
      return '${_formatDateWithWeekday(startDate)} (${_formatTime(startDate)} - ${_formatTime(endDate)})';
    }

    // Single day without time: "seg, 29/04/2026"
    if (isSingleDay) {
      return _formatDateWithWeekday(startDate);
    }

    // Period: "seg, 18/05/2026 - sex, 20/05/2026"
    return '${_formatDateWithWeekday(startDate)} - ${_formatDateWithWeekday(endDate)}';
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
  Future<AbsenceDayModel> createAbsence({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _client.post(
        '/absences',
        data: {
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      return AbsenceDayModel.fromJson(response.data as Map<String, dynamic>);
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
