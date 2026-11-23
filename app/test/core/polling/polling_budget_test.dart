import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/core/polling/polling_budget.dart';
import 'package:gi_home/src/features/devices/domain/freshness_policy.dart';

void main() {
  group('heating card cadence', () {
    test('up to two cards poll at the base cadence', () {
      for (final cards in [0, 1, 2]) {
        expect(
          PollingBudget.heatingCardInterval(cards),
          PollingBudget.heatingCard,
          reason: '$cards cards',
        );
      }
    });

    test('more cards poll slower, rounded up to whole seconds', () {
      expect(PollingBudget.heatingCardInterval(3), const Duration(seconds: 18));
      expect(PollingBudget.heatingCardInterval(4), const Duration(seconds: 24));
      expect(PollingBudget.heatingCardInterval(5), const Duration(seconds: 30));
      expect(PollingBudget.heatingCardInterval(7), const Duration(seconds: 42));
    });

    test('Home with any number of cards stays within the budget', () {
      for (var cards = 0; cards <= 50; cards++) {
        expect(
          PollingBudget.homeRequestsPerMinuteFor(cards),
          lessThanOrEqualTo(PollingBudget.homeRequestsPerMinute),
          reason: '$cards cards',
        );
      }
    });

    test('a card is never polled faster than the base cadence', () {
      for (var cards = 0; cards <= 50; cards++) {
        expect(
          PollingBudget.heatingCardInterval(cards),
          greaterThanOrEqualTo(PollingBudget.heatingCard),
        );
      }
    });

    test('the freshness policy follows the cadence', () {
      final policy = FreshnessPolicy.heatingCards(5);
      expect(policy.interval, const Duration(seconds: 30));
      expect(policy.staleAfter, const Duration(seconds: 60));
    });

    test('the freshness policy of few cards is the base policy', () {
      expect(
        FreshnessPolicy.heatingCards(1).interval,
        FreshnessPolicy.heatingCard.interval,
      );
    });
  });

  group('documented cadences', () {
    test('the list is polled twice a minute', () {
      expect(PollingBudget.deviceListRequestsPerMinute, 2);
    });

    test('details poll 12 times a minute, 4 when idle', () {
      expect(PollingBudget.perMinute(PollingBudget.deviceDetail), 12);
      expect(PollingBudget.perMinute(PollingBudget.deviceDetailIdle), 4);
    });

    test('a command burst stays under 30 requests a minute', () {
      expect(PollingBudget.perMinute(PollingBudget.postCommandPoll), 30);
    });

    test('the policies read the same constants', () {
      expect(FreshnessPolicy.deviceList.interval, PollingBudget.deviceList);
      expect(FreshnessPolicy.deviceDetail.interval, PollingBudget.deviceDetail);
      expect(
        FreshnessPolicy.deviceDetailIdle.interval,
        PollingBudget.deviceDetailIdle,
      );
      expect(
        FreshnessPolicy.deviceDetailIdleAfter,
        PollingBudget.deviceDetailIdleAfter,
      );
    });
  });
}
