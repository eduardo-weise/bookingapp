import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/absence_service.dart';

part 'absence_providers.g.dart';

@riverpod
AbsenceService absenceService(Ref ref) {
  return AbsenceService();
}

@riverpod
class FutureAbsences extends _$FutureAbsences {
  @override
  FutureOr<List<AbsenceDayModel>> build() {
    return ref.watch(absenceServiceProvider).getFutureAbsences();
  }

  Future<void> refresh() async {
    final service = ref.read(absenceServiceProvider);
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(service.getFutureAbsences);
    if (!ref.mounted) return;
    state = result;
  }

  void addAbsence(AbsenceDayModel absence) {
    final current = state.asData?.value ?? const <AbsenceDayModel>[];
    final updated = [...current, absence]
      ..sort((left, right) => left.startDate.compareTo(right.startDate));
    state = AsyncValue.data(updated);
  }

  void removeAbsence(String absenceId) {
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data(
      current.where((absence) => absence.id != absenceId).toList(),
    );
  }
}

@riverpod
class PastAbsences extends _$PastAbsences {
  @override
  FutureOr<List<AbsenceDayModel>> build() {
    return ref.watch(absenceServiceProvider).getPastAbsences(page: 1);
  }

  Future<void> loadMore(int page) async {
    final service = ref.read(absenceServiceProvider);
    final previousState = state.asData?.value ?? [];
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => service.getPastAbsences(page: page),
    );
    if (!ref.mounted) return;
    
    state = result.when(
      data: (newItems) => AsyncValue.data([...previousState, ...newItems]),
      error: (err, stack) => AsyncValue.error(err, stack),
      loading: () => const AsyncValue.loading(),
    );
  }
}
