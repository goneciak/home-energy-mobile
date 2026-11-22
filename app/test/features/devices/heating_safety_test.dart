import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/features/devices/domain/confirmation_policy.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';
import 'package:gi_home/src/features/devices/domain/heating_permission.dart';
import 'package:gi_home/src/features/devices/domain/safety_policy.dart';
import 'package:gi_home/src/features/devices/presentation/heating_safety_labels.dart';

import '../../support/fixtures.dart';

const _heatingRelay = 'heating-relay';
const _pumpRelay = 'pump-relay';
const _aux = 'aux-switch';
const _sensor = 'supply-temp';

Map<String, Object?> _entity(
  String id, {
  String domain = 'switch',
  bool writable = true,
  bool availability = true,
  bool enabled = true,
}) => {
  'id': id,
  'displayName': id,
  'sourceName': id,
  'domain': domain,
  'value': false,
  'readable': true,
  'writable': writable,
  'availability': availability,
  'enabled': enabled,
};

DeviceDetail _device({
  ConnectivityState connectivity = ConnectivityState.online,
  bool suspended = false,
  bool dryRun = false,
  String? firmwareState,
  Map<String, Object?> aux = const {},
  Object? pvHeatingConfig,
}) => fixtureDetail({
  'heatingSuspended': suspended,
  'dryRun': dryRun,
  'connectivityState': switch (connectivity) {
    ConnectivityState.online => 'ONLINE',
    ConnectivityState.stale => 'STALE',
    ConnectivityState.offline => 'OFFLINE',
    ConnectivityState.provisioning => 'PROVISIONING',
    ConnectivityState.error => 'ERROR',
    ConnectivityState.unknown => 'SOMETHING_NEW',
  },
  'heatingRelayEntityId': _heatingRelay,
  'pumpRelayEntityId': _pumpRelay,
  'diagnostics': {'currentState': ?firmwareState},
  'pvHeatingConfig': pvHeatingConfig,
  'entities': [
    _entity(_heatingRelay),
    _entity(_pumpRelay),
    {..._entity(_aux), ...aux},
    _entity(_sensor, domain: 'sensor', writable: false),
  ],
});

final _now = DateTime.utc(2026, 11, 21, 12);

DeviceSnapshot _data(
  DeviceDetail device, {
  Duration age = Duration.zero,
  bool fromSnapshot = false,
  FirmwareState? currentState,
}) => DeviceSnapshot(
  device: device,
  fetchedAt: _now.subtract(age),
  fromSnapshot: fromSnapshot,
  currentState: currentState,
);

final _owner = HeatingPermission.of(UserRole.owner);
final _user = HeatingPermission.of(UserRole.user);

SafetyDecision _switch(
  DeviceSnapshot data, {
  String entityId = _aux,
  bool on = true,
  HeatingPermission? permission,
}) => SafetyPolicy.evaluateSwitch(
  data: data,
  entityId: entityId,
  requestedOn: on,
  permission: permission ?? _owner,
  now: _now,
);

