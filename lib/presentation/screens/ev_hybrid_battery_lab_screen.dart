import 'package:flutter/material.dart';
import '../../core/utils/uds_response.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/ev_battery_models.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';

/// Screen offering high-voltage EV and hybrid battery pack diagnostics,
/// 96-cell delta voltage matrix, isolation resistance, and thermal zone monitoring
class EvHybridBatteryLabScreen extends StatefulWidget {
  const EvHybridBatteryLabScreen({Key? key}) : super(key: key);

  @override
  State<EvHybridBatteryLabScreen> createState() => _EvHybridBatteryLabScreenState();
}

class _EvHybridBatteryLabScreenState extends State<EvHybridBatteryLabScreen> {
  late EvBatteryPackSummary _pack;
  bool _isRebalancing = false;

  @override
  void initState() {
    super.initState();
    _pack = EvBatteryPackSummary.empty();
  }

  void _syncPack(ObdState state) {
    if (!state.isConnected) {
      if (_pack.cells.isNotEmpty) {
        setState(() {
          _pack = EvBatteryPackSummary.empty();
        });
      }
      return;
    }

    double? coolant;
    try {
      final s = state.sensors.firstWhere((p) => p.pid == "05");
      coolant = s.currentValue;
    } catch (_) {}

    setState(() {
      _pack = EvBatteryPackSummary.fromLiveTelemetry(
        batteryVoltage: state.batteryVoltage,
        isConnected: true,
        coolantTemp: coolant,
      );
    });
  }

  void _triggerPassiveCellBalancing() async {
    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يجب الاتصال بمحول OBD-II أولاً لبدء موازنة خلايا البطارية (BMS)!"
                : "OBD-II hardware must be connected to dispatch UDS RoutineControl BMS balancing!",
          ),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    setState(() {
      _isRebalancing = true;
    });

    // Transmit genuine ISO 14229 UDS RoutineControl (Service 0x31 01 0B 01: Start Routine BMS Cell Balancing)
    final raw = await state.sendCommand('31 01 0B 01');
    final result = UdsResult.evaluate(raw, 0x31);

    if (!mounted) return;

