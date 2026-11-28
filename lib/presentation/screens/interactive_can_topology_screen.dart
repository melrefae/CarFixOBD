import 'package:flutter/material.dart';
import 'lab_gate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/ecu_module_node.dart';
import '../providers/obd_state.dart';
import 'dtc_scanner_screen.dart';
import 'live_data_screen.dart';
import 'actuator_tests_screen.dart';
import 'ecu_coding_screen.dart';
import 'terminal_screen.dart';

import 'connection_screen.dart';

/// Screen displaying the interactive multi-trunk CAN topology visual graph & bus map
class InteractiveCanTopologyScreen extends StatefulWidget {
  const InteractiveCanTopologyScreen({Key? key}) : super(key: key);

  @override
  State<InteractiveCanTopologyScreen> createState() => _InteractiveCanTopologyScreenState();
}

class _InteractiveCanTopologyScreenState extends State<InteractiveCanTopologyScreen> {
  bool _isVisualMapView = true;
  CanBusType? _selectedFilter;
  late List<EcuModuleNode> _nodes;
  bool _isLocalScanning = false;

  @override
  void initState() {
    super.initState();
    _nodes = EcuModuleNode.getExtendedNetworkTopology();
    // All modules start unscanned until genuine scan is executed
    for (final node in _nodes) {
      node.status = EcuModuleStatus.notScanned;
    }
  }

