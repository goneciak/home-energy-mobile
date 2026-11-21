import 'dart:io';
import 'dart:ui' show Rect;

import 'package:gi_home/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostics_service.dart';
import 'package:gi_home/src/features/diagnostics/domain/diagnostic_report.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'diagnostic_report_sharer.g.dart';

/// "Wyślij raport diagnostyczny": writes the redacted JSON report to a
/// temporary file and hands it to the system share sheet (plan §8.4).
final class DiagnosticReportSharer {
  new({
    required this._diagnostics,
    required this._environment,
    required this._directory,
    required this._launch,
  });

  static const folderName = 'gi-home-diagnostics';

  /// share_plus on Android copies every shared file into
  /// `<cacheDir>/share_plus` (the temporary directory there) and keeps it
  /// until the next share.
  static const sharePlusFolderName = 'share_plus';

  /// Deletes every report waiting in [directory], and share_plus's copy of
  /// it, so the previous user's diagnostics do not survive a logout or a
  /// change of appliance (plan §8.3). Never throws.
  static Future<void> deleteReports(
    Future<Directory> Function() directory,
  ) async {
    try {
      final base = await directory();
      for (final name in [folderName, sharePlusFolderName]) {
        final folder = Directory('${base.path}${Platform.pathSeparator}$name');
        // Synchronous: only a few small files.
        if (folder.existsSync()) folder.deleteSync(recursive: true);
      }
    } on Object {
      // A file left behind is overwritten by the next report.
    }
  }

  final DiagnosticsService _diagnostics;
  final ReportEnvironment _environment;
  final Future<Directory> Function() _directory;
  final ShareLauncher _launch;

  /// Writes the report and returns its file. Older reports are removed
  /// first, so at most one copy waits in the temporary directory.
  Future<File> writeReport() async {
    final base = await _directory();
    final folder = Directory(
      '${base.path}${Platform.pathSeparator}$folderName',
    );
    if (folder.existsSync()) await folder.delete(recursive: true);
    await folder.create(recursive: true);
    await _diagnostics.flush();
    final report = _diagnostics.buildReport(_environment);
    final stamp = '${report['generatedAt']}'
        .replaceAll(RegExp('[^0-9T]'), '')
        .substring(0, 13);
    final file = File(
      '${folder.path}${Platform.pathSeparator}gi-home-diagnostics-$stamp.json',
    );
    await file.writeAsString(DiagnosticReport.encode(report), flush: true);
    return file;
  }

  /// Writes the report and opens the share sheet. [origin] anchors the
  /// sheet on iPad. Throws when the file cannot be written.
  Future<void> share({required String subject, Rect? origin}) async {
    final file = await writeReport();
    await _launch(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: subject,
        sharePositionOrigin: origin,
      ),
    );
  }
}

@riverpod
DiagnosticReportSharer diagnosticReportSharer(Ref ref) =>
    DiagnosticReportSharer(
      diagnostics: ref.watch(diagnosticsServiceProvider),
      environment: ref.watch(reportEnvironmentProvider),
      directory: ref.watch(reportDirectoryProvider),
      launch: ref.watch(shareLauncherProvider),
    );
