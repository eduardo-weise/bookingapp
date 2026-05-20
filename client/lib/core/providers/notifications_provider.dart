import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/sse_service.dart';
import '../models/notification_event.dart';

part 'notifications_provider.g.dart';

@riverpod
class SseServiceController extends _$SseServiceController {
  SseService? _service;

  @override
  void build() {
    _service = SseService();
    ref.onDispose(() {
      _service?.dispose();
    });
  }

  SseService get service => _service!;
}

@riverpod
Stream<NotificationEvent> notificationStream(Ref ref) {
  final service = ref.watch(sseServiceControllerProvider.notifier).service;
  return service.stream;
}
