import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/core/data/polled_data.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';

import '../../support/fixtures.dart';

void main() {
  final now = DateTime.utc(2026, 11, 18, 7, 41);
  var nextId = 0;

  DeviceListItem device({
    String? name,
    String connectivity = 'ONLINE',
    String? currentState,
    int faults = 0,
    bool heating = false,
    bool suspended = false,
    bool dryRun = false,
    bool enabled = true,
  }) {
    final id = 'device-${nextId++}';
    return listedDevice({
      'id': id,
      'name': name ?? id,
      'connectivityState': connectivity,
      'currentState': currentState,
      'activeFaultCount': faults,
      'heatingRelayEntityId': heating ? 'relay-$id' : null,
      'heatingSuspended': suspended,
      'dryRun': dryRun,
      'enabled': enabled,
    });
  }

  HomeCondition evaluate(
    List<DeviceListItem> devices, {
    Duration age = const Duration(seconds: 5),
    bool refreshFailed = false,
    Map<String, PolledData<DeviceDetail>> heatingCards = const {},
  }) => HomeCondition.evaluate(
    Fetched(devices, now.subtract(age)),
    now: now,
    refreshFailed: refreshFailed,
    heatingCards: heatingCards,
  );

  /// Card state of a heating device whose details loaded.
  PolledData<DeviceDetail> loadedCard(
    DeviceListItem device, [
    Map<String, Object?> overrides = const {},
  ]) => PolledData(
    data: Fetched(
      fixtureDetail({
        ...entityRichDetailJson(),
        'id': device.id,
        'diagnostics': null,
        ...overrides,
      }),
      now,
    ),
  );

  List<AttentionKind> kinds(HomeCondition condition) => [
    for (final item in condition.items) item.kind,
  ];

  group('good', () {
    test('every enabled device online without faults', () {
      final condition = evaluate([device(), device(heating: true)]);

      expect(condition.level, ConditionLevel.good);
      expect(condition.items, isEmpty);
      expect(condition.limitedReasons, isEmpty);
    });

    test('disabled devices are ignored', () {
      final condition = evaluate([
        device(),
        device(enabled: false, connectivity: 'ERROR', faults: 3),
      ]);

      expect(condition.level, ConditionLevel.good);
    });

    test('heatingSuspended on a device without heating relay is ignored', () {
      expect(evaluate([device(suspended: true)]).level, ConditionLevel.good);
    });
  });

  group('action required', () {
    for (final state in ['FAULT', 'SAFE_MODE']) {
      test('controller in $state', () {
        final condition = evaluate([device(currentState: state)]);

        expect(condition.level, ConditionLevel.actionRequired);
        expect(kinds(condition), [AttentionKind.firmwareFault]);
      });
    }

    test('connectivity ERROR', () {
      final condition = evaluate([device(connectivity: 'ERROR')]);

      expect(condition.level, ConditionLevel.actionRequired);
      expect(kinds(condition), [AttentionKind.connectivityError]);
    });

    test('active faults on a heating device', () {
      final condition = evaluate([device(heating: true, faults: 2)]);

      expect(condition.level, ConditionLevel.actionRequired);
      expect(kinds(condition), [AttentionKind.heatingFaults]);
    });

    test('wins over limited data', () {
      final condition = evaluate([
        device(currentState: 'FAULT'),
      ], refreshFailed: true);

      expect(condition.level, ConditionLevel.actionRequired);
      expect(condition.limitedReasons, [LimitedDataReason.refreshFailed]);
    });
  });

  group('needs attention', () {
    test('active faults on a non-heating device', () {
      final condition = evaluate([device(faults: 1)]);

      expect(condition.level, ConditionLevel.needsAttention);
      expect(kinds(condition), [AttentionKind.faults]);
    });

    test('offline and stale devices', () {
      final condition = evaluate([
        device(connectivity: 'OFFLINE'),
        device(connectivity: 'STALE'),
      ]);

      expect(condition.level, ConditionLevel.needsAttention);
      expect(kinds(condition), [AttentionKind.offline, AttentionKind.stale]);
    });

    test('suspended heating', () {
      final condition = evaluate([device(heating: true, suspended: true)]);

      expect(condition.level, ConditionLevel.needsAttention);
      expect(kinds(condition), [AttentionKind.heatingSuspended]);
    });

    test('dry-run', () {
      final condition = evaluate([device(dryRun: true)]);

      expect(condition.level, ConditionLevel.needsAttention);
      expect(kinds(condition), [AttentionKind.dryRun]);
    });

    test('wins over limited data', () {
      final condition = evaluate([
        device(connectivity: 'OFFLINE'),
      ], age: const Duration(minutes: 10));

      expect(condition.level, ConditionLevel.needsAttention);
      expect(condition.limitedReasons, [LimitedDataReason.outdated]);
    });
  });

  group('limited data never reads as good', () {
    test('the latest refresh failed', () {
      final condition = evaluate([device()], refreshFailed: true);

      expect(condition.level, ConditionLevel.limitedData);
      expect(condition.limitedReasons, [LimitedDataReason.refreshFailed]);
    });

    test('the list is older than 2 minutes', () {
      expect(
        evaluate([device()], age: const Duration(minutes: 2)).level,
        ConditionLevel.good,
      );
      final outdated = evaluate([
        device(),
      ], age: const Duration(minutes: 2, seconds: 1));
      expect(outdated.level, ConditionLevel.limitedData);
      expect(outdated.limitedReasons, [LimitedDataReason.outdated]);
    });

    test('no enabled devices', () {
      final condition = evaluate([device(enabled: false)]);

      expect(condition.level, ConditionLevel.limitedData);
      expect(condition.limitedReasons, [LimitedDataReason.noDevices]);
    });

    test('devices that never reported (UNKNOWN, PROVISIONING)', () {
      final condition = evaluate([
        device(connectivity: 'UNKNOWN'),
        device(connectivity: 'PROVISIONING'),
      ]);

      expect(condition.level, ConditionLevel.limitedData);
      expect(kinds(condition), [AttentionKind.noData, AttentionKind.noData]);
    });

    test('the recorded dev appliance: three devices without data yet', () {
      final condition = HomeCondition.evaluate(
        Fetched(fixtureDevices(), now),
        now: now,
        refreshFailed: false,
      );

      expect(condition.level, ConditionLevel.limitedData);
      expect(kinds(condition), List.filled(3, AttentionKind.noData));
      expect(condition.limitedReasons, isEmpty);
    });
  });

  group('heating cards', () {
    test('loaded card details keep a good home good', () {
      final heating = device(heating: true);
      final condition = evaluate(
        [heating],
        heatingCards: {heating.id: loadedCard(heating)},
      );

      expect(condition.level, ConditionLevel.good);
    });

    test('a card still loading for the first time is not a failure', () {
      final heating = device(heating: true);
      final condition = evaluate(
        [heating],
        heatingCards: {heating.id: const PolledData(isRefreshing: true)},
      );

      expect(condition.level, ConditionLevel.good);
    });

    test('a failed card detail fetch means limited data', () {
      final heating = device(name: 'Kocioł', heating: true);
      final condition = evaluate(
        [heating, device()],
        heatingCards: {
          heating.id: loadedCard(heating)
              .failed(const ApiFailure.unreachable()),
        },
      );

      expect(condition.level, ConditionLevel.limitedData);
      expect(condition.limitedReasons, [
        LimitedDataReason.heatingDetailsFailed,
      ]);
      expect(kinds(condition), [AttentionKind.heatingDetailsUnavailable]);
      expect(condition.items.single.device, heating);
    });

    test('a failed first fetch (no details at all) means limited data', () {
      final heating = device(heating: true);
      final condition = evaluate(
        [heating],
        heatingCards: {
          heating.id: const PolledData(error: ApiFailure.timeout()),
        },
      );

      expect(condition.level, ConditionLevel.limitedData);
    });

    test('a failed card never hides faults or suspended heating', () {
      final faulty = device(heating: true, faults: 1);
      final suspended = device(heating: true, suspended: true);
      PolledData<DeviceDetail> failed() =>
          const PolledData(error: ApiFailure.timeout());

      expect(
        evaluate([faulty], heatingCards: {faulty.id: failed()}).level,
        ConditionLevel.actionRequired,
      );
      final condition = evaluate(
        [suspended],
        heatingCards: {suspended.id: failed()},
      );
      expect(condition.level, ConditionLevel.needsAttention);
      expect(
        condition.limitedReasons,
        contains(LimitedDataReason.heatingDetailsFailed),
      );
    });

    test('cards of disabled or non-heating devices are ignored', () {
      final disabled = device(heating: true, enabled: false);
      final plain = device();
      PolledData<DeviceDetail> failed() =>
          const PolledData(error: ApiFailure.timeout());

      final condition = evaluate(
        [disabled, plain],
        heatingCards: {disabled.id: failed(), plain.id: failed()},
      );

      expect(condition.level, ConditionLevel.good);
    });

    test('needs_configuration in the card details needs attention', () {
      final heating = device(heating: true);
      final condition = evaluate(
        [heating],
        heatingCards: {
          heating.id: loadedCard(heating, {'status': 'needs_configuration'}),
        },
      );

      expect(condition.level, ConditionLevel.needsAttention);
      expect(kinds(condition), [AttentionKind.needsConfiguration]);
    });
  });

  group('suggestions', () {
    test('items are ordered by severity, then by device name', () {
      final condition = evaluate([
        device(name: 'b', dryRun: true),
        device(name: 'Zeta', connectivity: 'ERROR'),
        device(name: 'a', dryRun: true),
        device(name: 'Alfa', currentState: 'FAULT', faults: 1),
      ]);

      expect(
        [for (final i in condition.items) '${i.device.name}:${i.kind.name}'],
        [
          'Alfa:firmwareFault',
          'Zeta:connectivityError',
          'Alfa:faults',
          'a:dryRun',
          'b:dryRun',
        ],
      );
    });

    test('at most three suggestions, the rest counted', () {
      final condition = evaluate([
        for (var i = 0; i < 5; i++) device(dryRun: true),
      ]);

      expect(condition.suggestions, hasLength(HomeCondition.maxSuggestions));
      expect(condition.hiddenItemCount, 2);
      expect(evaluate([device(dryRun: true)]).hiddenItemCount, 0);
    });
  });
}
