import 'package:flutter_test/flutter_test.dart';
import 'package:gi_core_api/gi_core_api.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/features/attention/domain/attention_feed.dart';
import 'package:gi_home/src/features/home/domain/home_condition.dart';

import '../../support/fixtures.dart';

/// Derivation of the "Uwaga" list (plan §15).
void main() {
  final now = DateTime(2026, 11, 22, 12);

  DeviceListItem device(String id, Map<String, Object?> overrides) =>
      listedDevice({
        'id': id,
        'name': 'Urządzenie $id',
        'connectivityState': 'ONLINE',
        'activeFaultCount': 0,
        'currentState': null,
        'heatingSuspended': false,
        'enabled': true,
        ...overrides,
      });

  AttentionFeed feedOf(
    List<DeviceListItem> devices, {
    bool mustChangePassword = false,
    AttentionFeed? previous,
    DateTime? at,
    String userId = 'u1',
  }) => AttentionFeed.derive(
    userId: userId,
    devices: Fetched(devices, at ?? now),
    mustChangePassword: mustChangePassword,
    now: at ?? now,
    previous: previous,
  );

  group('one device, one condition', () {
    for (final (name, overrides, kind, severity) in [
      ('online, nothing wrong', <String, Object?>{}, null, null),
      (
        'offline',
        {'connectivityState': 'OFFLINE'},
        AttentionKind.offline,
        AttentionSeverity.important,
      ),
      (
        'stale telemetry',
        {'connectivityState': 'STALE'},
        AttentionKind.stale,
        AttentionSeverity.notice,
      ),
      (
        'connectivity error',
        {'connectivityState': 'ERROR'},
        AttentionKind.connectivityError,
        AttentionSeverity.critical,
      ),
      (
        'unknown connectivity (no data)',
        {'connectivityState': 'UNKNOWN'},
        AttentionKind.noData,
        AttentionSeverity.notice,
      ),
      (
        'firmware FAULT',
        {'currentState': 'FAULT'},
        AttentionKind.firmwareFault,
        AttentionSeverity.critical,
      ),
      (
        'SAFE_MODE',
        {'currentState': 'SAFE_MODE'},
        AttentionKind.firmwareFault,
        AttentionSeverity.critical,
      ),
      (
        'active faults',
        {'activeFaultCount': 2},
        AttentionKind.faults,
        AttentionSeverity.important,
      ),
    ]) {
      test(name, () {
        final feed = feedOf([device('a', overrides)]);
        if (kind == null) {
          expect(feed.active, isEmpty);
          expect(feed.badgeCount, 0);
        } else {
          expect(feed.active.map((e) => e.kind), [kind]);
          expect(feed.active.single.severity, severity);
          expect(feed.badgeCount, 1);
        }
      });
    }
  });

  test('disabled devices are ignored', () {
    final feed = feedOf([
      device('a', {'connectivityState': 'OFFLINE', 'enabled': false}),
    ]);
    expect(feed.active, isEmpty);
  });

  test('mustChangePassword is an important account entry', () {
    final feed = feedOf([], mustChangePassword: true);
    expect(feed.active, [AttentionEntry.mustChangePassword]);
    expect(feed.active.single.severity, AttentionSeverity.important);
  });

  test('entries are ordered critical, important, notice', () {
    final feed = feedOf([
      device('s', {'connectivityState': 'STALE'}),
      device('o', {'connectivityState': 'OFFLINE'}),
      device('f', {'currentState': 'FAULT'}),
    ]);
    expect(feed.active.map((e) => e.severity), [
      AttentionSeverity.critical,
      AttentionSeverity.important,
      AttentionSeverity.notice,
    ]);
  });

  test('a cleared entry is resolved for 24 h, then dropped', () {
    final offline = feedOf([
      device('a', {'connectivityState': 'OFFLINE'}),
    ]);
    final later = now.add(const Duration(minutes: 5));
    final cleared = feedOf([device('a', {})], previous: offline, at: later);

    expect(cleared.active, isEmpty);
    expect(cleared.badgeCount, 0);
    expect(cleared.resolved.single.kind, AttentionKind.offline);
    expect(cleared.resolved.single.resolvedAt, later);

    final nextDay = later.add(const Duration(hours: 24));
    expect(
      feedOf([device('a', {})], previous: cleared, at: nextDay).resolved,
      isEmpty,
    );
  });

  test('an entry reported again leaves the resolved list', () {
    final offline = feedOf([
      device('a', {'connectivityState': 'OFFLINE'}),
    ]);
    final cleared = feedOf([device('a', {})], previous: offline);
    final again = feedOf([
      device('a', {'connectivityState': 'OFFLINE'}),
    ], previous: cleared);
    expect(again.resolved, isEmpty);
    expect(again.badgeCount, 1);
  });

  test('another user never inherits resolved entries', () {
    final offline = feedOf([
      device('a', {'connectivityState': 'OFFLINE'}),
    ]);
    final other = feedOf([device('a', {})], previous: offline, userId: 'u2');
    expect(other.resolved, isEmpty);
  });
}
