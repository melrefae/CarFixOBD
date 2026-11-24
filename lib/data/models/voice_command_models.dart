/// Models for Workshop Hands-Free Voice Assistant
enum VoiceCommandIntent {
  scanDtcs,
  clearDtcs,
  readRpm,
  checkBattery,
  startUsedCarAudit,
  snapshotFreezeFrame,
  showWiring,
  queryCoolantTemp,
  help,
  unknown,
}

class VoiceCommandResult {
  final String recognizedText;
  final VoiceCommandIntent intent;
  final double confidence;
  final String feedbackEn;
  final String feedbackAr;
  final DateTime timestamp;
  final bool executed;

  const VoiceCommandResult({
    required this.recognizedText,
    required this.intent,
    required this.confidence,
    required this.feedbackEn,
    required this.feedbackAr,
    required this.timestamp,
    this.executed = true,
  });

  String localizedFeedback(bool isArabic) => isArabic ? feedbackAr : feedbackEn;
}

class VoicePhraseGuide {
  final String category;
  final String englishPhrase;
  final String arabicPhrase;
  final VoiceCommandIntent intent;

  const VoicePhraseGuide({
    required this.category,
    required this.englishPhrase,
    required this.arabicPhrase,
    required this.intent,
  });
}

class VoiceCommandCatalog {
  static const List<VoicePhraseGuide> phrases = [
    VoicePhraseGuide(
      category: "DTCs & Health",
      englishPhrase: "Scan trouble codes",
      arabicPhrase: "اقرأ الأعطال",
      intent: VoiceCommandIntent.scanDtcs,
    ),
    VoicePhraseGuide(
      category: "DTCs & Health",
      englishPhrase: "Clear trouble codes",
      arabicPhrase: "امسح الأعطال",
      intent: VoiceCommandIntent.clearDtcs,
    ),
    VoicePhraseGuide(
      category: "Live Telemetry",
      englishPhrase: "Read engine RPM",
      arabicPhrase: "اقرأ الآر بي إم",
      intent: VoiceCommandIntent.readRpm,
    ),
    VoicePhraseGuide(
      category: "Electrical",
      englishPhrase: "Check battery voltage",
      arabicPhrase: "افحص جهد البطارية",
      intent: VoiceCommandIntent.checkBattery,
    ),
    VoicePhraseGuide(
      category: "Forensic Audit",
      englishPhrase: "Start used car audit",
      arabicPhrase: "ابدأ فحص السيارة المستعملة",
      intent: VoiceCommandIntent.startUsedCarAudit,
    ),
    VoicePhraseGuide(
      category: "Data Logging",
      englishPhrase: "Snapshot freeze frame",
      arabicPhrase: "سجل لقطة فريز فريم",
      intent: VoiceCommandIntent.snapshotFreezeFrame,
    ),
    VoicePhraseGuide(
      category: "Schematics",
      englishPhrase: "Show wiring schematic",
      arabicPhrase: "افتح مخطط الضفيرة والفيش",
      intent: VoiceCommandIntent.showWiring,
    ),
    VoicePhraseGuide(
      category: "Thermal",
      englishPhrase: "Check coolant temperature",
      arabicPhrase: "افحص حرارة المحرك",
      intent: VoiceCommandIntent.queryCoolantTemp,
    ),
  ];
}
