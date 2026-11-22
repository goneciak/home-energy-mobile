@Tags(['golden'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/data/fetched.dart';
import 'package:gi_home/src/features/attention/domain/attention_feed.dart';
import 'package:gi_home/src/features/attention/presentation/attention_screen.dart';
import 'package:gi_home/src/features/devices/data/device_snapshot_store.dart';
import 'package:gi_home/src/features/devices/presentation/offline_snapshot_view.dart';
import 'package:material_ui/material_ui.dart';

import '../support/golden.dart';
import 'golden_devices.dart';

/// "Uwaga" (plan §15) and the offline snapshot banner (plan §8.3, G3).
void main() {
  const phones = [GoldenDevice.smallPhone, GoldenDevice.largePhone];

  final offline = goldenListed(
    GoldenIds.lamp,
    connectivity: 'OFFLINE',
    seenAgo: const Duration(minutes: 40),
  );
  final faulty = goldenListed(
    GoldenIds.boiler,
    overrides: {'currentState': 'FAULT'},
  );
  final stale = goldenListed(
    GoldenIds.sensor,
    connectivity: 'STALE',
    seenAgo: const Duration(minutes: 7),
  );

  AttentionFeed feed() {
    final before = AttentionFeed.derive(
      userId: 'u1',
      devices: Fetched([
        offline,
        faulty,
        goldenListed(GoldenIds.sensor, connectivity: 'OFFLINE'),
      ], goldenNow.subtract(const Duration(hours: 2))),
      mustChangePassword: false,
      now: goldenNow.subtract(const Duration(hours: 2)),
    );
    return AttentionFeed.derive(
      userId: 'u1',
      devices: Fetched([offline, faulty, stale], goldenNow),
      mustChangePassword: false,
      now: goldenNow.subtract(const Duration(minutes: 20)),
      previous: before,
    );
  }

  screenGoldens(
    'Uwaga: critical, important, notice and resolved',
    fileName: 'attention_list',
    devices: phones,
    screen: () => Scaffold(
      body: AttentionFeedView(feed: feed(), now: goldenNow, onOpen: (_) {}),
    ),
  );

  screenGoldens(
    'Uwaga: nothing to report',
    fileName: 'attention_empty',
    devices: phones,
    screen: () => Scaffold(
      body: AttentionFeedView(
        feed: const AttentionFeed.empty(userId: 'u1'),
        now: goldenNow,
        onOpen: (_) {},
      ),
    ),
  );

  screenGoldens(
    'Offline cold start: snapshot banner',
    fileName: 'offline_snapshot',
    devices: phones,
    screen: () => Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: OfflineSnapshotView(
          snapshot: DeviceSnapshot(
            userId: 'u1',
            devices: Fetched([
              goldenListed(GoldenIds.boiler),
              offline,
              stale,
            ], goldenNow.subtract(const Duration(hours: 3))),
          ),
          now: goldenNow,
        ),
      ),
    ),
  );
}
