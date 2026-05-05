// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(adminClientsService)
final adminClientsServiceProvider = AdminClientsServiceProvider._();

final class AdminClientsServiceProvider
    extends
        $FunctionalProvider<
          AdminClientsService,
          AdminClientsService,
          AdminClientsService
        >
    with $Provider<AdminClientsService> {
  AdminClientsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminClientsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminClientsServiceHash();

  @$internal
  @override
  $ProviderElement<AdminClientsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminClientsService create(Ref ref) {
    return adminClientsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminClientsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminClientsService>(value),
    );
  }
}

String _$adminClientsServiceHash() =>
    r'6d4d7058bc5036e72abbcd2770b013edf53b41ff';

@ProviderFor(adminAppointmentsService)
final adminAppointmentsServiceProvider = AdminAppointmentsServiceProvider._();

final class AdminAppointmentsServiceProvider
    extends
        $FunctionalProvider<
          AdminAppointmentsService,
          AdminAppointmentsService,
          AdminAppointmentsService
        >
    with $Provider<AdminAppointmentsService> {
  AdminAppointmentsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminAppointmentsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminAppointmentsServiceHash();

  @$internal
  @override
  $ProviderElement<AdminAppointmentsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminAppointmentsService create(Ref ref) {
    return adminAppointmentsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminAppointmentsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminAppointmentsService>(value),
    );
  }
}

String _$adminAppointmentsServiceHash() =>
    r'1ed23144c0b303c988e1182c00f8078cdc6dab1c';

@ProviderFor(adminDebtsService)
final adminDebtsServiceProvider = AdminDebtsServiceProvider._();

final class AdminDebtsServiceProvider
    extends
        $FunctionalProvider<
          AdminDebtsService,
          AdminDebtsService,
          AdminDebtsService
        >
    with $Provider<AdminDebtsService> {
  AdminDebtsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminDebtsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminDebtsServiceHash();

  @$internal
  @override
  $ProviderElement<AdminDebtsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AdminDebtsService create(Ref ref) {
    return adminDebtsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminDebtsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminDebtsService>(value),
    );
  }
}

String _$adminDebtsServiceHash() => r'60bac0342e32a95e9c69d370b96db08425f88995';

@ProviderFor(AdminPendingDebts)
final adminPendingDebtsProvider = AdminPendingDebtsProvider._();

final class AdminPendingDebtsProvider
    extends
        $AsyncNotifierProvider<
          AdminPendingDebts,
          List<AdminClientDebtSummary>
        > {
  AdminPendingDebtsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminPendingDebtsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminPendingDebtsHash();

  @$internal
  @override
  AdminPendingDebts create() => AdminPendingDebts();
}

String _$adminPendingDebtsHash() => r'65e003bdc8a4d1ecc0c52b9b8093e9d1cebf49e5';

abstract class _$AdminPendingDebts
    extends $AsyncNotifier<List<AdminClientDebtSummary>> {
  FutureOr<List<AdminClientDebtSummary>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AdminClientDebtSummary>>,
              List<AdminClientDebtSummary>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AdminClientDebtSummary>>,
                List<AdminClientDebtSummary>
              >,
              AsyncValue<List<AdminClientDebtSummary>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AdminTodayAppointments)
final adminTodayAppointmentsProvider = AdminTodayAppointmentsProvider._();

final class AdminTodayAppointmentsProvider
    extends
        $AsyncNotifierProvider<
          AdminTodayAppointments,
          List<AdminAppointmentModel>
        > {
  AdminTodayAppointmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminTodayAppointmentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminTodayAppointmentsHash();

  @$internal
  @override
  AdminTodayAppointments create() => AdminTodayAppointments();
}

String _$adminTodayAppointmentsHash() =>
    r'b18d6f1117064bf7b3932c47cc8c2c36f6112598';

abstract class _$AdminTodayAppointments
    extends $AsyncNotifier<List<AdminAppointmentModel>> {
  FutureOr<List<AdminAppointmentModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AdminAppointmentModel>>,
              List<AdminAppointmentModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AdminAppointmentModel>>,
                List<AdminAppointmentModel>
              >,
              AsyncValue<List<AdminAppointmentModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AdminDateAppointments)
final adminDateAppointmentsProvider = AdminDateAppointmentsFamily._();

final class AdminDateAppointmentsProvider
    extends
        $AsyncNotifierProvider<
          AdminDateAppointments,
          List<AdminAppointmentModel>
        > {
  AdminDateAppointmentsProvider._({
    required AdminDateAppointmentsFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'adminDateAppointmentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$adminDateAppointmentsHash();

  @override
  String toString() {
    return r'adminDateAppointmentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AdminDateAppointments create() => AdminDateAppointments();

  @override
  bool operator ==(Object other) {
    return other is AdminDateAppointmentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$adminDateAppointmentsHash() =>
    r'faa698dbb963cae35b59a6da0d397f6f62b0708c';

final class AdminDateAppointmentsFamily extends $Family
    with
        $ClassFamilyOverride<
          AdminDateAppointments,
          AsyncValue<List<AdminAppointmentModel>>,
          List<AdminAppointmentModel>,
          FutureOr<List<AdminAppointmentModel>>,
          DateTime
        > {
  AdminDateAppointmentsFamily._()
    : super(
        retry: null,
        name: r'adminDateAppointmentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AdminDateAppointmentsProvider call(DateTime date) =>
      AdminDateAppointmentsProvider._(argument: date, from: this);

  @override
  String toString() => r'adminDateAppointmentsProvider';
}

abstract class _$AdminDateAppointments
    extends $AsyncNotifier<List<AdminAppointmentModel>> {
  late final _$args = ref.$arg as DateTime;
  DateTime get date => _$args;

  FutureOr<List<AdminAppointmentModel>> build(DateTime date);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<AdminAppointmentModel>>,
              List<AdminAppointmentModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AdminAppointmentModel>>,
                List<AdminAppointmentModel>
              >,
              AsyncValue<List<AdminAppointmentModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
