import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../data/models/ecu_module_node.dart';
import '../../data/models/sensor_pid.dart';
import '../providers/obd_state.dart';
import 'interactive_can_topology_screen.dart';

/// Screen displaying the vehicle multi-ECU network gateway topology
class MultiEcuTopologyScreen extends StatelessWidget {
  const MultiEcuTopologyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = Provider.of<ObdState>(context);
    final nodes = state.ecuTopology;

    final onlineCount = nodes.where((n) => n.isOnline).length;
    final totalFaults = nodes.fold<int>(0, (sum, n) => sum + n.dtcs.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.topoTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.topoRescan,
            onPressed: state.isScanningTopology || !state.isConnected
                ? null
                : () => state.scanAllEcuModules(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Smart Scan Hero Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263238), Color(0xFF1E262C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.topoBusTitle,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.topoModulesOnline(onlineCount, nodes.length, totalFaults),
                            style: TextStyle(
                              fontSize: 12,
                              color: totalFaults > 0 ? AppColors.dangerRed : AppColors.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.hub, color: AppColors.primaryYellow, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: Colors.black,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: state.isScanningTopology
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.radar),
                          label: Text(
                            state.isScanningTopology ? l10n.topoScanningBus : l10n.topoSmartScan,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          onPressed: state.isScanningTopology || !state.isConnected
                              ? null
                              : () => state.scanAllEcuModules(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dangerRed,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        ),
                        icon: const Icon(Icons.delete_sweep, size: 18),
                        label: Text(l10n.topoClearAll, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: state.isScanningTopology || !state.isConnected || totalFaults == 0
                            ? null
                            : () async {
                                final ok = await state.clearAllEcuDtcs();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(ok ? l10n.topoClearedOk : l10n.topoClearedFail),
                                      backgroundColor: ok ? AppColors.successGreen : AppColors.dangerRed,
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentCyan,
                        side: const BorderSide(color: AppColors.accentCyan, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.account_tree, size: 16),
                      label: Text(
                        l10n.topoOpenGraph,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const InteractiveCanTopologyScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n.topoSubsystems,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
            ),
            const SizedBox(height: 10),

            // Modules Topology Cards
            ...nodes.map((node) => _buildModuleCard(node, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(EcuModuleNode node, AppLocalizations l10n) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (node.status) {
      case EcuModuleStatus.scanning:
        statusColor = AppColors.primaryYellow;
        statusLabel = l10n.topoScanning;
        statusIcon = Icons.hourglass_top;
        break;
      case EcuModuleStatus.healthy:
        statusColor = AppColors.successGreen;
        statusLabel = l10n.topoHealthy;
        statusIcon = Icons.check_circle;
        break;
      case EcuModuleStatus.faultPresent:
        statusColor = AppColors.dangerRed;
        statusLabel = l10n.topoFaults(node.dtcs.length);
        statusIcon = Icons.warning;
        break;
      case EcuModuleStatus.notResponding:
        statusColor = AppColors.textDisabled;
        statusLabel = l10n.topoOffline;
        statusIcon = Icons.cancel_outlined;
        break;
      case EcuModuleStatus.notScanned:
      default:
        statusColor = AppColors.textMuted;
        statusLabel = l10n.topoPending;
        statusIcon = Icons.radio_button_unchecked;
        break;
    }

    return Card(
      color: AppColors.cardSurface,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: node.isFaulted ? AppColors.dangerRed : AppColors.cardBorder),
      ),
      child: ExpansionTile(
        initiallyExpanded: node.isFaulted,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(node.icon, color: statusColor, size: 22),
        ),
        title: Text(
          "${node.shortName} (${node.header})",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
        ),
        subtitle: Text(
          node.fullName,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, color: statusColor, size: 14),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppColors.cardBorder),
                Text(node.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(l10n.topoProtocol(node.protocol), style: const TextStyle(fontSize: 11, color: AppColors.electricBlue)),
                    const Spacer(),
                    if (node.responseLatencyMs > 0)
                      Text(l10n.topoLatency(node.responseLatencyMs), style: const TextStyle(fontSize: 11, color: AppColors.textDisabled)),
                  ],
                ),
                if (node.status == EcuModuleStatus.healthy || node.status == EcuModuleStatus.faultPresent) ...[
                  const SizedBox(height: 8),
                  if (node.supportedPids.isNotEmpty) ...[
                    Text(
                      l10n.topoSupportedPids(node.supportedPids.length),
                      style: const TextStyle(fontSize: 11, color: AppColors.accentCyan, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _buildPidChips(node, l10n.localeName == 'ar'),
                    ),
                  ] else
                    Text(l10n.topoNoMode01, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
                if (node.dtcs.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(l10n.topoStoredCodes, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.dangerRed)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: node.dtcs.map((dtc) {
                      return Chip(
                        backgroundColor: AppColors.dangerRed.withOpacity(0.2),
                        side: const BorderSide(color: AppColors.dangerRed),
                        label: Text(dtc, style: const TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, fontSize: 11)),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Map<String, SensorPid>? _pidCatalog;

  List<Widget> _buildPidChips(EcuModuleNode node, bool isAr) {
    _pidCatalog ??= {
      for (final p in SensorPid.getStandardPids())
        if (p.mode == "01") p.pid.toUpperCase(): p,
    };
    final sorted = node.supportedPids.toList()..sort();
    return sorted.map((pid) {
      final meta = _pidCatalog![pid];
      // LRM keeps the hex PID in left-to-right order inside Arabic text (0C, not C0).
      final label = meta == null ? "\u200E$pid" : "\u200E$pid ${isAr ? meta.nameAr : meta.name}";
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.accentCyan.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      );
    }).toList();
  }
}
