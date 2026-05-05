import 'package:app/features/admin/services/admin_appointments_service.dart';
import 'package:app/features/admin/services/admin_clients_service.dart';
import 'package:app/features/admin/services/admin_debts_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'admin_providers.g.dart';

// Services
@riverpod
AdminClientsService adminClientsService(Ref ref) {
  return AdminClientsService();
}

@riverpod
AdminAppointmentsService adminAppointmentsService(Ref ref) {
  return AdminAppointmentsService();
}

@riverpod
AdminDebtsService adminDebtsService(Ref ref) {
  return AdminDebtsService();
}

// State Providers
@riverpod
class AdminPendingDebts extends _$AdminPendingDebts {
  @override
  FutureOr<List<AdminClientDebtSummary>> build() {
    return ref.watch(adminDebtsServiceProvider).getPendingDebts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(adminDebtsServiceProvider).getPendingDebts());
  }
}

@riverpod
class AdminTodayAppointments extends _$AdminTodayAppointments {
  @override
  FutureOr<List<AdminAppointmentModel>> build() {
    return ref.watch(adminAppointmentsServiceProvider).getAppointmentsByDate(DateTime.now());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(adminAppointmentsServiceProvider).getAppointmentsByDate(DateTime.now()));
  }
}

@riverpod
class AdminDateAppointments extends _$AdminDateAppointments {
  @override
  FutureOr<List<AdminAppointmentModel>> build(DateTime date) {
    return ref.watch(adminAppointmentsServiceProvider).getAppointmentsByDate(date);
  }

  Future<void> refresh(DateTime date) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(adminAppointmentsServiceProvider).getAppointmentsByDate(date));
  }
}