void main() {
  group('HeatingPermission (catalog-driven)', () {
    for (final (role, control) in [
      (UserRole.owner, true),
      (UserRole.admin, true),
      (UserRole.user, false),
      (UserRole.service, false),
      (UserRole.unknown, false),
      (null, false),
    ]) {
      test('$role ${control ? 'controls' : 'is view-only'}', () {
        final permission = HeatingPermission.of(role);
        expect(permission.canSwitch, control);
        expect(permission.canSuspend, control);
        expect(permission.canEditStrategy, control);
        expect(permission.canControl, control);
        expect(permission.isViewOnly, !control);
        if (role != null) {
          expect(permission.canSwitch, GiEndpoints.setSwitchState.allows(role));
        }
      });
    }

    test('any single write permission counts as control', () {
      for (final permission in const [
        HeatingPermission(
          canSwitch: true,
          canSuspend: false,
          canEditStrategy: false,
        ),
        HeatingPermission(
          canSwitch: false,
          canSuspend: true,
          canEditStrategy: false,
        ),
        HeatingPermission(
          canSwitch: false,
          canSuspend: false,
          canEditStrategy: true,
        ),
      ]) {
        expect(permission.canControl, isTrue);
      }
    });
  });

  group('SafetyPolicy.evaluateSwitch', () {
    test('a writable, enabled, available switch on live data is allowed', () {
      for (final on in [true, false]) {
        final decision = _switch(_data(_device()), on: on);
        expect(decision, const Allowed());
        expect(decision.isAllowed, isTrue);
      }
    });

    test('USER and SERVICE: hidden control (notOwnerAdmin)', () {
      for (final role in [UserRole.user, UserRole.service]) {
        final decision = _switch(
          _data(_device()),
          permission: HeatingPermission.of(role),
        );
        expect(decision, Locked(const [LockReason.notOwnerAdmin]));
        expect((decision as Locked).hidesControl, isTrue);
      }
    });

    test('heating and pump relays are always read-only, ON and OFF', () {
      for (final id in [_heatingRelay, _pumpRelay]) {
        for (final on in [true, false]) {
          final decision = _switch(_data(_device()), entityId: id, on: on);
          expect(decision, Locked(const [LockReason.heatingOrPumpRelay]));
          expect((decision as Locked).hidesControl, isFalse);
        }
      }
    });

    test('an entity missing from the device is locked', () {
      expect(
        _switch(_data(_device()), entityId: 'gone'),
        Locked(const [LockReason.entityMissing]),
      );
    });

    test('a sensor, or a switch that is not writable', () {
      expect(
        _switch(_data(_device()), entityId: _sensor),
        Locked(const [LockReason.notWritableSwitch]),
      );
      expect(
        _switch(_data(_device(aux: {'writable': false}))),
        Locked(const [LockReason.notWritableSwitch]),
      );
    });

    test('a disabled entity', () {
      expect(
        _switch(_data(_device(aux: {'enabled': false})), on: false),
        Locked(const [LockReason.entityDisabled]),
      );
    });

    test('an unavailable entity', () {
      expect(
        _switch(_data(_device(aux: {'availability': false})), on: false),
        Locked(const [LockReason.entityUnavailable]),
      );
    });

    group('every connectivity value other than ONLINE locks (§12.6)', () {
      for (final state in ConnectivityState.values) {
        test(state.name, () {
          for (final on in [true, false]) {
            final decision = _switch(
              _data(_device(connectivity: state)),
              on: on,
            );
            expect(
              decision,
              state == ConnectivityState.online
                  ? const Allowed()
                  : Locked(const [LockReason.staleData]),
            );
          }
        });
      }
    });

    test('data older than twice the polling interval locks', () {
      final staleAfter = FreshnessPolicy.deviceDetail.staleAfter;
      expect(_switch(_data(_device(), age: staleAfter)), const Allowed());
      expect(
        _switch(
          _data(_device(), age: staleAfter + const Duration(milliseconds: 1)),
        ),
        Locked(const [LockReason.staleData]),
      );
    });

    test('snapshot data locks', () {
      expect(
        _switch(_data(_device(), fromSnapshot: true)),
        Locked(const [LockReason.staleData]),
      );
    });

    test('suspended: ON locked for every switch, OFF allowed', () {
      final data = _data(_device(suspended: true));
      expect(_switch(data), Locked(const [LockReason.suspendedOnRequest]));
      expect(_switch(data, on: false), const Allowed());
      expect(
        _switch(data, entityId: _heatingRelay),
        Locked(const [
          LockReason.heatingOrPumpRelay,
          LockReason.suspendedOnRequest,
        ]),
      );
    });

    group('fault latched: ON locked, OFF allowed', () {
      for (final state in FirmwareState.values) {
        test('from diagnostics: ${state.name}', () {
          final raw = switch (state) {
            FirmwareState.selfTest => 'SELF_TEST',
            FirmwareState.heatingRequested => 'HEATING_REQUESTED',
            FirmwareState.heatingVerifying => 'HEATING_VERIFYING',
            FirmwareState.safeMode => 'SAFE_MODE',
            _ => state.name.toUpperCase(),
          };
          final data = _data(_device(firmwareState: raw));
          expect(
            _switch(data),
            state.isCritical
                ? Locked(const [LockReason.faultLatched])
                : const Allowed(),
          );
          expect(_switch(data, on: false), const Allowed());
        });
      }

      test('the merged currentState overrides diagnostics', () {
        expect(
          _switch(
            _data(
              _device(firmwareState: 'IDLE'),
              currentState: FirmwareState.fault,
            ),
          ),
          Locked(const [LockReason.faultLatched]),
        );
        expect(
          _switch(
            _data(
              _device(firmwareState: 'SAFE_MODE'),
              currentState: FirmwareState.idle,
            ),
          ),
          const Allowed(),
        );
      });

      test('no diagnostics at all is not a fault', () {
        final device = _device().copyWith(diagnostics: null);
        expect(_switch(_data(device)), const Allowed());
      });
    });

    test('every reason at once, sorted by priority', () {
      final data = _data(
        _device(
          connectivity: ConnectivityState.offline,
          suspended: true,
          firmwareState: 'FAULT',
          aux: {'writable': false, 'enabled': false, 'availability': false},
        ),
      );
      final decision = _switch(data, permission: _user) as Locked;
      expect(decision.reasons, [
        LockReason.notOwnerAdmin,
        LockReason.notWritableSwitch,
        LockReason.entityDisabled,
        LockReason.entityUnavailable,
        LockReason.staleData,
        LockReason.suspendedOnRequest,
        LockReason.faultLatched,
      ]);
      expect(decision.primary, LockReason.notOwnerAdmin);
      expect(decision.hidesControl, isTrue);
    });

    test('heating relay that is also missing from entities', () {
      final device = _device().copyWith(entities: const []);
      expect(
        _switch(_data(device), entityId: _heatingRelay),
        Locked(const [LockReason.heatingOrPumpRelay, LockReason.entityMissing]),
      );
    });
  });

  group('SafetyPolicy suspend / resume / strategy', () {
    final stale = _data(_device(connectivity: ConnectivityState.stale));
    final live = _data(_device());

    test('suspend stays available on stale data, only roles gate it', () {
      expect(SafetyPolicy.evaluateSuspend(permission: _owner), const Allowed());
      expect(
        SafetyPolicy.evaluateSuspend(permission: _user),
        Locked(const [LockReason.notOwnerAdmin]),
      );
    });

    test('resume needs live data and a write role', () {
      expect(
        SafetyPolicy.evaluateResume(data: live, permission: _owner, now: _now),
        const Allowed(),
      );
      expect(
        SafetyPolicy.evaluateResume(data: stale, permission: _owner, now: _now),
        Locked(const [LockReason.staleData]),
      );
      expect(
        SafetyPolicy.evaluateResume(data: stale, permission: _user, now: _now),
        Locked(const [LockReason.notOwnerAdmin, LockReason.staleData]),
      );
    });

    test('strategy editing needs live data and a write role', () {
      expect(
        SafetyPolicy.evaluateStrategyEdit(
          data: live,
          permission: _owner,
          now: _now,
        ),
        const Allowed(),
      );
      expect(
        SafetyPolicy.evaluateStrategyEdit(
          data: stale,
          permission: _owner,
          now: _now,
        ),
        Locked(const [LockReason.staleData]),
      );
      expect(
        SafetyPolicy.evaluateStrategyEdit(
          data: live,
          permission: _user,
          now: _now,
        ),
        Locked(const [LockReason.notOwnerAdmin]),
      );
    });
  });

  group('SafetyDecision value semantics', () {
    test('Locked dedupes and sorts, equality and hashCode', () {
      final a = Locked(const [LockReason.staleData, LockReason.notOwnerAdmin]);
      final b = Locked(const [
        LockReason.notOwnerAdmin,
        LockReason.staleData,
        LockReason.staleData,
      ]);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(Locked(const [LockReason.staleData])));
      expect(
        a,
        isNot(Locked(const [LockReason.staleData, LockReason.faultLatched])),
      );
      expect(a, isNot(const Allowed()));
      expect(a.isAllowed, isFalse);
      expect(a.toString(), contains('staleData'));
      expect(
        () => a.reasons.add(LockReason.faultLatched),
        throwsUnsupportedError,
      );
    });

    test('Allowed equality', () {
      expect(const Allowed(), const Allowed());
      expect(const Allowed().hashCode, const Allowed().hashCode);
      expect(const Allowed(), isNot(Locked(const [LockReason.staleData])));
      expect(const Allowed().toString(), 'Allowed()');
    });
  });

  group('ConfirmationPolicy', () {
    ConfirmationRequirement of(HeatingAction action, {bool dryRun = false}) =>
        ConfirmationPolicy.of(action, _device(dryRun: dryRun));

    const sheet = ConfirmationKind.sheet;

    test('suspend: hold to confirm, names the effect and recovery', () {
      // Built at runtime on purpose: a `const` instance is canonicalised at
      // compile time and never runs the constructor, which the 100% coverage
      // gate on ConfirmationPolicy would count as uncovered.
      // ignore: prefer_const_constructors
      final suspend = SuspendHeating();
      for (final dryRun in [false, true]) {
        final requirement = of(suspend, dryRun: dryRun);
        expect(
          requirement,
          const ConfirmationRequirement(ConfirmationKind.hold, [
            Consequence.stopsHeating,
          ]),
        );
        expect(requirement.needsConfirmation, isTrue);
      }
    });

    test('resume: consequence sheet', () {
      expect(
        of(const ResumeHeating()),
        const ConfirmationRequirement(sheet, [
          Consequence.boilerMayStartSoon,
          Consequence.restoresBaseOrSchedule,
        ]),
      );
      expect(
        of(const ResumeHeating(), dryRun: true).consequences.last,
        Consequence.dryRunOutputsStayOff,
      );
    });

    test('switch OFF needs no confirmation, ON a sheet', () {
      expect(of(const SetSwitch(on: false)), ConfirmationRequirement.none);
      expect(ConfirmationRequirement.none.needsConfirmation, isFalse);
      expect(
        of(const SetSwitch(on: true)),
        const ConfirmationRequirement(sheet, [
          Consequence.commandNotPhysicallyVerified,
        ]),
      );
      expect(
        of(const SetSwitch(on: true), dryRun: true),
        const ConfirmationRequirement(sheet, [
          Consequence.commandNotPhysicallyVerified,
          Consequence.dryRunOutputsStayOff,
        ]),
      );
    });

    group('strategy change', () {
      ControlStrategy strategy(
        double target, [
        ControlStrategyMode mode = ControlStrategyMode.auto,
      ]) => ControlStrategy(
        targetTemperatureCelsius: target,
        hysteresisCelsius: 4,
        mode: mode,
      );

      test('small raise, lowering, entering OFF: no confirmation', () {
        for (final (from, to) in [
          (strategy(50), strategy(60)),
          (strategy(60), strategy(40)),
          (strategy(50), strategy(50, ControlStrategyMode.off)),
          (
            strategy(50, ControlStrategyMode.off),
            strategy(50, ControlStrategyMode.off),
          ),
          (null, strategy(80)),
        ]) {
          expect(
            of(ChangeStrategy(from: from, to: to), dryRun: true),
            ConfirmationRequirement.none,
          );
        }
      });

      test('raise by more than 10 °C', () {
        expect(
          of(ChangeStrategy(from: strategy(50), to: strategy(60.5))),
          const ConfirmationRequirement(sheet, [Consequence.largeTargetRaise]),
        );
      });

      test('leaving OFF to AUTO or MANUAL', () {
        for (final mode in [
          ControlStrategyMode.auto,
          ControlStrategyMode.manual,
        ]) {
          expect(
            of(
              ChangeStrategy(
                from: strategy(50, ControlStrategyMode.off),
                to: strategy(50, mode),
              ),
            ),
            const ConfirmationRequirement(sheet, [Consequence.leavesOffMode]),
          );
        }
      });

      test('above the PV safe maximum, with dry-run and all at once', () {
        final device = _device(
          dryRun: true,
          pvHeatingConfig: {'mode': 'HYBRID', 'safeMaxTemperatureCelsius': 65},
        );
        expect(
          ConfirmationPolicy.of(
            ChangeStrategy(from: strategy(56), to: strategy(65)),
            device,
          ),
          ConfirmationRequirement.none,
        );
        expect(
          ConfirmationPolicy.of(
            ChangeStrategy(
              from: strategy(50, ControlStrategyMode.off),
              to: strategy(70),
            ),
            device,
          ),
          const ConfirmationRequirement(sheet, [
            Consequence.largeTargetRaise,
            Consequence.leavesOffMode,
            Consequence.aboveSafeMax,
            Consequence.dryRunOutputsStayOff,
          ]),
        );
      });
    });

    test('requirement value semantics', () {
      const a = ConfirmationRequirement(sheet, [Consequence.leavesOffMode]);
      expect(
        a.hashCode,
        of(
          const ChangeStrategy(
            from: ControlStrategy(
              targetTemperatureCelsius: 1,
              hysteresisCelsius: 1,
              mode: ControlStrategyMode.off,
            ),
            to: ControlStrategy(
              targetTemperatureCelsius: 1,
              hysteresisCelsius: 1,
              mode: ControlStrategyMode.auto,
            ),
          ),
        ).hashCode,
      );
      expect(a, isNot(const ConfirmationRequirement(sheet)));
      expect(
        a,
        isNot(const ConfirmationRequirement(sheet, [Consequence.aboveSafeMax])),
      );
      expect(
        a,
        isNot(
          const ConfirmationRequirement(ConfirmationKind.hold, [
            Consequence.leavesOffMode,
          ]),
        ),
      );
      expect(a, isNot(Object()));
      expect(a.toString(), contains('leavesOffMode'));
    });
  });

  group('texts', () {
    final pl = lookupAppLocalizations(const Locale('pl'));
    final en = lookupAppLocalizations(const Locale('en'));

    test('every lock reason and consequence has a distinct text', () {
      for (final l10n in [pl, en]) {
        final locks = LockReason.values.map((r) => lockReasonText(l10n, r));
        final consequences = Consequence.values.map(
          (c) => consequenceText(l10n, c),
        );
        expect(locks.toSet(), hasLength(LockReason.values.length));
        expect(consequences.toSet(), hasLength(Consequence.values.length));
      }
    });

    test('key wording (plan §12, PRD §8.6)', () {
      expect(
        pl.heatingViewOnlyHint,
        'Zmiany ogrzewania może wprowadzić właściciel.',
      );
      expect(pl.consequenceBoilerMayStartSoon, contains('~30 s'));
      expect(lockReasonText(pl, LockReason.faultLatched), contains('reset'));
      expect(en.heatingDryRunBanner, contains('outputs stay off'));
    });
  });
}
