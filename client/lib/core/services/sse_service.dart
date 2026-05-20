import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/notification_event.dart';

class SseService {
  final _controller = StreamController<NotificationEvent>.broadcast();
  http.Client? _client;
  int _retryDelaySeconds = 1;
  bool _isDisposed = false;

  Stream<NotificationEvent> get stream => _controller.stream;

  SseService() {
    _connect();
  }

  Future<void> _connect() async {
    if (_isDisposed) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token == null || token.isEmpty) {
      // No token, cannot connect. Retry later or handle differently.
      _scheduleReconnect();
      return;
    }

    try {
      _client = http.Client();
      final request = http.Request(
        'GET',
        Uri.parse('${ApiConfig.baseUrl}/notifications/stream'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'text/event-stream';

      final response = await _client!.send(request);

      if (response.statusCode == 200) {
        // Connected successfully, reset retry delay
        _retryDelaySeconds = 1;

        response.stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (String line) {
            if (line.startsWith('data: ')) {
              final dataStr = line.substring(6);
              try {
                final json = jsonDecode(dataStr) as Map<String, dynamic>;
                final event = NotificationEvent.fromJson(json);
                _controller.add(event);
              } catch (e) {
                // Ignore parsing errors for individual events
              }
            }
          },
          onError: (error) {
            _scheduleReconnect();
          },
          onDone: () {
            _scheduleReconnect();
          },
          cancelOnError: true,
        );
      } else {
        // Connection failed with status code
        _scheduleReconnect();
      }
    } catch (e) {
      // Network error
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_isDisposed) return;
    
    _client?.close();
    _client = null;

    Future.delayed(Duration(seconds: _retryDelaySeconds), () {
      _connect();
    });

    _retryDelaySeconds *= 2;
    if (_retryDelaySeconds > 30) {
      _retryDelaySeconds = 30; // Max 30 seconds
    }
  }

  void dispose() {
    _isDisposed = true;
    _client?.close();
    _controller.close();
  }
}