    // Cell data is not read from the car, so nothing is recalculated here.
    setState(() {
      _isRebalancing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.isPositive
            ? (isAr ? "الـBMS قبل الأمر. الرد: ${result.raw}. لا توجد قراءة للخلايا للتأكد من النتيجة." : "The BMS accepted the request. Reply: ${result.raw}. Cell data is not read, so the result cannot be confirmed.")
            : (isAr ? "الـBMS لم يقبل الأمر (غير مدعوم أو لا يوجد رد). الرد: ${result.raw}" : "The BMS did not accept the request (unsupported or no reply). Reply: ${result.raw}")),
        backgroundColor: result.isPositive ? AppColors.primaryYellow : AppColors.dangerRed,
      ),
    );
  }

  void _showBatteryHealthCertificate() {
    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected || _pack.cells.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يلزم الاتصال بالسيارة وفحص البطارية حياً لإنشاء شهادة فحص معتمدة!"
                : "Active OBD vehicle connection required to generate certified battery inspection report!",
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.verified, color: AppColors.successGreen, size: 24),
              SizedBox(width: 8),
              Text("EV Battery Certificate", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Pre-Purchase High-Voltage Inspection Report • VIN: ${state.currentVin}",
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const Divider(color: AppColors.cardBorder),
                const SizedBox(height: 6),
                _buildCertRow("State of Health (SOH):", "${_pack.sohPercent.toStringAsFixed(1)}% (Nominal)", AppColors.successGreen),
                _buildCertRow("State of Charge (SOC):", "${_pack.socPercent.toStringAsFixed(1)}%", AppColors.accentCyan),
                _buildCertRow("Pack Total Voltage:", "${_pack.totalVoltage} V", AppColors.textWhite),
                _buildCertRow("Cell Delta (ΔV):", "${_pack.deltaMilliVolts.toStringAsFixed(1)} mV", _pack.deltaMilliVolts > 30 ? AppColors.dangerRed : AppColors.successGreen),
                _buildCertRow("Available Capacity:", "${_pack.remainingCapacityKwh} / ${_pack.nominalCapacityKwh} kWh", AppColors.primaryYellow),
                _buildCertRow("Discharge Cycles:", "${_pack.totalDischargeCycles} Cycles", AppColors.textMuted),
                _buildCertRow("HV Isolation:", "${_pack.safetyStatus.isolationResistanceMegaOhms} MΩ (Pass)", AppColors.successGreen),
                _buildCertRow("Balance Status:", _pack.balanceRatingEn, AppColors.electricBlue),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151B20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Vehicle VIN: ${state.currentVin}\nCertified by AutoSpect Diagnostic Lab",
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Close", style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildCertRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(bool isAr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.link_off, color: AppColors.warningOrange, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr ? "محول OBD غير متصل" : "OBD-II Hardware Disconnected",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  isAr
                      ? "قم بتوصيل محول الفحص لقراءة بيانات وحدة إدارة البطارية (BMS) الحية واختبار العزل ومصفوفة الخلايا."
                      : "Connect OBD-II adapter to interrogate live Battery Management System (BMS) telemetry, HV isolation, and cell matrix.",
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warningOrange,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConnectionScreen()),
              );
            },
            child: Text(
              isAr ? "اتصال" : "Connect",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    if (state.isConnected && _pack.cells.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncPack(state);
      });
    }

    final delta = _pack.deltaMilliVolts;
    Color deltaColor = AppColors.successGreen;
    if (delta > 50.0) {
      deltaColor = AppColors.dangerRed;
    } else if (delta > 25.0) {
      deltaColor = AppColors.warningOrange;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "مختبر بطاريات الهايبرد والسيارات الكهربائية" : "EV & Hybrid High-Voltage Lab"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: isAr ? "تحديث القراءات الحية" : "Refresh Live Telemetry",
            onPressed: () => _syncPack(state),
          ),
          IconButton(
            icon: const Icon(Icons.bolt),
            tooltip: "Trigger Passive Cell Balancing",
            onPressed: _isRebalancing ? null : _triggerPassiveCellBalancing,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!state.isConnected)
              _buildConnectionBanner(isAr),

            // KPI Hero Dashboard Card
            _buildHeroKpiCard(isAr, delta, deltaColor),

            const SizedBox(height: 16),

            // Cell Delta Warning Banner (if weak cell detected)
            if (delta > 30.0 && _pack.cells.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.dangerRed),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.dangerRed, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isAr
                            ? "تنبيه: فارق الجهد مرتفع (${delta.toStringAsFixed(1)} mV)! الخلية #${_pack.lowestCellIndex} تعاني من انخفاض الجهد."
                            : "WARNING: High Cell Delta (${delta.toStringAsFixed(1)} mV)! Cell #${_pack.lowestCellIndex} exhibits abnormal voltage sag.",
                        style: const TextStyle(fontSize: 11, color: AppColors.textWhite, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

            // SECTION 1: 96-Cell Voltage Matrix Grid
            _buildSectionHeader(
              isAr ? "مصفوفة جهد الخلايا (96 خلية)" : "96-Cell Individual Voltage Matrix",
              Icons.grid_view,
              AppColors.primaryYellow,
            ),
            const SizedBox(height: 6),
            Text(
              _pack.cells.isEmpty
                  ? (isAr ? "قم بالاتصال لقراءة جهد الخلايا الفردية" : "Connect OBD adapter to scan individual cell voltages")
                  : (isAr
                      ? "أعلى خلية: #${_pack.highestCellIndex} (${_pack.maxCellVoltage}V) • أدنى خلية: #${_pack.lowestCellIndex} (${_pack.minCellVoltage}V)"
                      : "Peak Cell: #${_pack.highestCellIndex} (${_pack.maxCellVoltage}V) • Lowest Cell: #${_pack.lowestCellIndex} (${_pack.minCellVoltage}V)"),
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            _buildCellGrid(isAr),

            const SizedBox(height: 20),

            // SECTION 2: High-Voltage Safety & Contactors
            _buildSectionHeader(
              isAr ? "الأمان الكهربائي ومرحلات الجهد العالي" : "High-Voltage Safety & Contactors",
              Icons.electrical_services,
              AppColors.electricBlue,
            ),
            const SizedBox(height: 10),
            _buildSafetyStatusCard(isAr),

            const SizedBox(height: 20),

            // SECTION 3: Thermal Distribution & Cooling
            _buildSectionHeader(
              isAr ? "حساسات التوزيع الحراري ودورة التبريد" : "Thermal Zones & Coolant Loop",
              Icons.thermostat,
              AppColors.accentCyan,
            ),
            const SizedBox(height: 10),
            _buildThermalZonesCard(isAr),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _isRebalancing
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                        : const Icon(Icons.balance),
                    label: Text(
                      _isRebalancing
                          ? (isAr ? "جارِ الموازنة..." : "Balancing Pack...")
                          : (isAr ? "بدء الموازنة السلبية" : "Balance Cells"),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: _isRebalancing ? null : _triggerPassiveCellBalancing,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(Icons.verified),
                    label: Text(
                      isAr ? "شهادة الفحص المعتمدة" : "Health Certificate",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: _showBatteryHealthCertificate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroKpiCard(bool isAr, double delta, Color deltaColor) {
    return Container(
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
              _buildKpiItem(
                isAr ? "صحة البطارية (SOH)" : "State of Health (SOH)",
                "${_pack.sohPercent.toStringAsFixed(1)}%",
                AppColors.successGreen,
                "${_pack.totalDischargeCycles} Cycles",
              ),
              _buildKpiItem(
                isAr ? "مستوى الشحن (SOC)" : "State of Charge (SOC)",
                "${_pack.socPercent.toStringAsFixed(1)}%",
                AppColors.accentCyan,
                "${_pack.remainingCapacityKwh} kWh",
              ),
              _buildKpiItem(
                isAr ? "فارق الخلايا (ΔV)" : "Cell Delta (ΔV)",
                "${delta.toStringAsFixed(1)} mV",
                deltaColor,
                isAr ? _pack.balanceRatingAr : _pack.balanceRatingEn,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Pack: ${_pack.totalVoltage} V",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textWhite),
              ),
              Text(
                "Current: ${_pack.totalCurrentAmps} A",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
              ),
              Text(
                "Cells: ${_pack.cells.length}s",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.electricBlue),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String title, String value, Color color, String subtitle) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textDisabled)),
      ],
    );
  }

  Widget _buildCellGrid(bool isAr) {
    if (_pack.cells.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF151B20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_off, size: 36, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              isAr ? "لا توجد خلايا مقروءة حالياً" : "No Live Battery Cells Detected",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
            const SizedBox(height: 4),
            Text(
              isAr ? "قم بالاتصال بمحول OBD لقراءة مصفوفة الخلايا" : "Connect OBD adapter to scan live high-voltage cell voltages",
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 260,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151B20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
          childAspectRatio: 1.05,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _pack.cells.length,
        itemBuilder: (context, index) {
          final cell = _pack.cells[index];
          Color cellBgColor = const Color(0xFF1E262C);
          Color borderColor = AppColors.cardBorder;

          if (cell.isHighest) {
            cellBgColor = const Color(0xFF004D40);
            borderColor = AppColors.successGreen;
          } else if (cell.isLowest) {
            cellBgColor = _pack.deltaMilliVolts > 30 ? const Color(0xFF4A148C) : const Color(0xFF263238);
            borderColor = _pack.deltaMilliVolts > 30 ? AppColors.dangerRed : AppColors.warningOrange;
          }

          return InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Cell #${cell.cellNumber}: ${cell.voltage}V (Δ: ${cell.deltaFromAvgMv > 0 ? "+" : ""}${cell.deltaFromAvgMv} mV from avg)"),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: cellBgColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: borderColor, width: (cell.isHighest || cell.isLowest) ? 1.5 : 0.8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "#${cell.cellNumber}",
                    style: const TextStyle(fontSize: 8, color: AppColors.textDisabled),
                  ),
                  Text(
                    cell.voltage.toStringAsFixed(3),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: cell.isLowest && _pack.deltaMilliVolts > 30 ? AppColors.dangerRed : (cell.isHighest ? AppColors.successGreen : AppColors.textWhite),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSafetyStatusCard(bool isAr) {
    final safety = _pack.safetyStatus;

    return Card(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? "مقاومة العزل الكهربائي (HV Isolation):" : "HV Isolation Resistance:",
                  style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                ),
                Text(
                  "${safety.isolationResistanceMegaOhms} MΩ (Threshold ≥ ${safety.isolationThresholdMegaOhms} MΩ)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: safety.isIsolationSafe ? AppColors.successGreen : AppColors.dangerRed,
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.cardBorder),
            _buildSafetyRow(isAr ? "حلقة أمان الجهد العالي (HVIL):" : "High-Voltage Interlock Loop (HVIL):", safety.hvilLoopClosed ? "CLOSED (Safe)" : "OPEN (Tripped)", safety.hvilLoopClosed),
            _buildSafetyRow(isAr ? "مرحل الشحن التمهيدي (Pre-Charge):" : "Pre-Charge Relay Contactor:", safety.preChargeRelayEngaged ? "ENGAGED" : "OPEN", safety.preChargeRelayEngaged),
            _buildSafetyRow(isAr ? "كونتاكتور القطب الموجب (+B):" : "Main Positive Contactor (+B):", safety.mainPositiveContactorEngaged ? "ENGAGED" : "OPEN", safety.mainPositiveContactorEngaged),
            _buildSafetyRow(isAr ? "كونتاكتور القطب السالب (-B):" : "Main Negative Contactor (-B):", safety.mainNegativeContactorEngaged ? "ENGAGED" : "OPEN", safety.mainNegativeContactorEngaged),
            _buildSafetyRow(isAr ? "فيوز الفصل البيروتقني (Pyro-Fuse):" : "Pyrotechnic Safety Battery Disconnect:", safety.pyroFuseArmed ? "ARMED & READY" : "FIRED/OPEN", safety.pyroFuseArmed),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyRow(String label, String value, bool isOk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Row(
            children: [
              Icon(isOk ? Icons.check_circle : Icons.error, size: 14, color: isOk ? AppColors.successGreen : AppColors.dangerRed),
              const SizedBox(width: 4),
              Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOk ? AppColors.successGreen : AppColors.dangerRed)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThermalZonesCard(bool isAr) {
    if (_pack.thermalZones.isEmpty) {
      return Card(
        color: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              isAr ? "حساسات الحرارة غير متصلة • اربط محول OBD" : "Thermal sensors offline • Connect OBD adapter",
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ),
      );
    }

    return Card(
      color: AppColors.cardSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: _pack.thermalZones.map((zone) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151B20),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        Text(zone.zoneId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentCyan)),
                        const SizedBox(height: 4),
                        Text(
                          "${zone.tempCelsius.toStringAsFixed(1)}°C",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          zone.locationNameEn.split(' ').first,
                          style: const TextStyle(fontSize: 9, color: AppColors.textDisabled),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.cardBorder),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Coolant Pump: ${_pack.safetyStatus.coolantPumpLpm} L/min",
                  style: const TextStyle(fontSize: 11, color: AppColors.electricBlue, fontWeight: FontWeight.w600),
                ),
                Text(
                  "Chiller Valve: ${_pack.safetyStatus.chillerValveOpen ? "OPEN (Active)" : "CLOSED"}",
                  style: const TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
