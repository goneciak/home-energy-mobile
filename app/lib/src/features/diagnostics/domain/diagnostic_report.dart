import 'dart:convert';

import 'package:gi_home/src/features/diagnostics/domain/diagnostic_counters.dart';
import 'package:gi_home/src/features/diagnostics/domain/error_log.dart';
import 'package:gi_home/src/features/diagnostics/domain/redaction.dart';
import 'package:meta/meta.dart';

/// Device and build facts put at the top of a report.
@immutable
final class ReportEnvironment {
  const new({
    required this.appVersion,
    required this.buildNumber,
    required this.platform,
    required this.osVersion,
    required this.locale,
    this.applianceConnected = false,
    this.applianceCleartext,
    this.coreVersion,
  });

  final String appVersion;
  final String buildNumber;
  final String platform;
  final String osVersion;
  final String locale;
  final bool applianceConnected;

  /// Whether the saved appliance is reached over plain http.
  final bool? applianceCleartext;

  /// GI Core version, when the appliance reports one.
  final String? coreVersion;
}

/// The diagnostic report the user shares from Settings (plan §8.4 point 3).
abstract final class DiagnosticReport {
  static const schemaVersion = 1;

  /// The report as JSON-ready data. Every string — including values that
  /// were redacted when recorded — is redacted again here, so a report never
  /// carries a token, cookie, e-mail, recovery code or host address.
  static Map<String, Object?> build({
    required DateTime generatedAt,
    required ReportEnvironment environment,
    required DiagnosticCounters counters,
    required List<ErrorLogEntry> errors,
    List<ErrorLogEntry> httpLog = const [],
  }) {
    final report = <String, Object?>{
      'schema': schemaVersion,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'app': {
        'version': environment.appVersion,
        'build': environment.buildNumber,
      },
      'device': {
        'platform': environment.platform,
        'osVersion': environment.osVersion,
        'locale': environment.locale,
      },
      'appliance': {
        'connected': environment.applianceConnected,
        if (environment.applianceCleartext != null)
          'cleartext': environment.applianceCleartext,
        'coreVersion': environment.coreVersion,
      },
      'counters': counters.toJson(),
      'errors': [for (final entry in errors) entry.toJson()],
      'http': [for (final entry in httpLog) entry.toJson()],
    };
    return Redactor.redactJson(report)! as Map<String, Object?>;
  }

  /// [build] encoded as indented JSON.
  static String encode(Map<String, Object?> report) =>
      const JsonEncoder.withIndent('  ').convert(report);
}
