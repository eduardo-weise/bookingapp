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
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(absenceServiceProvider).getFutureAbsences(),
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
    final previousState = state.asData?.value ?? [];
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(absenceServiceProvider).getPastAbsences(page: page),
    );
    
    state = result.when(
      data: (newItems) => AsyncValue.data([...previousState, ...newItems]),
      error: (err, stack) => AsyncValue.error(err, stack),
      loading: () => const AsyncValue.loading(),
    );
  }
}
