import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:gi_home/src/features/demo/data/demo_core.dart';
import 'package:gi_home/src/features/demo/data/demo_names.dart';

/// The transport of demo mode (plan §19.5): every GI Core request is
/// answered in process by [core]. No socket is opened, not even on
/// localhost.
final class DemoHttpClientAdapter implements HttpClientAdapter {
  new(this.core, {this.latency = Duration.zero, this.languageCode});

  final DemoCore core;

  /// The language the app shows now (`en` or `pl`), asked on every answer so
  /// a language change shows at once; `null` leaves the Polish fixture names.
  final String Function()? languageCode;

  /// Delay before each answer, so loading states show briefly.
  final Duration latency;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = await _readBody(options, requestStream);
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final reply = core.handle(
      options.method,
      options.uri.path,
      body,
      query: options.uri.queryParameters,
    );
    final isLogin =
        reply.status == 200 &&
        options.method == 'POST' &&
        (options.uri.path.endsWith('/auth/login') ||
            options.uri.path.endsWith('/auth/refresh'));
    return ResponseBody.fromString(
      reply.body == null
          ? ''
          : jsonEncode(
              localizeDemoNames(reply.body, languageCode?.call() ?? 'pl'),
            ),
      reply.status,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
        if (isLogin) 'set-cookie': [DemoCore.setCookie],
      },
    );
  }

  static Future<Object?> _readBody(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
  ) async {
    if (requestStream != null) {
      final bytes = await requestStream.fold<List<int>>(
        [],
        (all, chunk) => all..addAll(chunk),
      );
      if (bytes.isEmpty) return null;
      try {
        return jsonDecode(utf8.decode(bytes));
      } on FormatException {
        return null;
      }
    }
    return switch (options.data) {
      final String text when text.isNotEmpty => _tryDecode(text),
      final Map<Object?, Object?> map => map,
      _ => null,
    };
  }

  static Object? _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  /// A no-op: the clients that share this adapter come and go with the
  /// session, while the demo state lives until demo mode ends.
  @override
  void close({bool force = false}) {}
}
