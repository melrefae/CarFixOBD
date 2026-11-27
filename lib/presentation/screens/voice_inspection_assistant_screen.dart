import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/voice_command_models.dart';
import '../../domain/services/voice_assistant_engine.dart';
import '../providers/obd_state.dart';
import 'used_car_audit_screen.dart';
import 'wiring_schematics_screen.dart';

/// Hands-Free Voice-Guided Automotive Diagnostic Assistant
class VoiceInspectionAssistantScreen extends StatefulWidget {
  const VoiceInspectionAssistantScreen({super.key});

  @override
  State<VoiceInspectionAssistantScreen> createState() => _VoiceInspectionAssistantScreenState();
}

class _VoiceInspectionAssistantScreenState extends State<VoiceInspectionAssistantScreen>
    with SingleTickerProviderStateMixin {
  final VoiceAssistantEngine _engine = VoiceAssistantEngine();
  final TextEditingController _manualTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isListening = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<VoiceCommandResult> _history = [
    VoiceCommandResult(
      recognizedText: "System Initialized",
      intent: VoiceCommandIntent.help,
      confidence: 1.0,
      feedbackEn: "AutoSpect voice assistant ready. Tap the microphone or say 'Scan trouble codes'.",
      feedbackAr: "المساعد الصوتي للفحص جاهز. اضغط على الميكروفون أو انطق 'اقرأ الأعطال'.",
      timestamp: DateTime.now(),
      executed: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _manualTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _processVoiceInput(String text) {
    if (text.trim().isEmpty) return;
    final result = _engine.parseCommand(text);

    setState(() {
      _history.add(result);
      _isListening = false;
    });

    // Auto scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Execute associated diagnostic action
    final obdState = Provider.of<ObdState>(context, listen: false);
    switch (result.intent) {
      case VoiceCommandIntent.scanDtcs:
        if (obdState.isConnected) {
          obdState.readDtcs();
        }
        break;
      case VoiceCommandIntent.startUsedCarAudit:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsedCarAuditScreen()),
        );
        break;
      case VoiceCommandIntent.showWiring:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WiringSchematicsScreen()),
        );
        break;
      default:
        break;
    }
  }

  void _toggleMic() {
    final text = _manualTextController.text.trim();
    if (text.isNotEmpty) {
      _processVoiceInput(text);
      _manualTextController.clear();
      return;
    }

    final isAr = Provider.of<ObdState>(context, listen: false).isArabic;
    _showVoiceDictationDialog(context, isAr);
  }

  Future<void> _showVoiceDictationDialog(BuildContext context, bool isAr) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.mic, color: AppColors.primaryYellow),
              const SizedBox(width: 8),
              Text(
                isAr ? "إملاء أمر صوتي للفحص" : "Technician Voice Dictation",
                style: const TextStyle(fontSize: 16, color: AppColors.textWhite),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAr
                      ? "تحدث بأمر الفحص أو اختر أمراً تشخيصياً أدناه:"
                      : "Speak diagnostic command or select a quick voice shortcut below:",
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: isAr ? "مثال: افحص جهد البطارية" : "e.g., Check battery voltage",
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  isAr ? "أوامر صوتية سريعة:" : "Quick Voice Commands:",
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final cmd in isAr
                        ? ["اقرأ الأعطال", "افحص جهد البطارية", "اقرأ الآر بي إم", "ابدأ فحص مستعمل", "عرض المخططات الكهربائية", "امسح الأعطال"]
                        : ["Scan trouble codes", "Check battery voltage", "Read engine RPM", "Start used car audit", "Show wiring", "Clear trouble codes"])
                      ActionChip(
                        backgroundColor: AppColors.backgroundDark,
                        label: Text(cmd, style: const TextStyle(fontSize: 11, color: AppColors.textWhite)),
                        onPressed: () {
                          controller.text = cmd;
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? "إلغاء" : "Cancel", style: const TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: Colors.black),
              onPressed: () {
                final txt = controller.text.trim();
                Navigator.pop(ctx);
                if (txt.isNotEmpty) {
                  _processVoiceInput(txt);
                }
              },
              child: Text(isAr ? "تنفيذ الأمر" : "Execute Command"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final obdState = Provider.of<ObdState>(context);
    final isAr = obdState.isArabic;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(isAr ? "المساعد الصوتي بدون استخدام اليدين" : "Hands-Free Voice Assistant"),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: isAr ? "دليل الأوامر الصوتية" : "Voice Commands Guide",
            onPressed: () => _showCommandsGuide(context, isAr),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hardware Connection & Battery Status Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.cardSurface,
            child: Row(
              children: [
                Icon(
                  obdState.isConnected ? Icons.check_circle : Icons.warning_amber,
                  color: obdState.isConnected ? AppColors.successGreen : AppColors.primaryAmber,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  obdState.isConnected
                      ? (isAr ? "متصل بالمركبة (${obdState.activeProtocolName})" : "Connected: ${obdState.activeProtocolName}")
                      : (isAr ? "غير متصل بجهاز OBD" : "OBD Hardware Disconnected"),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Spacer(),
                Text(
                  "12V: ${obdState.batteryVoltage.toStringAsFixed(1)}V",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                ),
              ],
            ),
          ),

          // Conversation Transcript List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final isUser = index > 0 && index.isOdd;
                return _buildMessageBubble(item, isUser, isAr);
              },
            ),
          ),

          // Quick Commands Suggested Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: VoiceCommandCatalog.phrases.map((guide) {
                final label = isAr ? guide.arabicPhrase : guide.englishPhrase;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    backgroundColor: AppColors.cardSurface,
                    label: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                    avatar: const Icon(Icons.mic, size: 14, color: AppColors.primaryYellow),
                    onPressed: () => _processVoiceInput(label),
                  ),
                );
              }).toList(),
            ),
          ),

          // Bottom Voice Action Console
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isListening)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.graphic_eq, color: AppColors.dangerRed, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isAr ? "جارِ الاستماع لأمر الفني الصوتي..." : "Listening for technician voice command...",
                            style: const TextStyle(
                              color: AppColors.dangerRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      // Manual type fallback
                      Expanded(
                        child: TextField(
                          controller: _manualTextController,
                          decoration: InputDecoration(
                            hintText: isAr ? "أو اكتب الأمر هنا..." : "Or type diagnostic command...",
                            hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          onSubmitted: (val) {
                            _processVoiceInput(val);
                            _manualTextController.clear();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Animated Mic Button
                      ScaleTransition(
                        scale: _isListening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                        child: GestureDetector(
                          onTap: _toggleMic,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? [AppColors.dangerRed, Colors.orange]
                                    : [AppColors.primaryYellow, AppColors.primaryAmber],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? AppColors.dangerRed : AppColors.primaryYellow)
                                      .withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(VoiceCommandResult item, bool isUser, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isUser ? Icons.person : Icons.smart_toy,
                size: 14,
                color: isUser ? AppColors.accentCyan : AppColors.primaryYellow,
              ),
              const SizedBox(width: 6),
              Text(
                isUser ? (isArabic ? "الفني" : "Technician") : (isArabic ? "المساعد الذكي" : "Aspect Assistant"),
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isUser ? AppColors.electricBlue.withOpacity(0.2) : AppColors.cardSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isUser ? AppColors.electricBlue.withOpacity(0.4) : Colors.white12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isUser)
                  Text(
                    '"${item.recognizedText}"',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                  )
                else ...[
                  Text(
                    item.localizedFeedback(isArabic),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryYellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.intent.name.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${(item.confidence * 100).toStringAsFixed(0)}% confidence",
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCommandsGuide(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isArabic ? "كتالوج الأوامر الصوتية المدعومة" : "Supported Voice Commands Catalog",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: VoiceCommandCatalog.phrases.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
                    itemBuilder: (context, i) {
                      final p = VoiceCommandCatalog.phrases[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.record_voice_over, color: AppColors.accentCyan, size: 20),
                        title: Text(isArabic ? p.arabicPhrase : p.englishPhrase, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(p.category, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.white30),
                        onTap: () {
                          Navigator.pop(context);
                          _processVoiceInput(isArabic ? p.arabicPhrase : p.englishPhrase);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
