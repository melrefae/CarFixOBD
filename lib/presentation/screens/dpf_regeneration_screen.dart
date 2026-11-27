import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/utils/uds_response.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../core/localization/app_strings_ar.dart';
import '../../data/models/dpf_aftertreatment_models.dart';
import '../../core/utils/hex_parser.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';

/// Screen for DPF / GPF Soot/Ash Mass, Forced Regeneration Wizard, and SCR AdBlue Diagnostics
class DpfRegenerationScreen extends StatefulWidget {
  const DpfRegenerationScreen({Key? key}) : super(key: key);

  @override
  State<DpfRegenerationScreen> createState() => _DpfRegenerationScreenState();
}

class _DpfRegenerationScreenState extends State<DpfRegenerationScreen> {
  late ExhaustAftertreatmentBundle _bundle;

  // Regeneration wizard state
  bool _isRegenRunning = false;
  int _currentPhaseIndex = 0; // 0..3
  double _phaseProgress = 0.0;
  Timer? _regenTimer;

  // Safety checklist states
  bool _chkTempSafe = true;
  bool _chkFuelAdequate = true;
  bool _chkHoodClosed = true;
  bool _chkHandbrakePark = true;

  @override
  void initState() {
    super.initState();
    // Neutral placeholder: soot mass / ash / SCR values are NOT available over standard OBD and are not shown.
    _bundle = ExhaustAftertreatmentBundle.fromLiveTelemetry(coolantTempC: 25.0, rpm: 0.0);
  }

  @override
  void dispose() {
    _regenTimer?.cancel();
    super.dispose();
  }

  Future<void> _startForcedRegeneration() async {
    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى توصيل فيشة الفحص (OBD) بالسيارة قبل بدء دورة التجديد"
                : "Please connect OBD adapter to vehicle before starting forced regeneration.",
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

    if (state.currentCoolantTemp < 70.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "حرارة سائل التبريد (${state.currentCoolantTemp.toStringAsFixed(0)}°C) منخفضة. يجب أن تكون ≥ 70°C لبدء التجديد."
                : "Coolant temperature (${state.currentCoolantTemp.toStringAsFixed(0)}°C) is below 70°C. Warm engine up first.",
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    if (state.currentRpm < 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "المحرك متوقف. يرجى تشغيل المحرك وتركه يعمل على السلانسيه لبدء الحرق."
                : "Engine is stopped. Please start engine and idle before running regeneration.",
          ),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    // Transmit genuine UDS StartRoutine 0x0203 (DPF Service Stationary Regeneration)
    final startRaw = await state.sendCommand('31 01 02 03');
    final startResult = UdsResult.evaluate(startRaw, 0x31);
    if (!startResult.isPositive) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr
              ? "الكمبيوتر لم يقبل أمر التجديد (غير مدعوم أو لا يوجد رد). لم يبدأ أي إجراء. الرد: ${startResult.raw}"
              : "The ECU did not accept the regeneration request (unsupported or no reply). Nothing was started. Reply: ${startResult.raw}"),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      return;
    }

    final phases = ForcedRegenerationPhase.getStandardPhases();
    setState(() {
      _isRegenRunning = true;
      _currentPhaseIndex = 0;
      _phaseProgress = 0.0;
    });

