// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userProfileService)
final userProfileServiceProvider = UserProfileServiceProvider._();

final class UserProfileServiceProvider
    extends
        $FunctionalProvider<
          UserProfileService,
          UserProfileService,
          UserProfileService
        >
    with $Provider<UserProfileService> {
  UserProfileServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileServiceHash();

  @$internal
  @override
  $ProviderElement<UserProfileService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserProfileService create(Ref ref) {
    return userProfileService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfileService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfileService>(value),
    );
  }
}

String _$userProfileServiceHash() =>
    r'3296e7ec05eb86d15a7062b9dd5921bfe53267da';

@ProviderFor(clientDebtService)
final clientDebtServiceProvider = ClientDebtServiceProvider._();

final class ClientDebtServiceProvider
    extends
        $FunctionalProvider<
          ClientDebtService,
          ClientDebtService,
          ClientDebtService
        >
    with $Provider<ClientDebtService> {
  ClientDebtServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientDebtServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientDebtServiceHash();

  @$internal
  @override
  $ProviderElement<ClientDebtService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientDebtService create(Ref ref) {
    return clientDebtService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientDebtService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientDebtService>(value),
    );
  }
}

String _$clientDebtServiceHash() => r'c8c2bc1172cfe96472a35c2560b6a11fce1c7cd0';

@ProviderFor(clientAppointmentsService)
final clientAppointmentsServiceProvider = ClientAppointmentsServiceProvider._();

final class ClientAppointmentsServiceProvider
    extends
        $FunctionalProvider<
          ClientAppointmentsService,
          ClientAppointmentsService,
          ClientAppointmentsService
        >
    with $Provider<ClientAppointmentsService> {
  ClientAppointmentsServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientAppointmentsServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientAppointmentsServiceHash();

  @$internal
  @override
  $ProviderElement<ClientAppointmentsService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClientAppointmentsService create(Ref ref) {
    return clientAppointmentsService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientAppointmentsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientAppointmentsService>(value),
    );
  }
}

String _$clientAppointmentsServiceHash() =>
    r'f67df2847a027c65d1b84fa096eb85b96654906a';

@ProviderFor(UserProfile)
final userProfileProvider = UserProfileProvider._();

final class UserProfileProvider
    extends $AsyncNotifierProvider<UserProfile, UserProfileModel> {
  UserProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @$internal
  @override
  UserProfile create() => UserProfile();
}

String _$userProfileHash() => r'2093a13e207714de226a3f8a54c00728724c7e9e';

abstract class _$UserProfile extends $AsyncNotifier<UserProfileModel> {
  FutureOr<UserProfileModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<UserProfileModel>, UserProfileModel>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfileModel>, UserProfileModel>,
              AsyncValue<UserProfileModel>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ClientDebts)
final clientDebtsProvider = ClientDebtsProvider._();

final class ClientDebtsProvider
    extends $AsyncNotifierProvider<ClientDebts, List<ClientDebtModel>> {
  ClientDebtsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientDebtsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientDebtsHash();

  @$internal
  @override
  ClientDebts create() => ClientDebts();
}

String _$clientDebtsHash() => r'86ec36546a2c7d879251e05f2eec506ec87483ff';

abstract class _$ClientDebts extends $AsyncNotifier<List<ClientDebtModel>> {
  FutureOr<List<ClientDebtModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<ClientDebtModel>>, List<ClientDebtModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ClientDebtModel>>,
                List<ClientDebtModel>
              >,
              AsyncValue<List<ClientDebtModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ClientAppointments)
final clientAppointmentsProvider = ClientAppointmentsProvider._();

final class ClientAppointmentsProvider
    extends
        $AsyncNotifierProvider<
          ClientAppointments,
          List<ClientAppointmentModel>
        > {
  ClientAppointmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clientAppointmentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clientAppointmentsHash();

  @$internal
  @override
  ClientAppointments create() => ClientAppointments();
}

String _$clientAppointmentsHash() =>
    r'e9bfa6a4ba76ecce3b6a28d1f2738b1cb96fe0b0';

abstract class _$ClientAppointments
    extends $AsyncNotifier<List<ClientAppointmentModel>> {
  FutureOr<List<ClientAppointmentModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ClientAppointmentModel>>,
              List<ClientAppointmentModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ClientAppointmentModel>>,
                List<ClientAppointmentModel>
              >,
              AsyncValue<List<ClientAppointmentModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
