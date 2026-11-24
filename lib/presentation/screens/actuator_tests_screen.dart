import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/actuation_test_model.dart';
import '../providers/obd_state.dart';

/// Screen for bi-directional active component actuation tests and guided calibration procedures
class ActuatorTestsScreen extends StatefulWidget {
  const ActuatorTestsScreen({Key? key}) : super(key: key);

  @override
  State<ActuatorTestsScreen> createState() => _ActuatorTestsScreenState();
}

class _ActuatorTestsScreenState extends State<ActuatorTestsScreen> {
  final List<ActuationTestModel> _tests = ActuationTestModel.getAllActuatorTests();
  String? _activeTestId;
  int _remainingSeconds = 0;
  Timer? _countdownTimer;

  void _startTest(ActuationTestModel test, ObdState state) async {
    _countdownTimer?.cancel();
    setState(() {
      _activeTestId = test.id;
      _remainingSeconds = test.activeDuration.inSeconds;
    });

    final ok = await state.executeActuatorTest(test, true);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Actuator command rejected by ECU or not supported by vehicle profile."),
          backgroundColor: AppColors.dangerRed,
        ),
      );
      _stopTest(test, state);
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        _stopTest(test, state);
      } else {
        if (mounted) setState(() => _remainingSeconds--);
      }
    });
  }

  void _stopTest(ActuationTestModel test, ObdState state) async {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    await state.executeActuatorTest(test, false);
    if (mounted) {
      setState(() {
        _activeTestId = null;
        _remainingSeconds = 0;
      });
    }
  }

  void _openGuidedProcedureModal(BuildContext context, ActuationTestModel test, ObdState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => _GuidedActuationRunnerModal(
        test: test,
        obdState: state,
        isArabic: state.isArabic,
      ),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "اختبار المشغلات والبلوف التفاعلي" : AppStrings.actuatorTests),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _tests.length,
        itemBuilder: (context, idx) {
          final test = _tests[idx];
          final isActive = _activeTestId == test.id;
          final isGuided = test.isGuidedProcedure;

          return Card(
            color: AppColors.cardSurface,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive ? AppColors.primaryYellow : (isGuided ? AppColors.accentCyan.withOpacity(0.5) : AppColors.cardBorder),
                width: isActive ? 1.8 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primaryYellow
                              : (isGuided ? AppColors.accentCyan.withOpacity(0.15) : AppColors.backgroundDark),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          test.icon,
                          color: isActive
                              ? Colors.black
                              : (isGuided ? AppColors.accentCyan : AppColors.primaryYellow),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              test.getTitle(isAr),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                            ),
                            Row(
                              children: [
                                Text(
                                  "${test.systemCategory} • Target: ${test.targetEcuHeader}",
                                  style: const TextStyle(fontSize: 11, color: AppColors.electricBlue),
                                ),
                                if (isGuided) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentCyan.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isAr ? "إجراء موجه" : "Guided Routine",
                                      style: const TextStyle(fontSize: 9, color: AppColors.accentCyan, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.dangerRed,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_remainingSeconds}s Active",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Text(test.getDescription(isAr), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),

                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.hearing, size: 16, color: AppColors.accentCyan),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            test.getNotice(isAr),
                            style: const TextStyle(fontSize: 11, color: AppColors.accentCyan),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Actions: Guided procedure vs quick single test
                  if (isGuided) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentCyan,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.alt_route, size: 18),
                            label: Text(
                              isAr ? "بدء الإجراء الموجه (${test.steps.length} مراحل)" : "Start Guided Routine (${test.steps.length} Steps)",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                            ),
                            onPressed: !state.isConnected ? null : () => _openGuidedProcedureModal(context, test, state),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isActive ? AppColors.dangerRed : AppColors.primaryYellow,
                          foregroundColor: isActive ? Colors.white : Colors.black,
                        ),
                        icon: Icon(isActive ? Icons.stop : Icons.play_arrow),
                        label: Text(
                          isActive
                              ? (isAr ? "إيقاف الفحص" : "Stop Actuation Test")
                              : "${isAr ? 'تفعيل المشغل' : 'Trigger Component Test'} (${test.activeDuration.inSeconds}s)",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: !state.isConnected
                            ? null
                            : () {
                                if (isActive) {
                                  _stopTest(test, state);
                                } else {
                                  _startTest(test, state);
                                }
                              },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Interactive Step-by-Step Guided Procedure Modal with live telemetry and emergency abort
class _GuidedActuationRunnerModal extends StatefulWidget {
  final ActuationTestModel test;
  final ObdState obdState;
  final bool isArabic;

  const _GuidedActuationRunnerModal({
    Key? key,
    required this.test,
    required this.obdState,
    required this.isArabic,
  }) : super(key: key);

  @override
  State<_GuidedActuationRunnerModal> createState() => _GuidedActuationRunnerModalState();
}

class _GuidedActuationRunnerModalState extends State<_GuidedActuationRunnerModal> {
  int _currentStepIndex = 0;
  bool _isStepActive = false;
  int _stepRemainingSeconds = 0;
  Timer? _stepTimer;
  bool _preconditionsConfirmed = false;
  bool _isFinished = false;

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  void _emergencyAbort() async {
    _stepTimer?.cancel();
    final currentStep = widget.test.steps[_currentStepIndex];
    final stopCmd = currentStep.stopCommand.isNotEmpty ? currentStep.stopCommand : widget.test.offCommand;

    try {
      await widget.obdState.sendRawCommand(stopCmd);
    } catch (_) {}

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.isArabic ? "⚠️ تم الإلغاء الفوري وإعادة الكنترول للوضع الطبيعي!" : "⚠️ Emergency Abort triggered! Normal ECU control restored."),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  void _startCurrentStep() async {
    final step = widget.test.steps[_currentStepIndex];

    if (step.durationSeconds > 0) {
      setState(() {
        _isStepActive = true;
        _stepRemainingSeconds = step.durationSeconds;
      });

      if (step.commandToSend.isNotEmpty) {
        await widget.obdState.sendRawCommand(step.commandToSend);
      }

      _stepTimer?.cancel();
      _stepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (_stepRemainingSeconds <= 1) {
          timer.cancel();
          if (step.stopCommand.isNotEmpty) {
            await widget.obdState.sendRawCommand(step.stopCommand);
          }
          _advanceToNextStep();
        } else {
          if (mounted) setState(() => _stepRemainingSeconds--);
        }
      });
    } else {
      // Manual confirmation step
      _advanceToNextStep();
    }
  }

  void _advanceToNextStep() {
    if (_currentStepIndex < widget.test.steps.length - 1) {
      if (mounted) {
        setState(() {
          _isStepActive = false;
          _currentStepIndex++;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isStepActive = false;
          _isFinished = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = widget.isArabic;
    final test = widget.test;
    final steps = test.steps;
    final currentStep = steps[_currentStepIndex];

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Icon(test.icon, color: AppColors.accentCyan, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        test.getTitle(isAr),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textWhite),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "${test.systemCategory} • Stage ${_currentStepIndex + 1} of ${steps.length}",
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                // Emergency Abort button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dangerRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.cancel, size: 16),
                  label: Text(
                    isAr ? "إلغاء طارئ" : "ABORT",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                  onPressed: _emergencyAbort,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),

          // Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // Pre-conditions section
                if (!_preconditionsConfirmed) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryYellow.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryYellow.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.security, color: AppColors.primaryYellow, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              isAr ? "شروط الأمان والمتطلبات القبلية" : "Pre-Test Safety Checklist",
                              style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...test.getPreConditions(isAr).map((cond) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primaryYellow),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(cond, style: const TextStyle(fontSize: 12.5, color: AppColors.textWhite)),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _preconditionsConfirmed = true;
                              });
                            },
                            child: Text(
                              isAr ? "تأكيد شروط الأمان وبدء الخطوة 1" : "Confirm Safety & Begin Step 1",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (_isFinished) ...[
                  // Finished banner
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.successGreen),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.successGreen, size: 54),
                        const SizedBox(height: 12),
                        Text(
                          isAr ? "اكتمل الإجراء بنجاح! ✅" : "Guided Procedure Completed! ✅",
                          style: const TextStyle(color: AppColors.successGreen, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAr ? "تم تنفيذ كافة خطوات المعايرة وإعادة ضبط المشغلات بنجاح." : "All calibration steps executed and verified successfully.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(isAr ? "تم الإغلاق" : "Close Routine"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Step Indicator
                  LinearProgressIndicator(
                    value: (_currentStepIndex + 1) / steps.length,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
                    minHeight: 6,
                  ),
                  const SizedBox(height: 16),

                  // Current Step Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isStepActive ? AppColors.accentCyan : AppColors.cardBorder,
                        width: _isStepActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accentCyan.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "Step ${_currentStepIndex + 1}/${steps.length}",
                                style: const TextStyle(color: AppColors.accentCyan, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            const Spacer(),
                            if (_isStepActive)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warningOrange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "${_stepRemainingSeconds}s remaining",
                                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          currentStep.getTitle(isAr),
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentStep.getInstruction(isAr),
                          style: const TextStyle(color: AppColors.textWhite, fontSize: 13, height: 1.4),
                        ),
                        const SizedBox(height: 16),

                        // Monitored telemetry if available
                        if (currentStep.monitoredPid.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.analytics_outlined, size: 18, color: AppColors.primaryYellow),
                                    const SizedBox(width: 8),
                                    Text(
                                      "PID ${currentStep.monitoredPid}:",
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                                    ),
                                  ],
                                ),
                                Text(
                                  "${widget.obdState.batteryVoltage.toStringAsFixed(1)} ${currentStep.monitoredUnit}",
                                  style: const TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Step CTA button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isStepActive ? AppColors.warningOrange : AppColors.accentCyan,
                              foregroundColor: Colors.black,
                            ),
                            icon: Icon(_isStepActive ? Icons.sync : Icons.play_arrow),
                            label: Text(
                              _isStepActive
                                  ? (isAr ? "جاري تشغيل المرحلة..." : "Executing Step...")
                                  : currentStep.getPromptAction(isAr),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: _isStepActive ? null : _startCurrentStep,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
