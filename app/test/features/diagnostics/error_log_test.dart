import 'package:flutter_test/flutter_test.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';

void main() {
  final t0 = DateTime.utc(2026, 11, 18, 12);

  ErrorLogEntry entry(int i, {String? message}) => ErrorLogEntry.redacted(
    time: t0.add(Duration(seconds: i)),
    kind: ErrorKind.zone,
    message: message ?? 'error $i',
  );

  group('ErrorRingBuffer', () {
    test('keeps the newest entries up to its capacity, oldest first', () {
      final buffer = ErrorRingBuffer(capacity: 3);
      for (var i = 0; i < 5; i++) {
        buffer.add(entry(i));
      }

      expect(buffer.length, 3);
      expect(buffer.entries.map((e) => e.message), [
        'error 2',
        'error 3',
        'error 4',
      ]);
    });

    test('defaults to the last 200 entries', () {
      final buffer = ErrorRingBuffer();
      for (var i = 0; i < 250; i++) {
        buffer.add(entry(i));
      }

      expect(buffer.length, ErrorRingBuffer.defaultCapacity);
      expect(buffer.entries.first.message, 'error 50');
    });

    test('folds a repeat of the newest entry into its count', () {
      final buffer = ErrorRingBuffer(capacity: 3)
        ..add(entry(0, message: 'same'))
        ..add(entry(1, message: 'same'))
        ..add(entry(2, message: 'same'))
        ..add(entry(3, message: 'other'));

      expect(buffer.length, 2);
      expect(buffer.entries.first.count, 3);
      expect(buffer.entries.first.time, t0.add(const Duration(seconds: 2)));
      expect(buffer.toJson().first['count'], 3);
      expect(buffer.toJson().last.containsKey('count'), isFalse);
    });

    test('prependAll puts older entries first within the capacity', () {
      final buffer = ErrorRingBuffer(capacity: 3)..add(entry(9));
      buffer.prependAll([entry(1), entry(2), entry(3)]);

      expect(buffer.entries.map((e) => e.message), [
        'error 2',
        'error 3',
        'error 9',
      ]);
    });

    test('clear empties it', () {
      final buffer = ErrorRingBuffer()..add(entry(0));
      buffer.clear();

      expect(buffer.isEmpty, isTrue);
    });
  });

  group('ErrorLogEntry', () {
    test('redacts the message and the stack', () {
      final e = ErrorLogEntry.redacted(
        time: t0,
        kind: ErrorKind.flutter,
        message: 'failed for owner@example.com at 192.168.1.10',
        stack: '#0 main (http://192.168.1.10:3000/x)',
      );

      expect(e.message, 'failed for <email> at <ip>');
      expect(e.stack, '#0 main (http://<host>:3000/x)');
    });

    test('trims a long stack and a long message', () {
      final stack = [for (var i = 0; i < 50; i++) '#$i frame$i'].join('\n');
      final e = ErrorLogEntry.redacted(
        time: t0,
        kind: ErrorKind.platform,
        message: 'x' * 5000,
        stack: '$stack\n\n',
      );

      final lines = e.stack!.split('\n');
      expect(lines, hasLength(ErrorLogEntry.maxStackLines + 1));
      expect(lines.first, '#0 frame0');
      expect(lines.last, '… 20 more');
      expect(e.message.length, ErrorLogEntry.maxMessageLength + 1);
    });

    test('round-trips through JSON and re-redacts what it loads', () {
      final e = ErrorLogEntry.redacted(
        time: t0,
        kind: ErrorKind.unexpectedShape,
        message: 'DevicesController_list · items.0.dryRun',
        stack: '#0 x',
      );

      expect(ErrorLogEntry.fromJson(e.toJson()), e);
      expect(
        ErrorLogEntry.fromJson({
          'time': t0.toIso8601String(),
          'kind': 'zone',
          'message': 'leaked owner@example.com',
          'stack': 'Bearer abc',
          'count': 4,
        }),
        isA<ErrorLogEntry>()
            .having((e) => e.message, 'message', 'leaked <email>')
            .having((e) => e.stack, 'stack', 'Bearer <redacted>')
            .having((e) => e.count, 'count', 4),
      );
    });

    test('malformed JSON is dropped', () {
      expect(ErrorLogEntry.fromJson('x'), isNull);
      expect(ErrorLogEntry.fromJson({'kind': 'zone', 'message': 'm'}), isNull);
      expect(
        ErrorLogEntry.fromJson({
          'time': t0.toIso8601String(),
          'kind': 'nope',
          'message': 'm',
        }),
        isNull,
      );
    });
  });
}
