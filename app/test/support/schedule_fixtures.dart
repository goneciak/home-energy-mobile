import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/schedules/data/schedule_source.dart';

/// A heating schedule row as GI Core returns it.
HeatingSchedule scheduleRow(
  String id, {
  String deviceId = 'd1',
  String? name,
  List<int> days = const [1, 2, 3, 4, 5],
  String start = '06:00',
  String end = '08:00',
  double target = 55,
  double hysteresis = 3,
  bool enabled = true,
  int createdMinute = 0,
}) => HeatingSchedule(
  id: id,
  deviceId: deviceId,
  name: name ?? id,
  daysOfWeek: days,
  startTime: start,
  endTime: end,
  targetTemperatureCelsius: target,
  hysteresisCelsius: hysteresis,
  enabled: enabled,
  createdAt: DateTime.utc(2026, 11).add(Duration(minutes: createdMinute)),
  updatedAt: DateTime.utc(2026, 11),
);

/// Scriptable [ScheduleSource] holding one list per device; records calls.
class FakeScheduleSource implements ScheduleSource {
  new([Map<String, List<HeatingSchedule>>? rows]) : rows = {...?rows};

  final Map<String, List<HeatingSchedule>> rows;
  final List<String> calls = [];

  /// Thrown by the next write (then cleared).
  ApiFailure? writeFailure;

  /// Thrown by every list read while set.
  ApiFailure? listFailure;

  HeatingScheduleInput? lastInput;
  HeatingSchedulePatch? lastPatch;
  var _next = 0;

  void _failWrite() {
    if (writeFailure case final failure?) {
      writeFailure = null;
      throw failure;
    }
  }

  @override
  Future<List<HeatingSchedule>> schedules(String deviceId) async {
    calls.add('list:$deviceId');
    if (listFailure case final failure?) throw failure;
    return [...?rows[deviceId]];
  }

  @override
  Future<HeatingSchedule> createSchedule(
    String deviceId,
    HeatingScheduleInput input,
  ) async {
    calls.add('create:$deviceId');
    lastInput = input;
    _failWrite();
    final row = scheduleRow(
      'new-${_next++}',
      deviceId: deviceId,
      name: input.name,
      days: input.daysOfWeek,
      start: input.startTime,
      end: input.endTime,
      target: input.targetTemperatureCelsius,
      hysteresis: input.hysteresisCelsius,
      enabled: input.enabled,
      createdMinute: 100 + _next,
    );
    (rows[deviceId] ??= []).add(row);
    return row;
  }

  @override
  Future<HeatingSchedule> updateSchedule(
    String deviceId,
    String scheduleId,
    HeatingSchedulePatch patch,
  ) async {
    calls.add('update:$scheduleId');
    lastPatch = patch;
    _failWrite();
    final list = rows[deviceId] ?? [];
    final index = list.indexWhere((s) => s.id == scheduleId);
    final row = list[index].copyWith(
      name: patch.name ?? list[index].name,
      enabled: patch.enabled ?? list[index].enabled,
    );
    list[index] = row;
    return row;
  }

  @override
  Future<void> deleteSchedule(String deviceId, String scheduleId) async {
    calls.add('delete:$scheduleId');
    _failWrite();
    rows[deviceId]?.removeWhere((s) => s.id == scheduleId);
  }
}