    _regenTimer?.cancel();
    _regenTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _phaseProgress += 0.05;
        if (_phaseProgress >= 1.0) {
          _phaseProgress = 0.0;
          _currentPhaseIndex++;
          if (_currentPhaseIndex >= phases.length) {
            timer.cancel();
            _isRegenRunning = false;
            // No values are invented here: the result must be checked with live DPF data from the ECU.
            _showCompletionDialog();
          }
        }
      });
    });
  }

  Future<void> _abortForcedRegeneration() async {
    _regenTimer?.cancel();
    final state = Provider.of<ObdState>(context, listen: false);
    if (state.isConnected) {
      // Transmit genuine UDS StopRoutine 0x0203 (DPF Service Regeneration Abort)
      await state.sendCommand('31 02 02 03');
    }

    setState(() {
      _isRegenRunning = false;
      _phaseProgress = 0.0;
      _currentPhaseIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Emergency Abort: Forced regeneration canceled safely."),
        backgroundColor: AppColors.dangerRed,
      ),
    );
  }

  void _showCompletionDialog() {
    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: AppColors.successGreen, size: 28),
            SizedBox(width: 8),
            Text(
              "Regeneration request completed",
              style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: Text(
          isAr
              ? "انتهى المؤقت بعد أن قبل الكمبيوتر أمر التجديد. هذا لا يؤكد نجاح الحرق. تحقق من بيانات الفلتر الحية (الضغط التفاضلي وحمل الهباب) قبل الاعتماد على النتيجة."
              : "The timer finished after the ECU accepted the regeneration request. This does not confirm the burn succeeded. Check live DPF data (differential pressure, soot load) before relying on the result.",
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow),
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBanner(BuildContext context, ObdState state, bool isAr) {
    if (state.isConnected) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
                      ? "قم بتوصيل فيشة الفحص بالسيارة لقراءة ضغط الفلتر DPF وتنفيذ دورة الحرق."
                      : "Connect OBD hardware to read live DPF pressure and execute regeneration.",
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

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    final phases = ForcedRegenerationPhase.getStandardPhases();

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? AppStringsAr.dpfRegeneration : AppStrings.dpfRegeneration),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConnectionBanner(context, state, isAr),

            _MeasuredAftertreatmentCard(isAr: isAr),

            const SizedBox(height: 16),

            // Stationary Forced Regeneration Wizard
            _buildForcedRegenWizard(isAr, phases, const DpfSootAshStatus(sootMassGrams: 0, maxSootRegenLimitGrams: 45, oilAshMassGrams: 0, differentialPressureMbar: 0, isRegenerationRequired: false, isRegenBlocked: false, dpfHealthStatusEn: '', dpfHealthStatusAr: '')),

          ],
        ),
      ),
    );
  }

  Widget _buildOverviewHeader(bool isAr, DpfSootAshStatus dpf) {
    final isAlert = dpf.isRegenBlocked || dpf.isRegenerationRequired;
    final badgeColor = dpf.isRegenBlocked
        ? AppColors.dangerRed
        : (dpf.isRegenerationRequired ? AppColors.warningOrange : AppColors.successGreen);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAlert ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                  color: badgeColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? "نظام معالجة انبعاثات الديزل والبنزين" : "Exhaust Aftertreatment & Particulate Filter",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAr ? dpf.dpfHealthStatusAr : dpf.dpfHealthStatusEn,
                      style: TextStyle(fontSize: 12, color: badgeColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDpfSootSection(bool isAr, DpfSootAshStatus dpf) {
    final sootRatio = (dpf.sootMassGrams / dpf.maxSootRegenLimitGrams).clamp(0.0, 1.0);
    final sootColor = sootRatio > 0.8
        ? AppColors.dangerRed
        : (sootRatio > 0.5 ? AppColors.warningOrange : AppColors.successGreen);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.filter_list_alt, color: AppColors.primaryYellow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "DPF Soot & Ash Saturation",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: sootColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${(sootRatio * 100).toStringAsFixed(0)}% LOAD",
                  style: TextStyle(color: sootColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: sootRatio,
              minHeight: 12,
              backgroundColor: const Color(0xFF151B20),
              valueColor: AlwaysStoppedAnimation<Color>(sootColor),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  isAr ? "كتلة الهباب الحالية" : "Calculated Soot Mass",
                  "${dpf.sootMassGrams.toStringAsFixed(1)} g",
                  "Limit: ${dpf.maxSootRegenLimitGrams}g",
                  sootColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  isAr ? "كتلة رماد الزيت" : "Oil Ash Accumulation",
                  "${dpf.oilAshMassGrams.toStringAsFixed(1)} g",
                  "Non-combustible",
                  AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  isAr ? "فارق الضغط" : "Differential Pressure",
                  "${dpf.differentialPressureMbar.toStringAsFixed(1)} mbar",
                  dpf.differentialPressureMbar > 25.0 ? "HIGH" : "NORMAL",
                  dpf.differentialPressureMbar > 25.0 ? AppColors.warningOrange : AppColors.accentCyan,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEgtBankSection(bool isAr, EgtSensorBank egt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.thermostat, color: AppColors.accentCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Exhaust Gas Temperature (EGT) Bank",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: egt.isTempSafeForRegen ? AppColors.successGreen.withOpacity(0.2) : AppColors.dangerRed.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  egt.isTempSafeForRegen ? "TEMP SAFE" : "OUT OF RANGE",
                  style: TextStyle(
                    color: egt.isTempSafeForRegen ? AppColors.successGreen : AppColors.dangerRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEgtCard("Sensor 1", "Pre-Turbo", "${egt.sensor1PreTurboC.toStringAsFixed(0)}°C", Icons.speed),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEgtCard("Sensor 2", "Pre-DPF", "${egt.sensor2PreDpfC.toStringAsFixed(0)}°C", Icons.local_fire_department),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildEgtCard("Sensor 3", "Post-DPF / SCR", "${egt.sensor3PostDpfC.toStringAsFixed(0)}°C", Icons.air),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEgtCard(String label, String position, String temp, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151B20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.accentCyan, size: 16),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(position, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          Text(temp, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
        ],
      ),
    );
  }

  Widget _buildForcedRegenWizard(bool isAr, List<ForcedRegenerationPhase> phases, DpfSootAshStatus dpf) {
    final allChecksPassed = _chkTempSafe && _chkFuelAdequate && _chkHoodClosed && _chkHandbrakePark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isRegenRunning ? AppColors.warningOrange : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.autorenew, color: AppColors.warningOrange, size: 20),
              SizedBox(width: 8),
              Text(
                "Stationary Forced Regeneration Wizard",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isAr
                ? "تفعيل دورة الحرق الساكنة بالورشة لإزالة رواسب الكربون والهباب تحت إشراف كمبيوتر السيارة ECM."
                : "Workshop stationary active regeneration to burn accumulated carbon and soot under ECM supervision.",
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),

          // Interlocks checklist (collapsible or displayed when idle)
          if (!_isRegenRunning) ...[
            const Text(
              "Pre-Regeneration Safety Interlocks:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite),
            ),
            const SizedBox(height: 6),
            _buildCheckItem(isAr ? "حرارة سائل التبريد > 70° مئوية" : "Coolant Temp > 70°C", _chkTempSafe, (v) => setState(() => _chkTempSafe = v!)),
            _buildCheckItem(isAr ? "مستوى الوقود > 25% بالخزان" : "Fuel Level > 25% (No Stalling Risk)", _chkFuelAdequate, (v) => setState(() => _chkFuelAdequate = v!)),
            _buildCheckItem(isAr ? "غطاء المحرك مغلق وخلو العادم" : "Hood Closed & Exhaust Clearance Verified", _chkHoodClosed, (v) => setState(() => _chkHoodClosed = v!)),
            _buildCheckItem(isAr ? "ناقل الحركة على P وفرامل اليد مشدودة" : "Gear in Park/Neutral & Handbrake Engaged", _chkHandbrakePark, (v) => setState(() => _chkHandbrakePark = v!)),
            const SizedBox(height: 14),
          ],

          // Phase Stepper
          if (_isRegenRunning) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF151B20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warningOrange.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "PHASE ${_currentPhaseIndex + 1} OF ${phases.length}",
                        style: const TextStyle(color: AppColors.warningOrange, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Text(
                        "${(_phaseProgress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr ? phases[_currentPhaseIndex].phaseNameAr : phases[_currentPhaseIndex].phaseNameEn,
                    style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text("Target: ${phases[_currentPhaseIndex].targetRpm} RPM", style: const TextStyle(fontSize: 11, color: AppColors.accentCyan)),
                      const SizedBox(width: 12),
                      Text("Target Temp: ${phases[_currentPhaseIndex].targetDpfTempC}°C", style: const TextStyle(fontSize: 11, color: AppColors.warningOrange)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _phaseProgress,
                      minHeight: 8,
                      backgroundColor: Colors.black26,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warningOrange),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Action Buttons
          Row(
            children: [
              if (!_isRegenRunning)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (allChecksPassed && !dpf.isRegenBlocked) ? AppColors.warningOrange : AppColors.cardBorder,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: (allChecksPassed && !dpf.isRegenBlocked) ? _startForcedRegeneration : null,
                    icon: const Icon(Icons.play_arrow, color: Colors.black),
                    label: Text(
                      isAr ? "بدء دورة التجديد الإجباري" : "Initiate Forced Regen",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _abortForcedRegeneration,
                    icon: const Icon(Icons.stop, color: Colors.white),
                    label: Text(
                      isAr ? "إيقاف طارئ لدورة التجديد" : "Emergency Abort Regen",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String title, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.successGreen,
                checkColor: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
          ],
        ),
      ),
    );
  }

  Widget _buildScrAdBlueSection(bool isAr, ScrAdBlueStatus scr) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.opacity, color: AppColors.accentCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "SCR AdBlue / DEF Injection Diagnostics",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "${scr.noxConversionEfficiencyPercent}% NOx REDUCTION",
                  style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  isAr ? "مستوى خزان الأدبلو" : "AdBlue DEF Level",
                  "${scr.tankLevelPercent.toStringAsFixed(1)}%",
                  "Target: > 20%",
                  AppColors.accentCyan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  isAr ? "ضغط مضخة الجرعات" : "Dosing Pump Pressure",
                  "${scr.pumpPressureBar.toStringAsFixed(1)} Bar",
                  "Normal: 5.8-6.5 Bar",
                  AppColors.primaryYellow,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  isAr ? "تركيز اليوريا" : "DEF Concentration",
                  "${scr.defQualityConcentrationPercent.toStringAsFixed(1)}%",
                  "AUS 32 Spec (32.5%)",
                  AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF151B20),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Upstream NOx (Engine Raw)", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text("${scr.noxUpstreamPpm.toStringAsFixed(0)} ppm", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.warningOrange)),
                  ],
                ),
                const Icon(Icons.arrow_forward, color: AppColors.textMuted, size: 18),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Downstream NOx (Post-SCR)", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text("${scr.noxDownstreamPpm.toStringAsFixed(0)} ppm", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF151B20),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Reads ONLY standard SAE J1979 Mode 01 PIDs for the aftertreatment system.
/// Soot mass, ash mass, AdBlue level and NOx conversion are not standard readable values,
/// so they are not shown. Anything the ECU does not answer is shown as "not supported".
class _MeasuredAftertreatmentCard extends StatefulWidget {
  final bool isAr;
  const _MeasuredAftertreatmentCard({required this.isAr});
  @override
  State<_MeasuredAftertreatmentCard> createState() => _MeasuredAftertreatmentCardState();
}

class _MeasuredAftertreatmentCardState extends State<_MeasuredAftertreatmentCard> {
  final Map<String, String> _rows = {};
  bool _busy = false;
  bool _done = false;

  Future<String?> _query(ObdState st, String pid, String Function(List<int>) fmt) async {
    final raw = await st.sendCommand('01$pid');
    final bytes = HexParser.extractBytes(raw);
    final p = HexParser.extractPayload(bytes, 0x01, int.parse(pid, radix: 16));
    if (p.isEmpty) return null;
    try {
      return fmt(p);
    } catch (_) {
      return null;
    }
  }

  double _temp(List<int> p, int i) => ((p[i] << 8 | p[i + 1]) / 10.0) - 40.0;

  Future<void> _read() async {
    final st = Provider.of<ObdState>(context, listen: false);
    setState(() { _busy = true; _rows.clear(); });
    // PID 78: EGT bank 1 (A = supported-sensor bits, then 2 bytes per sensor)
    final egt = await _query(st, '78', (p) {
      final out = <String>[];
      for (int n = 0; n < 4; n++) {
        if ((p[0] >> n) & 1 == 1) {
          out.add('S${n + 1}: ${_temp(p, 1 + n * 2).toStringAsFixed(1)} C');
        }
      }
      return out.join('  ');
    });
    // PID 7C: DPF inlet / outlet temperature
    final dpfT = await _query(st, '7C', (p) =>
        'in ${_temp(p, 1).toStringAsFixed(1)} C / out ${_temp(p, 3).toStringAsFixed(1)} C');
    // PID 7A: DPF delta pressure (bytes A-B, signed, 0.01 kPa)
    final dp = await _query(st, '7A', (p) {
      int v = (p[0] << 8) | p[1];
      if (v > 32767) v -= 65536;
      return '${(v * 0.01).toStringAsFixed(2)} kPa';
    });
    final nr = widget.isAr ? 'غير مدعوم أو لا رد' : 'not supported / no reply';
    if (!mounted) return;
    setState(() {
      _rows['EGT bank 1 (01 78)'] = egt ?? nr;
      _rows['DPF temp (01 7C)'] = dpfT ?? nr;
      _rows['DPF differential pressure (01 7A)'] = dp ?? nr;
      _busy = false;
      _done = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final st = Provider.of<ObdState>(context);
    final isAr = widget.isAr;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAr ? 'قراءات حقيقية من السيارة (PID قياسي)' : 'Measured from the car (standard PIDs)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text(
              isAr
                  ? 'كتلة الهباب والرماد ومستوى الأدبلو وكفاءة NOx غير متاحة عبر OBD القياسي ولذلك لا تُعرض.'
                  : 'Soot mass, ash mass, AdBlue level and NOx conversion are not readable over standard OBD, so they are not shown.',
              style: const TextStyle(fontSize: 11),
            ),
            const SizedBox(height: 10),
            for (final e in _rows.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 12)),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: (!st.isConnected || _busy) ? null : _read,
              icon: const Icon(Icons.sensors),
              label: Text(_busy ? '...' : (_done ? (isAr ? 'قراءة مرة أخرى' : 'Read again') : (isAr ? 'قراءة الآن' : 'Read now'))),
            ),
          ],
        ),
      ),
    );
  }
}
