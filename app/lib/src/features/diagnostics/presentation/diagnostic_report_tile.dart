import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gi_home/src/core/l10n/l10n.dart';
import 'package:gi_home/src/core/widgets/localized_snack_bar.dart';
import 'package:gi_home/src/features/diagnostics/application/diagnostic_report_sharer.dart';
import 'package:material_ui/material_ui.dart';

/// "Wyślij raport diagnostyczny" in Settings: explains what the report
/// contains, then opens the share sheet with the redacted JSON file
/// (plan §8.4 point 3).
class DiagnosticReportTile extends ConsumerWidget {
  const new({super.key});

  static const Key tileKey = ValueKey('settings-diagnostic-report');
  static const Key shareKey = ValueKey('diagnostic-report-share');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    Future<void> share() async {
      final confirmed = await _confirm(context);
      if (!confirmed || !context.mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null && box.hasSize
          ? box.localToGlobal(Offset.zero) & box.size
          : null;
      try {
        await ref
            .read(diagnosticReportSharerProvider)
            .share(subject: l10n.diagnosticReportSubject, origin: origin);
      } on Object {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          localizedSnackBar((l10n) => l10n.diagnosticReportFailed),
        );
      }
    }

    return ListTile(
      key: tileKey,
      leading: const Icon(Icons.bug_report_outlined),
      title: Text(l10n.settingsDiagnosticReport),
      subtitle: Text(l10n.settingsDiagnosticReportSubtitle),
      onTap: share,
    );
  }

  static Future<bool> _confirm(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.diagnosticReportTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.diagnosticReportIntro),
              const SizedBox(height: 12),
              Text(l10n.diagnosticReportContains),
              const SizedBox(height: 12),
              Text(l10n.diagnosticReportExcludes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton.icon(
            key: shareKey,
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.ios_share),
            label: Text(l10n.diagnosticReportShare),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}