  Widget _buildConnectionBanner(BuildContext context, ObdState state, bool isAr) {
    if (state.isConnected) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningOrange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.cable_outlined, color: AppColors.warningOrange, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? "فيشة الفحص غير متصلة بالمركبة" : "OBD Hardware Not Connected",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.warningOrange),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr
                      ? "قم بتوصيل فيشة الفحص بالسيارة لفحص شبكة CAN وقراءة وحدات ECU الفعلية."
                      : "Connect OBD hardware to audit multi-trunk CAN topology and query live ECUs.",
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectionScreen()),
              );
            },
            child: Text(isAr ? "اتصال" : "Connect", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _runSmartNetworkScan() async {
    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى توصيل فيشة الفحص بالمركبة قبل مسح شبكة CAN"
                : "Please connect OBD adapter before auditing CAN bus topology.",
          ),
          backgroundColor: AppColors.warningOrange,
          action: SnackBarAction(
            label: isAr ? "اتصال" : "Connect",
            textColor: Colors.black,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionScreen()));
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLocalScanning = true;
    });

    for (int i = 0; i < _nodes.length; i++) {
      if (!mounted) return;
      setState(() {
        _nodes[i].status = EcuModuleStatus.scanning;
      });

      final node = _nodes[i];
      final stopwatch = Stopwatch()..start();
      try {
        // Ping vehicle bus node using standard UDS TesterPresent (0x3E 0x00) or Mode 01
        await state.sendCommand('3E 00');
        stopwatch.stop();
        final latency = stopwatch.elapsedMilliseconds.clamp(6, 95);

        // Map live vehicle scanned DTCs to the appropriate vehicle subsystem
        final matchingDtcs = state.dtcs.where((d) {
          if (node.arbitrationId == 0x7E0) return d.code.startsWith('P'); // Powertrain
          if (node.arbitrationId == 0x7E2) return d.code.startsWith('C'); // Chassis
          if (node.arbitrationId == 0x7E4) return d.code.startsWith('B'); // Body
          if (node.arbitrationId == 0x7E8) return d.code.startsWith('U'); // Network
          return false;
        }).map((d) => d.code).toList();

        if (!mounted) return;
        setState(() {
          _nodes[i].responseLatencyMs = latency;
          if (matchingDtcs.isNotEmpty) {
            _nodes[i].status = EcuModuleStatus.faultPresent;
            _nodes[i].dtcs = matchingDtcs;
          } else {
            _nodes[i].status = EcuModuleStatus.healthy;
            _nodes[i].dtcs = [];
          }
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _nodes[i].status = EcuModuleStatus.notResponding;
          _nodes[i].dtcs = [];
          _nodes[i].responseLatencyMs = 0;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLocalScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "اكتمل فحص شبكة CAN المتعددة! تم تدقيق ${_nodes.length} وحدة إلكترونية بنجاح."
                : "CAN Gateway multi-trunk bus scan completed! ${_nodes.length} modules audited.",
          ),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  void _clearAllNetworkFaults() async {
    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى توصيل فيشة الفحص لمسح الأعطال من وحدات التحكم"
                : "Please connect OBD hardware to clear faults across vehicle modules.",
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    // Transmit genuine OBD-II Clear Diagnostic Trouble Codes Service 04
    await state.sendCommand('04');

    if (!mounted) return;
    setState(() {
      for (final n in _nodes) {
        n.dtcs.clear();
        if (n.status == EcuModuleStatus.faultPresent) {
          n.status = EcuModuleStatus.healthy;
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isAr
              ? "تم مسح أكواد الأعطال التشخيصية عبر جميع مصفوفات CAN بنجاح!"
              : "Diagnostic trouble codes cleared across all vehicle bus trunks!",
        ),
        backgroundColor: AppColors.successGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    final filteredNodes = _selectedFilter == null
        ? _nodes
        : _nodes.where((n) => n.busType == _selectedFilter).toList();

    final onlineCount = _nodes.where((n) => n.isOnline).length;
    final totalFaults = _nodes.fold<int>(0, (sum, n) => sum + n.dtcs.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "خريطة شبكة CAN المرئية التفاعلية" : "Interactive CAN Bus Topology"),
        actions: [
          IconButton(
            icon: Icon(_isVisualMapView ? Icons.view_list : Icons.account_tree),
            tooltip: _isVisualMapView ? "Switch to List View" : "Switch to Visual Bus Map",
            onPressed: () {
              setState(() {
                _isVisualMapView = !_isVisualMapView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.radar),
            tooltip: "Smart Network Bus Scan",
            onPressed: _isLocalScanning ? null : _runSmartNetworkScan,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildConnectionBanner(context, state, isAr),

          // Network Summary Hero Header
          _buildNetworkSummaryHeader(isAr, onlineCount, totalFaults),

          // Bus Trunk Filter Chips
          _buildTrunkFilterBar(isAr),

          // Main View (Visual Bus Map or List View)
          Expanded(
            child: _isVisualMapView
                ? _buildVisualBusMap(isAr, filteredNodes)
                : _buildListView(isAr, filteredNodes),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(isAr, totalFaults),
    );
  }

  Widget _buildNetworkSummaryHeader(bool isAr, int onlineCount, int totalFaults) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E262C), Color(0xFF151B20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.hub, color: AppColors.primaryYellow, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? "بوابة تشخيص شبكات CAN / LIN" : "CAN / LIN Gateway Diagnostic Bus",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "$onlineCount / ${_nodes.length} ${isAr ? "وحدة متصلة" : "Modules Online"}",
                      style: const TextStyle(color: AppColors.accentCyan, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: totalFaults > 0 ? AppColors.dangerRed.withOpacity(0.2) : AppColors.successGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: totalFaults > 0 ? AppColors.dangerRed : AppColors.successGreen),
                      ),
                      child: Text(
                        totalFaults > 0
                            ? "$totalFaults ${isAr ? "أعطال نشطة" : "Active Faults"}"
                            : (isAr ? "الشبكة سليمة" : "Bus Healthy"),
                        style: TextStyle(
                          color: totalFaults > 0 ? AppColors.dangerRed : AppColors.successGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLocalScanning)
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryYellow),
            ),
        ],
      ),
    );
  }

  Widget _buildTrunkFilterBar(bool isAr) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(isAr ? "كافة الشبكات" : "All Bus Trunks"),
            selected: _selectedFilter == null,
            selectedColor: AppColors.primaryYellow,
            labelStyle: TextStyle(
              color: _selectedFilter == null ? Colors.black : AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            onSelected: (_) => setState(() => _selectedFilter = null),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(isAr ? "PT-CAN (500k)" : "PT-CAN (500k)"),
            selected: _selectedFilter == CanBusType.ptCan500k,
            selectedColor: const Color(0xFFFF9800),
            labelStyle: TextStyle(
              color: _selectedFilter == CanBusType.ptCan500k ? Colors.black : const Color(0xFFFF9800),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            onSelected: (_) => setState(() => _selectedFilter = CanBusType.ptCan500k),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(isAr ? "Chassis (500k)" : "Chassis (500k)"),
            selected: _selectedFilter == CanBusType.chassisCan500k,
            selectedColor: const Color(0xFF00B0FF),
            labelStyle: TextStyle(
              color: _selectedFilter == CanBusType.chassisCan500k ? Colors.black : const Color(0xFF00B0FF),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            onSelected: (_) => setState(() => _selectedFilter = CanBusType.chassisCan500k),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(isAr ? "Body (125k)" : "Body (125k)"),
            selected: _selectedFilter == CanBusType.bodyCan125k,
            selectedColor: const Color(0xFF00E676),
            labelStyle: TextStyle(
              color: _selectedFilter == CanBusType.bodyCan125k ? Colors.black : const Color(0xFF00E676),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            onSelected: (_) => setState(() => _selectedFilter = CanBusType.bodyCan125k),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: Text(isAr ? "LIN (19.2k)" : "LIN Sub-Bus"),
            selected: _selectedFilter == CanBusType.lin19k,
            selectedColor: const Color(0xFFD500F9),
            labelStyle: TextStyle(
              color: _selectedFilter == CanBusType.lin19k ? Colors.white : const Color(0xFFD500F9),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
            onSelected: (_) => setState(() => _selectedFilter = CanBusType.lin19k),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualBusMap(bool isAr, List<EcuModuleNode> nodes) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Gateway Master Hub
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF263238),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryYellow, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.router, color: AppColors.primaryYellow, size: 22),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? "بوابة تشخيص السيارة المركزية (CGW)" : "Central Gateway Controller (CGW)",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                    ),
                    Text(
                      isAr ? "OBD-II DLC Port (Pin 6/14 CAN) • 500 kbps" : "OBD-II DLC Port (Pin 6/14 CAN) • 500 kbps",
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Central Bus Trunk Vertical Line
          Container(
            width: 3,
            height: 24,
            color: AppColors.primaryYellow.withOpacity(0.6),
          ),

          // Trunks Layout
          ..._buildBusTrunkSections(isAr, nodes),
        ],
      ),
    );
  }

  List<Widget> _buildBusTrunkSections(bool isAr, List<EcuModuleNode> nodes) {
    final trunks = [
      CanBusType.ptCan500k,
      CanBusType.chassisCan500k,
      CanBusType.bodyCan125k,
      CanBusType.lin19k,
    ];

    final filteredTrunks = _selectedFilter == null
        ? trunks
        : trunks.where((t) => t == _selectedFilter).toList();

    return filteredTrunks.map((trunk) {
      final trunkNodes = nodes.where((n) => n.busType == trunk).toList();
      if (trunkNodes.isEmpty) return const SizedBox.shrink();

      Color trunkColor;
      String trunkTitle;
      switch (trunk) {
        case CanBusType.ptCan500k:
          trunkColor = const Color(0xFFFF9800);
          trunkTitle = isAr ? "شبكة المحرك والجير PT-CAN (500 kbps)" : "Powertrain Bus PT-CAN (500 kbps)";
          break;
        case CanBusType.chassisCan500k:
          trunkColor = const Color(0xFF00B0FF);
          trunkTitle = isAr ? "شبكة الشاسيه والأمان Chassis CAN (500 kbps)" : "Chassis & Safety CAN (500 kbps)";
          break;
        case CanBusType.bodyCan125k:
          trunkColor = const Color(0xFF00E676);
          trunkTitle = isAr ? "شبكة البودي والراحة Body CAN (125 kbps)" : "Body & Comfort CAN (125 kbps)";
          break;
        case CanBusType.lin19k:
          trunkColor = const Color(0xFFD500F9);
          trunkTitle = isAr ? "ناقل الأجهزة الفرعية LIN (19.2 kbps)" : "Sub-System Bus LIN (19.2 kbps)";
          break;
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: trunkColor.withOpacity(0.5), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: trunkColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: trunkColor.withOpacity(0.6), blurRadius: 6, spreadRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  trunkTitle,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: trunkColor),
                ),
                const Spacer(),
                Text(
                  "${trunkNodes.length} ${isAr ? "وحدة" : "Nodes"}",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: trunkNodes.map((node) => _buildVisualNodeCard(isAr, node, trunkColor)).toList(),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildVisualNodeCard(bool isAr, EcuModuleNode node, Color trunkColor) {
    Color statusColor;
    switch (node.status) {
      case EcuModuleStatus.healthy:
        statusColor = AppColors.successGreen;
        break;
      case EcuModuleStatus.faultPresent:
        statusColor = AppColors.dangerRed;
        break;
      case EcuModuleStatus.scanning:
        statusColor = AppColors.primaryYellow;
        break;
      case EcuModuleStatus.notResponding:
      default:
        statusColor = AppColors.textDisabled;
        break;
    }

    return InkWell(
      onTap: () => _showModuleActionSheet(context, node, isAr),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 105,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF192026),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: node.isFaulted ? AppColors.dangerRed : statusColor.withOpacity(0.4),
            width: node.isFaulted ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(node.icon, color: statusColor, size: 20),
                ),
                if (node.dtcs.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.dangerRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${node.dtcs.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              node.shortName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite),
            ),
            Text(
              node.header,
              style: TextStyle(fontSize: 10, color: trunkColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              node.status == EcuModuleStatus.faultPresent
                  ? "${node.dtcs.length} DTCs"
                  : (node.status == EcuModuleStatus.healthy ? "OK" : "Offline"),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(bool isAr, List<EcuModuleNode> nodes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return Card(
          color: AppColors.cardSurface,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: node.isFaulted ? AppColors.dangerRed : AppColors.cardBorder,
            ),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: node.busColor.withOpacity(0.15),
              child: Icon(node.icon, color: node.busColor, size: 20),
            ),
            title: Text(
              "${node.shortName} (${node.header})",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textWhite, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(node.fullName, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  "${node.baudRate} • ${node.protocol} • Latency: ${node.responseLatencyMs}ms",
                  style: const TextStyle(fontSize: 10, color: AppColors.electricBlue),
                ),
              ],
            ),
            trailing: node.dtcs.isNotEmpty
                ? Chip(
                    backgroundColor: AppColors.dangerRed.withOpacity(0.2),
                    side: const BorderSide(color: AppColors.dangerRed),
                    label: Text(
                      "${node.dtcs.length} DTCs",
                      style: const TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  )
                : Icon(
                    node.isOnline ? Icons.check_circle : Icons.cancel_outlined,
                    color: node.isOnline ? AppColors.successGreen : AppColors.textDisabled,
                    size: 18,
                  ),
            onTap: () => _showModuleActionSheet(context, node, isAr),
          ),
        );
      },
    );
  }

  Widget _buildBottomActionBar(bool isAr, int totalFaults) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: _isLocalScanning
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.radar),
              label: Text(
                _isLocalScanning
                    ? (isAr ? "جارِ فحص الشبكة..." : "Scanning Network...")
                    : (isAr ? "فحص كافة وحدات الشبكة" : "Smart Gateway Bus Scan"),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              onPressed: _isLocalScanning ? null : _runSmartNetworkScan,
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            ),
            icon: const Icon(Icons.delete_sweep, size: 18),
            label: Text(
              isAr ? "مسح الأعطال" : "Clear All DTCs",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            onPressed: totalFaults == 0 ? null : _clearAllNetworkFaults,
          ),
        ],
      ),
    );
  }

  void _showModuleActionSheet(BuildContext context, EcuModuleNode node, bool isAr) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: node.busColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(node.icon, color: node.busColor, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${node.shortName} (${node.header})",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                        ),
                        Text(
                          node.fullName,
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.cardBorder),
              const SizedBox(height: 8),

              // Module Technical Specs
              Text(
                Provider.of<ObdState>(context, listen: false).isArabic ? "الناقل: ${node.busNameEn} • الباود: ${node.baudRate}" : "Bus: ${node.busNameEn} • Baud: ${node.baudRate}",
                style: const TextStyle(fontSize: 11, color: AppColors.electricBlue, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                Provider.of<ObdState>(context, listen: false).isArabic ? "رقم القطعة: ${node.softwarePartNumber} (HW: ${node.hardwarePartNumber})" : "Part Number: ${node.softwarePartNumber} (HW: ${node.hardwarePartNumber})",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const SizedBox(height: 4),
              Text(
                Provider.of<ObdState>(context, listen: false).isArabic ? "البرمجة: ${node.codingHex} • زمن الاستجابة: ${node.responseLatencyMs}ms" : "Coding: ${node.codingHex} • Latency: ${node.responseLatencyMs}ms",
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),

              if (node.dtcs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(Provider.of<ObdState>(context, listen: false).isArabic ? "أكواد الأعطال النشطة:" : "Active Trouble Codes:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.dangerRed)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: node.dtcs.map((dtc) {
                    return Chip(
                      backgroundColor: AppColors.dangerRed.withOpacity(0.2),
                      side: const BorderSide(color: AppColors.dangerRed),
                      label: Text(dtc, style: const TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.bold, fontSize: 11)),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 18),

              // Action Buttons Grid
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryYellow,
                        side: const BorderSide(color: AppColors.primaryYellow),
                      ),
                      icon: const Icon(Icons.error_outline, size: 16),
                      label: Text(Provider.of<ObdState>(context, listen: false).isArabic ? "قراءة الأعطال" : "Read DTCs", style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const DtcScannerScreen()));
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.electricBlue,
                        side: const BorderSide(color: AppColors.electricBlue),
                      ),
                      icon: const Icon(Icons.speed, size: 16),
                      label: Text(Provider.of<ObdState>(context, listen: false).isArabic ? "البيانات الحية" : "Live Stream", style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveDataScreen()));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentCyan,
                        side: const BorderSide(color: AppColors.accentCyan),
                      ),
                      icon: const Icon(Icons.play_circle_fill, size: 16),
                      label: Text(Provider.of<ObdState>(context, listen: false).isArabic ? "فحص المشغلات" : "Actuator Tests", style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        LabGate.open(context, const ActuatorTestsScreen());
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.warningOrange,
                        side: const BorderSide(color: AppColors.warningOrange),
                      ),
                      icon: const Icon(Icons.code, size: 16),
                      label: Text(Provider.of<ObdState>(context, listen: false).isArabic ? "برمجة الكنترول" : "ECU Coding", style: const TextStyle(fontSize: 12)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        LabGate.open(context, const EcuCodingScreen());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  icon: const Icon(Icons.terminal, size: 16, color: AppColors.textMuted),
                  label: Text(Provider.of<ObdState>(context, listen: false).isArabic ? "فتح طرفية ELM327 (العنوان: ATSH${node.header})" : "Open ELM327 Terminal (Header: ATSH${node.header})", style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TerminalScreen()));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
