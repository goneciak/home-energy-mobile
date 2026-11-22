import 'package:gi_core_api/gi_core_api.dart';

/// Outcome of the last create, update or delete of a heating schedule.
sealed class ScheduleMutationState {
  const new();

  bool get isBusy => this is ScheduleMutationSaving;
}

final class ScheduleMutationIdle extends ScheduleMutationState {
  const new();
}

final class ScheduleMutationSaving extends ScheduleMutationState {
  const new();
}

/// Saved; [deleted] tells a delete from a create or update.
final class ScheduleMutationSaved extends ScheduleMutationState {
  const new({this.deleted = false});

  final bool deleted;
}

/// `HEATING_SCHEDULE_NOT_FOUND`: the schedule was deleted elsewhere. The
/// list has been reloaded.
final class ScheduleMutationGone extends ScheduleMutationState {
  const new();
}

final class ScheduleMutationFailed extends ScheduleMutationState {
  const new(this.failure);

  final ApiFailure failure;
}
