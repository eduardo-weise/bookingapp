import 'package:app/features/client/services/client_appointments_service.dart';
import 'package:app/features/client/services/client_debt_service.dart';
import 'package:app/features/client/services/user_profile_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'client_providers.g.dart';

// Services
@riverpod
UserProfileService userProfileService(Ref ref) {
  return UserProfileService();
}

@riverpod
ClientDebtService clientDebtService(Ref ref) {
  return ClientDebtService();
}

@riverpod
ClientAppointmentsService clientAppointmentsService(Ref ref) {
  return ClientAppointmentsService();
}

// State Providers
@riverpod
class UserProfile extends _$UserProfile {
  @override
  FutureOr<UserProfileModel> build() {
    return ref.watch(userProfileServiceProvider).getProfile();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(userProfileServiceProvider).getProfile(),
    );
  }
}

@riverpod
class ClientDebts extends _$ClientDebts {
  @override
  FutureOr<List<ClientDebtModel>> build() {
    return ref.watch(clientDebtServiceProvider).getDebts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(clientDebtServiceProvider).getDebts(),
    );
  }
}

@riverpod
class ClientAppointments extends _$ClientAppointments {
  @override
  FutureOr<List<ClientAppointmentModel>> build() {
    return ref.watch(clientAppointmentsServiceProvider).getAppointmentHistory();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(clientAppointmentsServiceProvider).getAppointmentHistory(),
    );
  }
}
