import 'package:flutter/material.dart';
import '../../core/utils/uds_response.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/immo_key_models.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';

/// Screen offering anti-theft immobilizer diagnostics, RFID transponder reading,
/// RF remote frequency testing, PIN code calculator, and guided key learning
class ImmoKeyProgrammingScreen extends StatefulWidget {
  const ImmoKeyProgrammingScreen({Key? key}) : super(key: key);

  @override
  State<ImmoKeyProgrammingScreen> createState() => _ImmoKeyProgrammingScreenState();
}

class _ImmoKeyProgrammingScreenState extends State<ImmoKeyProgrammingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: Transponder state
  final List<TransponderChipInfo> _presetChips = TransponderChipInfo.getPresetTransponders();
  int _selectedChipIndex = 0;
  bool _isReadingTransponder = false;

  // Tab 2: Frequency tester state
  double _rssiStrength = -95.0;
  String _activeFrequency = "433.92 MHz";
  String _activeModulation = "FSK";
  bool _isRfSniffing = true;
  String _lastRfPacket = "Awaiting key fob transmission...";

  // Tab 3: PIN code calculator state
  int _selectedSystemIndex = 0;

  // Tab 4: Guided key learning wizard state
  final List<KeyLearningStep> _learningSteps = KeyLearningStep.getDefaultLearningSteps();
  int _currentStepIndex = 0;
  bool _isStepExecuting = false;

  // Tab 5: Live status
  ImmoKeyStatus _immoStatus = const ImmoKeyStatus.disconnected();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                      ? "قم بتوصيل فيشة الفحص بالسيارة لتنفيذ أوامر UDS ومصافحة مفتاح الأمان المشفر."
                      : "Connect OBD hardware to execute UDS routines and security access handshakes.",
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

  void _scanTransponder() async {
    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى توصيل فيشة الفحص بالمركبة قبل قراءة شريحة الترانسبوندر"
                : "Please connect OBD adapter before scanning transponder chip.",
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
      _isReadingTransponder = true;
    });

    // Query transponder RFID reader via UDS Service 31 RoutineControl
    final raw = await state.sendCommand('31 01 0F 10');
    final result = UdsResult.evaluate(raw, 0x31);

    if (!mounted) return;
    setState(() {
      _isReadingTransponder = false;
    });
    // No chip is invented: the reply is shown as received. Decoding of chip data is not implemented.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.isPositive
            ? "ECU accepted the request. Reply: ${result.raw}. Chip data is not decoded yet."
            : "No valid transponder reply (unsupported or no response). Reply: ${result.raw}"),
        backgroundColor: result.isPositive ? AppColors.primaryYellow : AppColors.dangerRed,
      ),
    );
  }

  void _setRfReceiverFrequency(String freq) {
    setState(() {
      _activeFrequency = freq;
      _lastRfPacket = "Listening on $freq...";
      _rssiStrength = -95.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Provider.of<ObdState>(context, listen: false).isArabic ? "غير متاح: قياس تردد الريموت يحتاج جهاز استقبال راديو خارجي - فيشة ELM327 لا تستقبل راديو." : "Unavailable: measuring remote frequency needs an external RF receiver - an ELM327 adapter cannot receive radio."),
        duration: const Duration(milliseconds: 1500),
        backgroundColor: AppColors.electricBlue,
      ),
    );
  }

  void _executeNextLearningStep() async {
    if (_currentStepIndex >= _learningSteps.length) return;

    final state = Provider.of<ObdState>(context, listen: false);
    final isAr = state.isArabic;

    if (!state.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? "يرجى توصيل فيشة الفحص بالمركبة قبل تنفيذ خطوة برمجة المفتاح"
                : "Please connect OBD adapter before executing key learning routine.",
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
      _isStepExecuting = true;
    });

    // Transmit genuine UDS key learning command for current guided step
    final step = _learningSteps[_currentStepIndex];
    final raw = await state.sendCommand(step.commandHex);
    final stepResult = UdsResult.evaluate(raw, int.tryParse(step.commandHex.replaceAll(' ', '').substring(0, 2), radix: 16) ?? 0x31);

    if (!mounted) return;

    setState(() {
      _isStepExecuting = false;
      // A step is completed only if the ECU gave a positive response.
      if (stepResult.isPositive) {
        _learningSteps[_currentStepIndex].isCompleted = true;
        if (_currentStepIndex < _learningSteps.length - 1) {
          _currentStepIndex++;
        }
      }
    });
    if (!stepResult.isPositive) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Provider.of<ObdState>(context, listen: false).isArabic ? "الكونترول لم يقبل الخطوة. الرد: ${stepResult.raw}" : "Step not accepted by the ECU. Reply: ${stepResult.raw}"),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    if (state.isConnected && !_immoStatus.isConnected) {
      _immoStatus = ImmoKeyStatus.fromLiveTelemetry(
        isConnected: true,
      );
    } else if (!state.isConnected && _immoStatus.isConnected) {
      _immoStatus = const ImmoKeyStatus.disconnected();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "برمجة المفاتيح ونظام الإيموبليزر IMMO" : "IMMO & Key Programming Suite"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(icon: const Icon(Icons.nfc, size: 18), text: isAr ? "قراءة الشريحة" : "RFID Transponder"),
            Tab(icon: const Icon(Icons.settings_remote, size: 18), text: isAr ? "تردد الريموت" : "RF Frequency"),
            Tab(icon: const Icon(Icons.calculate, size: 18), text: isAr ? "حساب PIN" : "PIN Calculator"),
            Tab(icon: const Icon(Icons.key, size: 18), text: isAr ? "معالج التعلم" : "Key Learning"),
            Tab(icon: const Icon(Icons.security, size: 18), text: isAr ? "حالة الأمان" : "Anti-Theft Status"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTransponderTab(state, isAr),
          _buildRfFrequencyTab(isAr),
          _buildPinCalculatorTab(isAr),
          _buildKeyLearningTab(state, isAr),
          _buildAntiTheftStatusTab(state, isAr),
        ],
      ),
    );
  }

  // --- TAB 1: RFID Transponder ---
  Widget _buildTransponderTab(ObdState state, bool isAr) {
    final chip = _presetChips[_selectedChipIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConnectionBanner(context, state, isAr),

          // Hero Key Coil Card
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
                          isAr ? "قارئ شرائح الترانسبوندر (RFID)" : "RFID Transponder Coil Reader",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? "هوائي 125 kHz / 134.2 kHz لنظام الإيموبليزر" : "125 kHz / 134.2 kHz Antenna Loop Detection",
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.nfc, color: AppColors.primaryYellow, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  icon: _isReadingTransponder
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.sensors),
                  label: Text(
                    _isReadingTransponder
                        ? (isAr ? "جارِ التحميل..." : "Loading...")
                        : (isAr ? "استعراض مرجع الشرائح" : "Browse Transponder Reference"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _isReadingTransponder ? null : _scanTransponder,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transponder reference card: technical reference data, NOT read from a key
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warningOrange),
            ),
            child: Text(
              isAr
                  ? "قراءة شريحة المفتاح الفعلية غير ممكنة عبر فيشة ELM327 (لا يوجد ملف هوائي 125kHz). البيانات التالية مرجع فني للشرائح الشائعة وليست قراءة من مفتاح حقيقي."
                  : "Reading an actual key transponder is not possible via an ELM327 adapter (no 125kHz coil). The data below is a technical reference of common chip types, not read from a real key.",
              style: const TextStyle(fontSize: 12, color: AppColors.warningOrange, fontWeight: FontWeight.w600),
            ),
          ),
          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accentCyan),
                        ),
                        child: Text(
                          chip.chipType,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentCyan, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          chip.chipFamily,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                        ),
                      ),
                      Chip(
                        backgroundColor: chip.isLocked ? AppColors.dangerRed.withOpacity(0.2) : AppColors.successGreen.withOpacity(0.2),
                        side: BorderSide(color: chip.isLocked ? AppColors.dangerRed : AppColors.successGreen),
                        label: Text(
                          chip.isLocked ? (isAr ? "مغلقة" : "LOCKED") : (isAr ? "مفتوحة" : "UNLOCKED"),
                          style: TextStyle(
                            color: chip.isLocked ? AppColors.dangerRed : AppColors.successGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildDetailRow(Provider.of<ObdState>(context, listen: false).isArabic ? "التشفير:" : "Crypto / Encryption:", chip.encryptionType, AppColors.textWhite),
                  _buildDetailRow(Provider.of<ObdState>(context, listen: false).isArabic ? "تردد الريموت:" : "RF Remote Frequency:", chip.frequency, AppColors.electricBlue),
                  _buildDetailRow(Provider.of<ObdState>(context, listen: false).isArabic ? "حالة الشريحة:" : "Chip Condition:", chip.isVirgin ? (Provider.of<ObdState>(context, listen: false).isArabic ? "فاضية / غير مبرمجة" : "Virgin / Unprogrammed") : (Provider.of<ObdState>(context, listen: false).isArabic ? "متعلمة على السيارة" : "Learned to Vehicle"), AppColors.textMuted),

const SizedBox(height: 14),
                  Text(Provider.of<ObdState>(context, listen: false).isArabic ? "المنصات الشائعة المدعومة:" : "Supported Common Platforms:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: chip.compatibleVehicles.map((v) {
                      return Chip(
                        backgroundColor: const Color(0xFF263238),
                        label: Text(v, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: RF Remote Frequency Tester ---
  Widget _buildRfFrequencyTab(bool isAr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warningOrange),
            ),
            child: Text(
              isAr
                  ? "قياس تردد الريموت الفعلي يحتاج جهاز استقبال راديو (433/315/868MHz) - فيشة ELM327 لا تستقبل راديو. القائمة بالأسفل مرجع للترددات القياسية فقط."
                  : "Measuring an actual remote frequency needs an RF receiver (433/315/868MHz) - an ELM327 adapter cannot receive radio. The list below is a standard-frequency reference only.",
              style: const TextStyle(fontSize: 12, color: AppColors.warningOrange, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warningOrange),
            ),
            child: Text(
              isAr
                  ? "قياس تردد الريموت الفعلي يحتاج جهاز استقبال راديو (433/315/868MHz) - فيشة ELM327 لا تستقبل راديو. القائمة بالأسفل مرجع للترددات القياسية فقط."
                  : "Measuring an actual remote frequency needs an RF receiver (433/315/868MHz) - an ELM327 adapter cannot receive radio. The list below is a standard-frequency reference only.",
              style: const TextStyle(fontSize: 12, color: AppColors.warningOrange, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.warningOrange),
            ),
            child: Text(
              isAr
                  ? "قياس تردد الريموت الفعلي يحتاج جهاز استقبال راديو (433/315/868MHz) - فيشة ELM327 لا تستقبل راديو. القائمة بالأسفل مرجع للترددات القياسية فقط."
                  : "Measuring an actual remote frequency needs an RF receiver (433/315/868MHz) - an ELM327 adapter cannot receive radio. The list below is a standard-frequency reference only.",
              style: const TextStyle(fontSize: 12, color: AppColors.warningOrange, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "مقياس تردد الريموت وقوة الإشارة" : "Remote RF Spectrum Sniffer",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                    ),
                    Icon(
                      _isRfSniffing ? Icons.wifi_tethering : Icons.wifi_tethering_off,
                      color: _isRfSniffing ? AppColors.successGreen : AppColors.textDisabled,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151B20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _activeFrequency,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryYellow,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Provider.of<ObdState>(context, listen: false).isArabic ? "التضمين: $_activeModulation • الإشارة: ${_rssiStrength.toStringAsFixed(1)} dBm" : "Modulation: $_activeModulation • Signal: ${_rssiStrength.toStringAsFixed(1)} dBm",
                        style: const TextStyle(fontSize: 12, color: AppColors.accentCyan),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: ((_rssiStrength + 90) / 70).clamp(0.0, 1.0),
                        color: AppColors.successGreen,
                        backgroundColor: Colors.white10,
                        minHeight: 8,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        Provider.of<ObdState>(context, listen: false).isArabic ? "آخر إشارة راديو: $_lastRfPacket" : "Last RF Frame: $_lastRfPacket",
                        style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Text(
            Provider.of<ObdState>(context, listen: false).isArabic ? "اختر نطاق مراقبة مستقبل الريموت:" : "Select RF Receiver Monitoring Band:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeFrequency.contains("433") ? AppColors.primaryYellow : const Color(0xFF263238),
                    foregroundColor: _activeFrequency.contains("433") ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.settings_input_antenna, size: 18),
                  label: const Text("433.92 MHz\n(EU / Asia / ME)", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                  onPressed: () => _setRfReceiverFrequency("433.92 MHz"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeFrequency.contains("315") ? AppColors.successGreen : const Color(0xFF263238),
                    foregroundColor: _activeFrequency.contains("315") ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.settings_input_antenna, size: 18),
                  label: const Text("315.00 MHz\n(US / Japan Spec)", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                  onPressed: () => _setRfReceiverFrequency("315.00 MHz"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _activeFrequency.contains("868") ? AppColors.electricBlue : const Color(0xFF263238),
                    foregroundColor: _activeFrequency.contains("868") ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.settings_input_antenna, size: 18),
                  label: const Text("868.35 MHz\n(Smart Key Pro)", textAlign: TextAlign.center, style: TextStyle(fontSize: 11)),
                  onPressed: () => _setRfReceiverFrequency("868.35 MHz"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Provider.of<ObdState>(context, listen: false).isArabic ? "الترددات القياسية في مصر والعالم:" : "Egypt & Global Standard Frequencies:", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite)),
                  const SizedBox(height: 6),
                  _buildFreqInfoRow("433.92 MHz", Provider.of<ObdState>(context, listen: false).isArabic ? "المعتمد الأوروبي والمصري والشرق أوسطي" : "Official European, Egyptian & Middle East Standard"),
                  _buildFreqInfoRow("315.00 MHz", Provider.of<ObdState>(context, listen: false).isArabic ? "سيارات السوق الأمريكي المستوردة (فورد، GM، تويوتا أمريكا)" : "US Market Import Vehicles (Ford, GM, US Toyota)"),
                  _buildFreqInfoRow("868.35 MHz", Provider.of<ObdState>(context, listen: false).isArabic ? "مفاتيح ذكية عالية الأمان (BMW، VAG بدون مفتاح)" : "High-Security Smart Key Fobs (BMW, VAG Keyless)"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: PIN Code Calculator (REMOVED - honest notice) ---
  Widget _buildPinCalculatorTab(bool isAr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dangerRed),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.gpp_bad, color: AppColors.dangerRed, size: 26),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAr ? "حاسبة الـ PIN أزيلت" : "PIN calculator removed",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.dangerRed),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              isAr
                  ? "الخوارزميات الرسمية لحساب كود الحماية من رقم الشاسيه ملكية وغير موثقة. النسخة السابقة كانت تعرض أرقامًا غير حقيقية، وإدخال كود خطأ في السيارة قد يقفل الإيموبيلايزر. لن نخمّن كود حماية أبدًا. استخدم أداة وكالة موثقة لهذه العملية."
                  : "Official VIN-to-PIN algorithms are proprietary and undocumented. The previous version showed invented numbers, and entering a wrong PIN can lock the immobilizer. We will never guess a security PIN. Use a trusted dealer tool for this job.",
              style: const TextStyle(fontSize: 13, color: AppColors.textWhite, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 4: Key Learning Wizard ---
  Widget _buildKeyLearningTab(ObdState state, bool isAr) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConnectionBanner(context, state, isAr),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAr ? "معالج برمجة المفاتيح الموجه" : "Guided Key Learning Wizard",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                    ),
                    Text(
                      Provider.of<ObdState>(context, listen: false).isArabic ? "الخطوة ${_currentStepIndex + 1} من ${_learningSteps.length}" : "Step ${_currentStepIndex + 1} of ${_learningSteps.length}",
                      style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (_currentStepIndex + 1) / _learningSteps.length,
                  color: AppColors.primaryYellow,
                  backgroundColor: Colors.white12,
                  minHeight: 6,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stepper List
          ..._learningSteps.asMap().entries.map((entry) {
            final idx = entry.key;
            final step = entry.value;
            final isCurrent = idx == _currentStepIndex;
            final isDone = step.isCompleted;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFF263238) : AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDone
                      ? AppColors.successGreen
                      : (isCurrent ? AppColors.primaryYellow : AppColors.cardBorder),
                  width: isCurrent ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isDone
                        ? AppColors.successGreen
                        : (isCurrent ? AppColors.primaryYellow : Colors.white12),
                    child: isDone
                        ? const Icon(Icons.check, size: 16, color: Colors.black)
                        : Text(
                            "${step.stepNumber}",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCurrent ? Colors.black : Colors.white60,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? step.titleAr : step.titleEn,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isCurrent ? AppColors.primaryYellow : AppColors.textWhite,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAr ? step.instructionAr : step.instructionEn,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          Provider.of<ObdState>(context, listen: false).isArabic ? "أمر UDS: ${step.commandHex}" : "UDS Command: ${step.commandHex}",
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.electricBlue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          const SizedBox(height: 14),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: _isStepExecuting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.play_arrow),
            label: Text(
              _isStepExecuting
                  ? (isAr ? "جارِ تنفيذ الخطوة..." : "Executing Step...")
                  : (_learningSteps.every((s) => s.isCompleted)
                      ? (isAr ? "اكتملت برمجة المفتاح بنجاح!" : "All Steps Completed Successfully!")
                      : (isAr ? "تنفيذ الخطوة التالية" : "Execute Next Step (${_learningSteps[_currentStepIndex].durationSeconds}s)")),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: _isStepExecuting || _learningSteps.every((s) => s.isCompleted) ? null : _executeNextLearningStep,
          ),
        ],
      ),
    );
  }

  // --- TAB 5: Anti-Theft Status ---
  Widget _buildAntiTheftStatusTab(ObdState state, bool isAr) {
    final isConn = state.isConnected;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConnectionBanner(context, state, isAr),

          Container(
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
                    color: isConn
                        ? AppColors.successGreen.withOpacity(0.15)
                        : AppColors.warningOrange.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isConn ? Icons.verified_user : Icons.link_off,
                    color: isConn ? AppColors.successGreen : AppColors.warningOrange,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? "حالة نظام الحماية والإيموبليزر" : "Immobilizer & Security Status",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isConn
                            ? (isAr ? "المفتاح مصرح به • المحرك جاهز للتشغيل" : "Key Authorized • Engine Start Permitted")
                            : (isAr ? "فيشة الفحص غير متصلة • يلزم الاتصال لقراءة الحالة" : "Hardware Disconnected • Connect OBD adapter to read status"),
                        style: TextStyle(
                          fontSize: 12,
                          color: isConn ? AppColors.successGreen : AppColors.warningOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            color: AppColors.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusRow(
                    isAr ? "عدد المفاتيح المبرمجة:" : "Programmed Keys Count:",
                    isConn ? "${_immoStatus.programmedKeysCount} / ${_immoStatus.maxKeysAllowed} Allowed" : "-- (Offline)",
                    isConn ? AppColors.primaryYellow : AppColors.textDisabled,
                  ),
                  const Divider(color: AppColors.cardBorder),
                  _buildStatusRow(
                    isAr ? "حالة الإيموبليزر:" : "Immobilizer Fuel Cut:",
                    isConn ? (_immoStatus.isImmobilizerActive ? "ACTIVE (Fuel Cut)" : "INACTIVE (Pass)") : "-- (Offline)",
                    isConn ? (_immoStatus.isImmobilizerActive ? AppColors.dangerRed : AppColors.successGreen) : AppColors.textDisabled,
                  ),
                  const Divider(color: AppColors.cardBorder),
                  _buildStatusRow(
                    isAr ? "تصريح تشغيل المحرك:" : "Engine Start Authorization:",
                    isConn ? (_immoStatus.isKeyAuthorized ? "AUTHORIZED" : "REJECTED") : "-- (Offline)",
                    isConn ? (_immoStatus.isKeyAuthorized ? AppColors.successGreen : AppColors.dangerRed) : AppColors.textDisabled,
                  ),
                  const Divider(color: AppColors.cardBorder),
                  _buildStatusRow(
                    isAr ? "مقاومة ملف الهوائي:" : "Key Antenna Coil Resistance:",
                    isConn ? "${_immoStatus.coilResistanceOhms} Ω (Nominal)" : "-- Ω (Offline)",
                    isConn ? AppColors.accentCyan : AppColors.textDisabled,
                  ),
                  const Divider(color: AppColors.cardBorder),
                  _buildStatusRow(
                    isAr ? "قفل عمود الدريكسيون (ESL):" : "Steering Column Lock (ESL):",
                    isConn ? (_immoStatus.eslUnlocked ? "UNLOCKED (Normal)" : "LOCKED") : "-- (Offline)",
                    isConn ? (_immoStatus.eslUnlocked ? AppColors.successGreen : AppColors.warningOrange) : AppColors.textDisabled,
                  ),
                  const Divider(color: AppColors.cardBorder),
                  _buildStatusRow(
                    isAr ? "شريحة المفتاح الحالية:" : "Transponder in Slot:",
                    isConn ? (_immoStatus.transponderDetected ? "DETECTED (ID46)" : "NO CHIP") : "-- (Offline)",
                    isConn ? (_immoStatus.transponderDetected ? AppColors.successGreen : AppColors.textDisabled) : AppColors.textDisabled,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textWhite)),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildFreqInfoRow(String freq, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$freq: ", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryYellow)),
          Expanded(child: Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))),
        ],
      ),
    );
  }
}
