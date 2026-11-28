import 'package:flutter/material.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/utils/traffic_log.dart';
import '../../core/constants/feature_status.dart';

/// Shows the raw request/response log of every command sent to the adapter.
/// Export it after a real-car test: it is the evidence a feature needs to be marked verified.
class TrafficLogScreen extends StatefulWidget {
  const TrafficLogScreen({Key? key}) : super(key: key);
  @override
  State<TrafficLogScreen> createState() => _TrafficLogScreenState();
}

class _TrafficLogScreenState extends State<TrafficLogScreen> {
  @override
  Widget build(BuildContext context) {
    final entries = TrafficLog.instance.entries.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).rawLogTitle('${entries.length}')),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: AppLocalizations.of(context).exportTooltip,
            onPressed: entries.isEmpty ? null : () => Share.share(TrafficLog.instance.export(), subject: 'CarFixOBD raw log'),
          ),
          IconButton(
            icon: const Icon(Icons.fact_check_outlined),
            tooltip: AppLocalizations.of(context).exportEvidenceTooltip,
            onPressed: () {
              final reg = kFeatureRegistry.map((f) => '${f.id}: ${f.status.name} ${f.evidence}').join('\n');
              Share.share('FEATURE STATUS\n$reg\n\nRAW LOG\n${TrafficLog.instance.export()}', subject: 'CarFixOBD test evidence');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppLocalizations.of(context).clearTooltip,
            onPressed: () => setState(TrafficLog.instance.clear),
          ),
        ],
      ),
      body: entries.isEmpty
          ? Center(child: Text(AppLocalizations.of(context).noCommandsYet))
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final e = entries[i];
                return ListTile(
                  dense: true,
                  title: Text('> ${e.request}', style: const TextStyle(fontFamily: 'monospace')),
                  subtitle: Text('< ${e.response.replaceAll(RegExp(r"[\r\n]+"), " ")}\n${e.time.toIso8601String()}',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
                );
              },
            ),
    );
  }
}
