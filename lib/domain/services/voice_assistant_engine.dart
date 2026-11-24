import '../../data/models/voice_command_models.dart';

/// Automotive Diagnostic Voice Assistant NLP & Command Processing Engine
class VoiceAssistantEngine {
  /// Parse incoming spoken technician speech string into an actionable intent
  VoiceCommandResult parseCommand(String rawTranscript) {
    final text = rawTranscript.trim().toLowerCase();
    if (text.isEmpty) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.unknown,
        confidence: 0.0,
        feedbackEn: "No voice input detected. Please speak an automotive command.",
        feedbackAr: "لم يتم التعرف على صوت. الرجاء نطق أمر فحص للمركبة.",
        timestamp: DateTime.now(),
        executed: false,
      );
    }

    // 1. Clear DTCs / Erase Faults (Checked first so 'clear trouble codes' doesn't trigger scan)
    if (_matches(text, [
      "clear", "erase", "reset codes", "wipe dtc", "delete codes",
      "امسح الأعطال", "مسح الأعطال", "تصفير الأعطال", "امسح الاعطال", "حذف الاعطال"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.clearDtcs,
        confidence: 0.92,
        feedbackEn: "Preparing to erase stored fault codes. Ensure vehicle ignition is ON with engine OFF.",
        feedbackAr: "جارِ تجهيز مسح الأعطال. تأكد من فتح الكونتاك والمحرك مطفأ تماماً.",
        timestamp: DateTime.now(),
      );
    }

    // 2. Scan DTCs / Faults
    if (_matches(text, [
      "scan", "read codes", "fault codes", "trouble codes", "dtc", "check engine",
      "اقرأ الأعطال", "فحص الأعطال", "كشف الأعطال", "اقرا الاعطال", "اعطال المحرك"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.scanDtcs,
        confidence: 0.95,
        feedbackEn: "Scanning all vehicle ECU systems for diagnostic fault codes...",
        feedbackAr: "جارِ قراءة وفحص أكواد الأعطال من كافة كمبيوترات السيارة...",
        timestamp: DateTime.now(),
      );
    }

    // 3. Engine RPM
    if (_matches(text, [
      "rpm", "engine speed", "revs", "tachometer", "crank speed",
      "ار بي ام", "سرعة المحرك", "الار بي ام", "لفات المحرك"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.readRpm,
        confidence: 0.94,
        feedbackEn: "Reading live engine rotational speed (RPM) from primary ECM stream.",
        feedbackAr: "جارِ قراءة سرعة دوران المحرك بالدقيقة من كمبيوتر المحرك الحي.",
        timestamp: DateTime.now(),
      );
    }

    // 4. Battery Voltage & Charging Alternator
    if (_matches(text, [
      "battery", "voltage", "volts", "alternator", "charging",
      "بطارية", "البطارية", "جهد البطارية", "شحن الدينامو", "الفولت"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.checkBattery,
        confidence: 0.96,
        feedbackEn: "Measuring vehicle terminal voltage and 12V alternator charging output.",
        feedbackAr: "جارِ قياس جهد أطراف البطارية وكفاءة شحن دينامو السيارة.",
        timestamp: DateTime.now(),
      );
    }

    // 5. Used Car Pre-Purchase Audit & Odometer Rollback
    if (_matches(text, [
      "used car", "audit", "pre purchase", "inspection", "rollback", "odometer",
      "فحص مستعمل", "سيارة مستعملة", "فحص الشراء", "عداد", "فحص شامل"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.startUsedCarAudit,
        confidence: 0.93,
        feedbackEn: "Initiating 6-Report Used Car Forensic Audit and Odometer Cross-Check.",
        feedbackAr: "بدء التدقيق الجنائي للسيارة المستعملة وكشف تلاعب العداد والـ 6 تقارير.",
        timestamp: DateTime.now(),
      );
    }

    // 6. Freeze Frame Snapshot
    if (_matches(text, [
      "freeze frame", "snapshot", "capture frame", "freeze",
      "فريز فريم", "لقطة التجميد", "لقطة فريز", "تسجيل اللقطة"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.snapshotFreezeFrame,
        confidence: 0.91,
        feedbackEn: "Capturing freeze-frame operating parameters at moment of DTC occurrence.",
        feedbackAr: "جارِ تسجيل بيانات الفريز فريم اللحظية المسجلة أثناء حدوث العطل.",
        timestamp: DateTime.now(),
      );
    }

    // 7. Wiring Schematics & Pinouts
    if (_matches(text, [
      "wiring", "schematic", "pinout", "circuit", "diagram",
      "ضفيرة", "مخطط", "فيشة", "اسلاك", "المخطط الكهربائي"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.showWiring,
        confidence: 0.92,
        feedbackEn: "Opening interactive vector electrical wiring schematics and multimeter pinouts.",
        feedbackAr: "فتح مخططات الضفيرة التفاعلية ودليل قياس الفولتيات بالأفوميتر.",
        timestamp: DateTime.now(),
      );
    }

    // 8. Coolant Temperature
    if (_matches(text, [
      "coolant", "temperature", "temp", "engine heat",
      "حرارة", "سخونة", "حرارة المحرك", "مياه الردياتير", "درجة الحرارة"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.queryCoolantTemp,
        confidence: 0.95,
        feedbackEn: "Reading Engine Coolant Temperature (ECT) sensor telemetry.",
        feedbackAr: "جارِ قراءة حساس درجة حرارة سائل تبريد المحرك.",
        timestamp: DateTime.now(),
      );
    }

    // 9. Help / Available Commands
    if (_matches(text, [
      "help", "commands", "what can you do", "options",
      "مساعدة", "الاوامر", "الأوامر", "ماذا تفعل", "طريقة الاستخدام"
    ])) {
      return VoiceCommandResult(
        recognizedText: rawTranscript,
        intent: VoiceCommandIntent.help,
        confidence: 0.98,
        feedbackEn: "Available voice commands: Scan trouble codes, Read RPM, Check battery, Start used car audit, Freeze frame, Wiring diagram.",
        feedbackAr: "الأوامر المتاحة: اقرأ الأعطال، افحص البطارية، اقرأ الآر بي إم، ابدأ فحص مستعمل، سجل فريز فريم، افتح المخطط.",
        timestamp: DateTime.now(),
      );
    }

    // Unmatched / Unknown
    return VoiceCommandResult(
      recognizedText: rawTranscript,
      intent: VoiceCommandIntent.unknown,
      confidence: 0.35,
      feedbackEn: "Command '$rawTranscript' not recognized. Try saying 'Scan trouble codes' or 'Check battery'.",
      feedbackAr: "لم يتم فهم الأمر '$rawTranscript'. جرب نطق 'اقرأ الأعطال' أو 'افحص البطارية'.",
      timestamp: DateTime.now(),
      executed: false,
    );
  }

  bool _matches(String text, List<String> keywords) {
    for (final kw in keywords) {
      if (text.contains(kw.toLowerCase())) return true;
    }
    return false;
  }
}
