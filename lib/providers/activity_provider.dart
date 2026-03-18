import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/sport_types.dart';
import '../core/errors/app_exception.dart';
import '../data/models/activity_model.dart';
import '../data/repositories/activity_repository.dart';

// -----------------------------------------------------------------------------
// Repository
// -----------------------------------------------------------------------------

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepository();
});

// -----------------------------------------------------------------------------
// Sport filter
// -----------------------------------------------------------------------------

final sportFilterProvider =
    NotifierProvider<SportFilterNotifier, SportType?>(
  SportFilterNotifier.new,
);

class SportFilterNotifier extends Notifier<SportType?> {
  @override
  SportType? build() => null;

  void select(SportType? type) => state = type;
}

// -----------------------------------------------------------------------------
// Location search
// -----------------------------------------------------------------------------

final locationSearchProvider =
    NotifierProvider<LocationSearchNotifier, String>(
  LocationSearchNotifier.new,
);

class LocationSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;

  void clear() => state = '';
}

// -----------------------------------------------------------------------------
// Pagination limit
// -----------------------------------------------------------------------------

final activityLimitProvider =
    NotifierProvider<ActivityLimitNotifier, int>(
  ActivityLimitNotifier.new,
);

class ActivityLimitNotifier extends Notifier<int> {
  static const _pageSize = 20;

  @override
  int build() => _pageSize;

  void loadMore() => state = state + _pageSize;

  void reset() => state = _pageSize;
}

// -----------------------------------------------------------------------------
// Activity list (stream with pagination)
// -----------------------------------------------------------------------------

final activityListProvider = StreamProvider<List<ActivityModel>>((ref) {
  final filter = ref.watch(sportFilterProvider);
  final limit = ref.watch(activityLimitProvider);
  final repo = ref.read(activityRepositoryProvider);
  return repo.streamActivities(sportTypeFilter: filter?.name, limit: limit);
});

// -----------------------------------------------------------------------------
// Filtered activity list (location search applied)
// -----------------------------------------------------------------------------

final filteredActivityListProvider =
    Provider<AsyncValue<List<ActivityModel>>>((ref) {
  final activitiesAsync = ref.watch(activityListProvider);
  final search = ref.watch(locationSearchProvider).toLowerCase().trim();

  if (search.isEmpty) return activitiesAsync;

  return activitiesAsync.whenData(
    (list) => list
        .where((a) => a.location.toLowerCase().contains(search))
        .toList(),
  );
});

// -----------------------------------------------------------------------------
// Activity detail
// -----------------------------------------------------------------------------

final activityDetailProvider =
    FutureProvider.family<ActivityModel, String>((ref, id) async {
  final repo = ref.read(activityRepositoryProvider);
  final result = await repo.getActivity(id);
  return result.fold(
    (err) => throw err,
    (model) => model,
  );
});

// -----------------------------------------------------------------------------
// Activity form (create / update / delete / join / leave)
// -----------------------------------------------------------------------------

final activityFormProvider =
    NotifierProvider<ActivityFormNotifier, ActivityFormState>(
  ActivityFormNotifier.new,
);

class ActivityFormState {
  const ActivityFormState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;

  ActivityFormState copyWith({bool? isLoading, String? errorMessage}) {
    return ActivityFormState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ActivityFormNotifier extends Notifier<ActivityFormState> {
  @override
  ActivityFormState build() => const ActivityFormState();

  Future<Either<AppException, ActivityModel>> createActivity({
    required String title,
    required String sportType,
    required DateTime dateTime,
    required String location,
    required int maxParticipants,
    String? description,
    required String hostId,
    required String hostName,
  }) async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(activityRepositoryProvider);

    final result = await repo.createActivity(
      title: title,
      sportType: sportType,
      dateTime: dateTime,
      location: location,
      maxParticipants: maxParticipants,
      description: description,
      hostId: hostId,
      hostName: hostName,
    );

    state = result.fold(
      (err) => state.copyWith(isLoading: false, errorMessage: err.message),
      (_) => const ActivityFormState(),
    );

    return result;
  }

  Future<Either<AppException, void>> updateActivity(
    String id, {
    String? title,
    String? sportType,
    DateTime? dateTime,
    String? location,
    int? maxParticipants,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(activityRepositoryProvider);

    final result = await repo.updateActivity(
      id,
      title: title,
      sportType: sportType,
      dateTime: dateTime,
      location: location,
      maxParticipants: maxParticipants,
      description: description,
    );

    state = result.fold(
      (err) => state.copyWith(isLoading: false, errorMessage: err.message),
      (_) => const ActivityFormState(),
    );

    return result;
  }

  Future<Either<AppException, void>> deleteActivity(String id) async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(activityRepositoryProvider);

    final result = await repo.deleteActivity(id);

    state = result.fold(
      (err) => state.copyWith(isLoading: false, errorMessage: err.message),
      (_) => const ActivityFormState(),
    );

    return result;
  }

  Future<Either<AppException, void>> joinActivity(
    String activityId,
    String userId,
  ) async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(activityRepositoryProvider);
    final result = await repo.joinActivity(activityId, userId);

    state = result.fold(
      (err) => state.copyWith(isLoading: false, errorMessage: err.message),
      (_) => const ActivityFormState(),
    );

    return result;
  }

  Future<Either<AppException, void>> leaveActivity(
    String activityId,
    String userId,
  ) async {
    state = state.copyWith(isLoading: true);
    final repo = ref.read(activityRepositoryProvider);
    final result = await repo.leaveActivity(activityId, userId);

    state = result.fold(
      (err) => state.copyWith(isLoading: false, errorMessage: err.message),
      (_) => const ActivityFormState(),
    );

    return result;
  }
}

// -----------------------------------------------------------------------------
// User activities (hosted + joined)
// -----------------------------------------------------------------------------

final userActivitiesProvider =
    StreamProvider.family<List<ActivityModel>, String>((ref, userId) {
  final repo = ref.read(activityRepositoryProvider);
  return repo.streamUserActivities(userId);
});
