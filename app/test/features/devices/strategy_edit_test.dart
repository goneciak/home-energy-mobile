import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/features/devices/domain/heating_command_state.dart';
import 'package:gi_home/src/features/devices/domain/strategy_edit.dart';

import '../../support/heating_fixtures.dart';

void main() {
  const auto55 = ControlStrategy(
    targetTemperatureCelsius: 55,
    hysteresisCelsius: 4,
    mode: ControlStrategyMode.auto,
  );

  group('StrategyValidation', () {
    test('parses a comma or a dot, rejects text and non-finite values', () {
      expect(StrategyValidation.parse('55,5'), 55.5);
      expect(StrategyValidation.parse(' 55.5 '), 55.5);
      expect(StrategyValidation.parse(''), isNull);
      expect(StrategyValidation.parse('abc'), isNull);
      expect(StrategyValidation.parse('Infinity'), isNull);
      expect(StrategyValidation.parse('NaN'), isNull);
    });

    test('target: 5–80 °C in 0.5 °C steps (UI limits, plan §12.5)', () {
      expect(StrategyValidation.target('5'), isNull);
      expect(StrategyValidation.target('80'), isNull);
      expect(StrategyValidation.target('55,5'), isNull);
      expect(StrategyValidation.target('4,5'), StrategyFieldError.outOfRange);
      expect(StrategyValidation.target('80,5'), StrategyFieldError.outOfRange);
      // GI Core would accept 0 and 100; the UI does not.
      expect(StrategyValidation.target('0'), StrategyFieldError.outOfRange);
      expect(StrategyValidation.target('100'), StrategyFieldError.outOfRange);
      expect(StrategyValidation.target('55,3'), StrategyFieldError.notOnStep);
      expect(StrategyValidation.target('x'), StrategyFieldError.notANumber);
    });

    test('hysteresis: 1–20 °C like GI Core', () {
      expect(StrategyValidation.hysteresis('1'), isNull);
      expect(StrategyValidation.hysteresis('20'), isNull);
      expect(
        StrategyValidation.hysteresis('0,5'),
        StrategyFieldError.outOfRange,
      );
      expect(
        StrategyValidation.hysteresis('21'),
        StrategyFieldError.outOfRange,
      );
      expect(
        StrategyValidation.hysteresis('1,2'),
        StrategyFieldError.notOnStep,
      );
      expect(StrategyValidation.hysteresis(''), StrategyFieldError.notANumber);
    });

    test('draft carries all three fields, or null when anything is '
        'invalid', () {
      expect(
        StrategyValidation.draft(
          target: '55',
          hysteresis: '4',
          mode: ControlStrategyMode.auto,
        ),
        auto55,
      );
      expect(
        StrategyValidation.draft(
          target: '90',
          hysteresis: '4',
          mode: ControlStrategyMode.auto,
        ),
        isNull,
      );
      expect(
        StrategyValidation.draft(
          target: '55',
          hysteresis: '0',
          mode: ControlStrategyMode.auto,
        ),
        isNull,
      );
      expect(
        StrategyValidation.draft(
          target: '55',
          hysteresis: '4',
          mode: ControlStrategyMode.unknown,
        ),
        isNull,
      );
    });
  });

  group('StrategyConflict', () {
    final started = StrategyBaseline.of(heatingDetail());

    test('the baseline is the BASE strategy and the suspension', () {
      expect(started, const StrategyBaseline(base: auto55, suspended: false));
      expect(started.hashCode, StrategyBaseline.of(heatingDetail()).hashCode);
      expect(started.toString(), contains('suspended: false'));
    });

    test('no conflict when only the effective strategy or the version '
        'changed (schedule cron, L16)', () {
      final fresh = heatingDetail(
        effective: strategyJson(60, 2, 'AUTO'),
        transform: (json) => {...json, 'configurationVersion': 999},
      );
      expect(
        StrategyConflict.detect(started, StrategyBaseline.of(fresh)),
        isNull,
      );
    });

    test('each changed base field and the suspension is reported', () {
      final conflict = StrategyConflict.detect(
        started,
        StrategyBaseline.of(
          heatingDetail(
            base: strategyJson(60, 2, 'MANUAL'),
            heatingSuspended: true,
          ),
        ),
      )!;
      expect(conflict.fields, StrategyConflictField.values);
      expect(
        conflict,
        StrategyConflict(started: started, current: conflict.current),
      );
      expect(conflict.hashCode, isA<int>());
      expect(conflict.toString(), contains('->'));
    });

    test('only the suspension changed', () {
      final conflict = StrategyConflict.detect(
        started,
        StrategyBaseline.of(heatingDetail(heatingSuspended: true)),
      )!;
      expect(conflict.fields, [StrategyConflictField.suspended]);
    });

    test('a base that disappeared changes every strategy field', () {
      final conflict = StrategyConflict.detect(
        started,
        StrategyBaseline.of(heatingDetail(base: null)),
      )!;
      expect(conflict.fields, [
        StrategyConflictField.target,
        StrategyConflictField.hysteresis,
        StrategyConflictField.mode,
      ]);
    });
  });

  group('relayReportAfter', () {
    final requestedAt = DateTime.utc(2026, 11, 18, 7, 41);
    final after = requestedAt.add(const Duration(seconds: 3));

    test('a heartbeat at or before the PATCH does not count', () {
      expect(
        relayReportAfter(
          heatingDetail(lastSeenAt: requestedAt, relays: [false, false]),
          requestedAt,
        ),
        RelayReport.awaitingHeartbeat,
      );
      expect(
        relayReportAfter(
          heatingDetail(transform: (json) => {...json, 'lastSeenAt': null}),
          requestedAt,
        ),
        RelayReport.awaitingHeartbeat,
      );
    });

    test('a later heartbeat: all outputs off, one on, or none reported', () {
      expect(
        relayReportAfter(
          heatingDetail(lastSeenAt: after, relays: [false, false, false]),
          requestedAt,
        ),
        RelayReport.outputsOff,
      );
      expect(
        relayReportAfter(
          heatingDetail(
            lastSeenAt: after,
            relays: [true, false],
            commanded: [false, false],
          ),
          requestedAt,
        ),
        RelayReport.outputOn,
      );
      // Still commanded on: the OFF commands were not applied yet.
      final stale = heatingDetail(lastSeenAt: after, relays: [true, false]);
      expect(
        relayReportAfter(stale, requestedAt),
        RelayReport.awaitingHeartbeat,
      );
      expect(
        relayReportAfter(stale, requestedAt, requireCommandedOff: false),
        RelayReport.outputOn,
      );
      expect(
        relayReportAfter(heatingDetail(lastSeenAt: after), requestedAt),
        RelayReport.notReported,
      );
    });
  });

  test('state equality', () {
    final at = DateTime.utc(2026);
    const result = ControlStrategyUpdateResult(configurationVersion: 1);
    const failure = ApiFailure.notFound(code: 'DEVICE_NOT_FOUND');
    const conflict = StrategyConflict(
      started: StrategyBaseline(base: null, suspended: false),
      current: StrategyBaseline(base: null, suspended: true),
    );
    final pairs = <(Object, Object)>[
      (const SuspensionIdle(), const SuspensionIdle()),
      (
        const SuspensionSending(suspend: true),
        const SuspensionSending(suspend: true),
      ),
      (
        SuspensionAwaiting(suspend: true, requestedAt: at),
        SuspensionAwaiting(suspend: true, requestedAt: at),
      ),
      (
        SuspendApplied(relays: RelayReport.outputsOff, heartbeatAt: at),
        SuspendApplied(relays: RelayReport.outputsOff, heartbeatAt: at),
      ),
      (
        const ResumeApplied(strategyRestored: true),
        const ResumeApplied(strategyRestored: true),
      ),
      (
        const SuspensionTimedOut(suspend: false),
        const SuspensionTimedOut(suspend: false),
      ),
      (
        const SuspensionFailed(suspend: true, failure: failure),
        const SuspensionFailed(suspend: true, failure: failure),
      ),
      (const StrategyEditIdle(), const StrategyEditIdle()),
      (const StrategyEditChecking(), const StrategyEditChecking()),
      (const StrategyEditSaving(), const StrategyEditSaving()),
      (
        const StrategyEditConflict(conflict),
        const StrategyEditConflict(conflict),
      ),
      (
        const StrategyEditSaved(result: result, suspended: false),
        const StrategyEditSaved(result: result, suspended: false),
      ),
      (const StrategyEditFailed(failure), const StrategyEditFailed(failure)),
    ];
    for (final (a, b) in pairs) {
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    }
    expect(
      const SuspendApplied(relays: RelayReport.awaitingHeartbeat).isBusy,
      isTrue,
    );
    expect(
      const SuspendApplied(relays: RelayReport.outputsOff).isBusy,
      isFalse,
    );
  });
}
