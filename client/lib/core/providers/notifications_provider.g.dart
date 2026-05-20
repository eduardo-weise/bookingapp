// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SseServiceController)
final sseServiceControllerProvider = SseServiceControllerProvider._();

final class SseServiceControllerProvider
    extends $NotifierProvider<SseServiceController, void> {
  SseServiceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sseServiceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sseServiceControllerHash();

  @$internal
  @override
  SseServiceController create() => SseServiceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$sseServiceControllerHash() =>
    r'580a8eb026b47d4d84d5e33f1a02b20111a4be7f';

abstract class _$SseServiceController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(notificationStream)
final notificationStreamProvider = NotificationStreamProvider._();

final class NotificationStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<NotificationEvent>,
          NotificationEvent,
          Stream<NotificationEvent>
        >
    with
        $FutureModifier<NotificationEvent>,
        $StreamProvider<NotificationEvent> {
  NotificationStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationStreamHash();

  @$internal
  @override
  $StreamProviderElement<NotificationEvent> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<NotificationEvent> create(Ref ref) {
    return notificationStream(ref);
  }
}

String _$notificationStreamHash() =>
    r'e7bdc22995955b25e331754f32b2e35101ac9e28';
