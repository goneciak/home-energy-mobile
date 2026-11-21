import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/features/devices/domain/controller_status.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';

import '../../support/fixtures.dart';

void main() {
  group('FreshnessPolicy', () {
    final fetchedAt = DateTime.utc(2026, 11, 18, 7, 41);

    test('polling cadence follows plan §11', () {
      expect(FreshnessPolicy.deviceList.interval, const Duration(seconds: 30));
      expect(FreshnessPolicy.deviceDetail.interval, const Duration(seconds: 5));
    });

    test('data is stale once older than twice the interval', () {
      const policy = FreshnessPolicy.deviceList;

      expect(policy.staleAfter, const Duration(minutes: 1));
      expect(
        policy.isStale(fetchedAt, fetchedAt.add(const Duration(minutes: 1))),
        isFalse,
      );
      expect(
        policy.isStale(
          fetchedAt,
          fetchedAt.add(const Duration(minutes: 1, milliseconds: 1)),
        ),
        isTrue,
      );
      expect(
        FreshnessPolicy.deviceDetail.isStale(
          fetchedAt,
          fetchedAt.add(const Duration(seconds: 11)),
        ),
        isTrue,
      );
    });

    test('a clock that moved backwards never yields a negative age', () {
      final earlier = fetchedAt.subtract(const Duration(hours: 1));

      expect(FreshnessPolicy.ageOf(fetchedAt, earlier), Duration.zero);
      expect(FreshnessPolicy.deviceList.isStale(fetchedAt, earlier), isFalse);
    });
  });

  group('ControllerStatus', () {
    final listedAt = DateTime.utc(2026, 11, 18, 7, 40);
    final detailAt = DateTime.utc(2026, 11, 18, 7, 41);

    Fetched<DeviceListItem> listed({String? state, int faults = 0}) => Fetched(
      listedDevice({'currentState': state, 'activeFaultCount': faults}),
      listedAt,
    );

    Fetched<DeviceDetail> detail(
      Map<String, Object?>? diagnostics, {
      DateTime? at,
    }) => Fetched(fixtureDetail({'diagnostics': diagnostics}), at ?? detailAt);

    test('the more recently received source is shown, with its time', () {
      final status = ControllerStatus.resolve(
        listItem: listed(state: 'HEATING'),
        detail: detail({
          'currentState': 'FAULT',
          'activeFaults': ['F1'],
        }),
      );

      expect(status.currentState!.value, FirmwareState.fault);
      expect(status.currentState!.source, ValueSource.diagnostics);
      expect(status.currentState!.receivedAt, detailAt);
      expect(status.activeFaultCount!.value, 1);
      expect(status.activeFaultCount!.source, ValueSource.diagnostics);
      expect(status.needsAttention, isTrue);
    });

    test('older diagnostics do not replace the list, but still alarm', () {
      final status = ControllerStatus.resolve(
        listItem: listed(state: 'READY'),
        detail: detail({
          'currentState': 'FAULT',
          'activeFaults': ['F1'],
        }, at: listedAt.subtract(const Duration(minutes: 1))),
      );

      expect(status.currentState!.value, FirmwareState.ready);
      expect(status.currentState!.source, ValueSource.deviceList);
      expect(status.currentState!.receivedAt, listedAt);
      expect(status.activeFaultCount!.value, 0);
      expect(status.needsAttention, isTrue);
    });

    test('diagnostics fill in what the list does not carry', () {
      final status = ControllerStatus.resolve(
        listItem: listed(),
        detail: detail({'currentState': 'SAFE_MODE'}),
      );

      expect(status.currentState!.value, FirmwareState.safeMode);
      expect(status.currentState!.source, ValueSource.diagnostics);
      expect(status.currentState!.receivedAt, detailAt);
      expect(status.activeFaultCount!.source, ValueSource.deviceList);
      expect(status.needsAttention, isTrue);
    });

    test('without a list item both come from diagnostics', () {
      final status = ControllerStatus.resolve(
        detail: detail({
          'activeFaults': ['F1', 'F2'],
        }),
      );

      expect(status.currentState, isNull);
      expect(status.activeFaultCount!.value, 2);
      expect(status.activeFaultCount!.source, ValueSource.diagnostics);
      expect(status.needsAttention, isTrue);
    });

    test('a safety interlock or a reboot loop needs attention', () {
      for (final key in ['safetyInterlockActive', 'rebootLoopDetected']) {
        final status = ControllerStatus.resolve(
          listItem: listed(state: 'READY'),
          detail: detail({key: true}),
        );
        expect(status.needsAttention, isTrue, reason: key);
      }
    });

    test('nothing known, nothing claimed', () {
      final status = ControllerStatus.resolve(detail: detail(null));

      expect(status.currentState, isNull);
      expect(status.activeFaultCount, isNull);
      expect(status.needsAttention, isFalse);
    });

    test('a quiet device needs no attention', () {
      final status = ControllerStatus.resolve(
        listItem: listed(state: 'HEATING'),
        detail: detail({
          'currentState': 'HEATING',
          'activeFaults': <String>[],
          'safetyInterlockActive': false,
          'rebootLoopDetected': false,
        }),
      );

      expect(status.needsAttention, isFalse);
    });

    test('list faults alone need attention', () {
      expect(
        ControllerStatus.resolve(listItem: listed(faults: 1)).needsAttention,
        isTrue,
      );
    });
  });
}
