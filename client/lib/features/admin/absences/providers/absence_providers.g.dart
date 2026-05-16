// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'absence_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(absenceService)
final absenceServiceProvider = AbsenceServiceProvider._();

final class AbsenceServiceProvider
    extends $FunctionalProvider<AbsenceService, AbsenceService, AbsenceService>
    with $Provider<AbsenceService> {
  AbsenceServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'absenceServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$absenceServiceHash();

  @$internal
  @override
  $ProviderElement<AbsenceService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AbsenceService create(Ref ref) {
    return absenceService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AbsenceService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AbsenceService>(value),
    );
  }
}

String _$absenceServiceHash() => r'012d565bc187d38a5647261e831fbcc67d1f52c8';

@ProviderFor(FutureAbsences)
final futureAbsencesProvider = FutureAbsencesProvider._();

final class FutureAbsencesProvider
    extends $AsyncNotifierProvider<FutureAbsences, List<AbsenceDayModel>> {
  FutureAbsencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'futureAbsencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$futureAbsencesHash();

  @$internal
  @override
  FutureAbsences create() => FutureAbsences();
}

String _$futureAbsencesHash() => r'b2dc161dcb01d4579e7bf4d2155c55757d7af2d7';

abstract class _$FutureAbsences extends $AsyncNotifier<List<AbsenceDayModel>> {
  FutureOr<List<AbsenceDayModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AbsenceDayModel>>, List<AbsenceDayModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AbsenceDayModel>>,
                List<AbsenceDayModel>
              >,
              AsyncValue<List<AbsenceDayModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PastAbsences)
final pastAbsencesProvider = PastAbsencesProvider._();

final class PastAbsencesProvider
    extends $AsyncNotifierProvider<PastAbsences, List<AbsenceDayModel>> {
  PastAbsencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastAbsencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastAbsencesHash();

  @$internal
  @override
  PastAbsences create() => PastAbsences();
}

String _$pastAbsencesHash() => r'13814675835596fd01c61ab1af2b33e324a0aaa9';

abstract class _$PastAbsences extends $AsyncNotifier<List<AbsenceDayModel>> {
  FutureOr<List<AbsenceDayModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AbsenceDayModel>>, List<AbsenceDayModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AbsenceDayModel>>,
                List<AbsenceDayModel>
              >,
              AsyncValue<List<AbsenceDayModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
