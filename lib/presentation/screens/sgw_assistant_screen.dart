import 'package:flutter/material.dart';
import '../../core/utils/uds_response.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/sgw_vehicle_guide.dart';
import '../providers/obd_state.dart';

/// Security Gateway (SGW) Bypass Assistant & Cable Pinout Visualizer Screen
class SgwAssistantScreen extends StatefulWidget {
  const SgwAssistantScreen({Key? key}) : super(key: key);

  @override
  State<SgwAssistantScreen> createState() => _SgwAssistantScreenState();
}

class _SgwAssistantScreenState extends State<SgwAssistantScreen> {
  late SgwVehicleGuide _selectedGuide;
  bool _isTestingSgw = false;
  String? _testResult;
  bool _sgwDetected = true;

  @override
  void initState() {
    super.initState();
    _selectedGuide = SgwVehicleGuide.catalog.first;
  }

  Future<void> _runSgwCheck(ObdState state) async {
    setState(() {
      _isTestingSgw = true;
      _testResult = null;
    });

    try {
      if (!state.isConnected) {
        setState(() {
          _isTestingSgw = false;
          _testResult = "Hardware Disconnected: Connect OBD-II adapter to vehicle to test Security Gateway (SGW) status.";
        });
        return;
      }

      // Live OBD test: query Extended Diagnostic Session (10 03) or Security Access (27 01)
      final resp = await state.sendCommand("27 01");
      final r = UdsResult.evaluate(resp, 0x27);
      setState(() {
        _isTestingSgw = false;
        if (r.isPositive) {
          _sgwDetected = false;
          _testResult = "The ECU answered the security access request positively (Raw: ${r.raw}). This does not prove there is no gateway.";
        } else if (r.outcome == UdsOutcome.negative) {
          _sgwDetected = true;
          _testResult = "The ECU rejected the request (negative code ${r.nrc}, Raw: ${r.raw}). A gateway may be present; the code alone does not prove it.";
        } else {
          _sgwDetected = false;
          _testResult = "No valid reply (Raw: ${r.raw}). Cannot determine gateway status.";
        }
      });
    } catch (e) {
      setState(() {
        _isTestingSgw = false;
        _testResult = "Diagnostic check error: $e. Cannot determine gateway status.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "مساعد تخطي حماية البوابة (SGW)" : "SGW Bypass Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Test SGW Status",
            onPressed: () => _runSgwCheck(state),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Guide Selector Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF263238)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<SgwVehicleGuide>(
                  isExpanded: true,
                  value: _selectedGuide,
                  dropdownColor: AppColors.darkBackground,
                  items: SgwVehicleGuide.catalog.map((guide) {
                    return DropdownMenuItem<SgwVehicleGuide>(
                      value: guide,
                      child: Text(
                        isAr ? guide.vehicleNameAr : guide.vehicleName,
                        style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedGuide = val;
                        _testResult = null;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Live SGW Status & Diagnostic Card
            Card(
              color: AppColors.cardSurfaceHighlight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _sgwDetected ? AppColors.warningAmber : AppColors.successGreen,
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _sgwDetected ? Icons.lock : Icons.lock_open,
                              color: _sgwDetected ? AppColors.warningAmber : AppColors.successGreen,
                              size: 26,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAr
                                  ? (_sgwDetected ? "البوابة مغلقة (SGW Locked)" : "الحماية مفكوكة (Unlocked)")
                                  : (_sgwDetected ? "SGW Active (Protection Locked)" : "SGW Unlocked / Bypassed"),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: _sgwDetected ? AppColors.warningAmber : AppColors.successGreen,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                          ),
                          onPressed: _isTestingSgw ? null : () => _runSgwCheck(state),
                          icon: _isTestingSgw
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : const Icon(Icons.bolt, size: 16),
                          label: Text(
                            isAr ? "فحص البوابة" : "Test SGW",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (_testResult != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _testResult!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Module Location & Recommended Harness
            Card(
              color: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF263238)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.accentCyan, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? "موقع وحدة الحماية في السيارة" : "Module Physical Location",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr ? _selectedGuide.locationAr : _selectedGuide.location,
                      style: const TextStyle(fontSize: 13, color: AppColors.accentCyan),
                    ),
                    const Divider(color: Color(0xFF263238), height: 20),
                    Row(
                      children: [
                        const Icon(Icons.cable, color: AppColors.primaryYellow, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? "كابل التخطي المطلوب" : "Required Bypass Cable",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAr ? _selectedGuide.harnessCableAr : _selectedGuide.harnessCable,
                      style: const TextStyle(fontSize: 13, color: AppColors.primaryYellow),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Provider.of<ObdState>(context, listen: false).isArabic ? "النوع: ${_selectedGuide.sgwType} • السنوات: ${_selectedGuide.years}" : "Type: ${_selectedGuide.sgwType} • Years: ${_selectedGuide.years}",
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Symptoms Checklist
            Card(
              color: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF263238)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? "أعراض وجود حماية البوابة (لماذا نحتاج التخطي؟)" : "SGW Symptoms (Why Bypass is Needed)",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      isAr ? _selectedGuide.symptomsAr.length : _selectedGuide.symptoms.length,
                      (i) {
                        final text = isAr ? _selectedGuide.symptomsAr[i] : _selectedGuide.symptoms[i];
                        final isBlock = text.contains("BLOCKED") || text.contains("REJECTED") || text.contains("مرفوض") || text.contains("محظورة");
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                isBlock ? Icons.cancel : Icons.check_circle,
                                size: 16,
                                color: isBlock ? AppColors.crimsonRed : AppColors.successGreen,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Interactive Pinout Visualizer
            Card(
              color: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF263238)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.settings_input_component, color: AppColors.electricBlue, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? "مخطط أطراف الفيشة (Pinout Visualizer)" : "Connector Pinout Visualizer",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedGuide.pinouts.map((pin) {
                        Color wireColorVal = AppColors.primaryYellow;
                        if (pin.wireColor.toLowerCase().contains("blue")) {
                          wireColorVal = Colors.blue;
                        } else if (pin.wireColor.toLowerCase().contains("red")) {
                          wireColorVal = Colors.red;
                        } else if (pin.wireColor.toLowerCase().contains("green")) {
                          wireColorVal = Colors.green;
                        } else if (pin.wireColor.toLowerCase().contains("white")) {
                          wireColorVal = Colors.white70;
                        } else if (pin.wireColor.toLowerCase().contains("black")) {
                          wireColorVal = Colors.grey;
                        }

                        return Container(
                          width: (MediaQuery.of(context).size.width - 56) / 2,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF37474F)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: wireColorVal,
                                    child: Text(
                                      "${pin.pinNumber}",
                                      style: const TextStyle(fontSize: 10, color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      pin.signalName,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: wireColorVal),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${pin.connectorName} • ${pin.wireColor}",
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pin.description,
                                style: const TextStyle(fontSize: 10, color: AppColors.textWhite),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Step-by-Step Bypass Procedure
            Card(
              color: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF263238)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.format_list_numbered, color: AppColors.successGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isAr ? "خطوات الفك والتركيب في الورشة" : "Workshop Step-by-Step Procedure",
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textWhite),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(
                      isAr ? _selectedGuide.procedureStepsAr.length : _selectedGuide.procedureSteps.length,
                      (idx) {
                        final stepText = isAr ? _selectedGuide.procedureStepsAr[idx] : _selectedGuide.procedureSteps[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            stepText,
                            style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.4),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
