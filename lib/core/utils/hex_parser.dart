import 'dart:convert';

/// معالج ومحلل بايتات الـ Hex وسلاسل ردود محول ELM327
class HexParser {
  /// تنظيف الرد الخام من الرموز الزائدة والـ Prompt `>`
  static String cleanRawResponse(String raw) {
    return raw
        .replaceAll('\r', '')
        .replaceAll('\n', ' ')
        .replaceAll('>', '')
        .trim();
  }

  /// التحقق مما إذا كان الرد يحتوي على خطأ أو عدم وجود اتصال
  static bool isErrorResponse(String raw) {
    final upper = raw.toUpperCase().trim();
    if (upper.isEmpty) return true;

    // رسائل الخطأ الحقيقية الصريحة فقط
    if (upper.contains('NO DATA') ||
        upper.contains('UNABLE TO CONNECT') ||
        upper.contains('CAN ERROR') ||
        upper.contains('BUS INIT: ERROR') ||
        upper.contains('BUS INIT: BUS ERROR') ||
        upper.contains('BUS ERROR') ||
        upper.contains('BUFFER FULL') ||
        upper.contains('FB ERROR') ||
        upper.contains('STOPPED') ||
        upper == '?' ||
        upper == 'ERROR') {
      return true;
    }

    // تنبيه: عبارات "BUS INIT: ... OK" أو "BUS INIT: ..." أو "SEARCHING..."
    // ليست أخطاء، بل هي رسائل تقدم أثناء فحص بروتوكولات K-Line و CAN
    return false;
  }

  /// استخراج مصفوفة البايتات بالأرقام (List<int>) من رد الـ Hex المنظف
  static List<int> extractBytes(String rawResponse) {
    final clean = cleanRawResponse(rawResponse);
    if (isErrorResponse(clean)) return [];

    // التخلص من معرفات الإطارات المتعددة (مثل 0: و 1: و 7E8)
    final tokens = clean.split(RegExp(r'\s+'));
    final List<int> bytes = [];

    for (var token in tokens) {
      token = token.trim();
      if (token.isEmpty) continue;
      // تجاهل عدادات الأسطر في بروتوكول CAN مثل "0:" أو "1:" أو "2:"
      if (RegExp(r'^[0-9A-Fa-f]:$').hasMatch(token)) continue;
      // تجاهل عناوين CAN مثل 7E8 أو 7EA إن كانت موجودة
      if (token.length == 3 && RegExp(r'^[7][E-F][0-9A-Fa-f]$').hasMatch(token)) {
        continue;
      }

      // إذا كانت التوكن عبارة عن سلسلة أطول من بايتين متصلة (مثل 410C0FA0) نقسمها لبايتات
      if (token.length > 2 && token.length % 2 == 0) {
        for (int i = 0; i < token.length; i += 2) {
          final byteStr = token.substring(i, i + 2);
          final val = int.tryParse(byteStr, radix: 16);
          if (val != null) bytes.add(val);
        }
      } else {
        final val = int.tryParse(token, radix: 16);
        if (val != null) bytes.add(val);
      }
    }
    return bytes;
  }

  /// التحقق من مطابقة الرد للطلب المرسل (مثلاً طلب 01 0C يرد 41 0C)
  static bool matchesExpectedMode(List<int> bytes, int requestedMode, [int? requestedPid]) {
    if (bytes.isEmpty) return false;
    final expectedResponseMode = requestedMode + 0x40; // 0x01 -> 0x41, 0x03 -> 0x43

    int modeIndex = -1;
    for (int i = 0; i < bytes.length; i++) {
      if (bytes[i] == expectedResponseMode) {
        modeIndex = i;
        break;
      }
    }

    if (modeIndex == -1) return false;
    if (requestedPid != null) {
      if (modeIndex + 1 < bytes.length && bytes[modeIndex + 1] == requestedPid) {
        return true;
      }
      return false;
    }
    return true;
  }

  /// استخراج بيانات بايتات الحساس (Payload) بعد رقم الـ Mode والـ PID
  static List<int> extractPayload(List<int> bytes, int requestedMode, int requestedPid) {
    final expectedResponseMode = requestedMode + 0x40;
    for (int i = 0; i < bytes.length - 1; i++) {
      if (bytes[i] == expectedResponseMode && bytes[i + 1] == requestedPid) {
        return bytes.sublist(i + 2);
      }
    }
    return [];
  }

  /// فك تشفير مصفوفة البايتات إلى قائمة أكواد أعطال قياسية (Standard DTCs)
  /// مثال: [0x43, 0x01, 0x33, 0x03, 0x00] -> ["P0133", "P0300"]
  static List<String> parseDtcs(List<int> bytes, int mode) {
    final expectedResponseMode = mode + 0x40; // 0x03 -> 0x43, 0x07 -> 0x47, 0x0A -> 0x4A
    final List<String> dtcs = [];

    int startIndex = 0;
    // ابحث عن بداية بايت الرد
    for (int i = 0; i < bytes.length; i++) {
      if (bytes[i] == expectedResponseMode) {
        startIndex = i + 1;
        break;
      }
    }

    // إذا كان البايت التالي يمثل عدد الأكواد (في بعض الأنظمة) نتخطاه إذا لزم
    final remaining = bytes.sublist(startIndex);

    // كل كود عطل يتكون من بايتين متتاليين (A و B)
    for (int i = 0; i + 1 < remaining.length; i += 2) {
      final byteA = remaining[i];
      final byteB = remaining[i + 1];

      // الكود 00 00 يعني انتهاء القائمة أو حشو (Padding)
      if (byteA == 0 && byteB == 0) continue;

      final dtc = decodeSingleDtc(byteA, byteB);
      if (dtc.isNotEmpty && !dtcs.contains(dtc)) {
        dtcs.add(dtc);
      }
    }

    return dtcs;
  }

  /// Convenience helper to extract DTC list directly from raw ELM327 response
  static List<String> extractDtcList(String rawResponse) {
    final bytes = extractBytes(rawResponse);
    return parseDtcs(bytes, 0x03);
  }

  /// فك بايتين إلى صيغة كود عطل قياسية (مثال: P0133)
  static String decodeSingleDtc(int byteA, int byteB) {
    if (byteA == 0 && byteB == 0) return "";

    // أول بتين تحدد النظام:
    // 00 -> P (Powertrain - الماتور والفتيس)
    // 01 -> C (Chassis - الشاسيه والفرامل والتعليق)
    // 10 -> B (Body - جسم السيارة والتكييف والإيرباج)
    // 11 -> U (Network - شبكة الكان بس والكنترولات)
    final typeBits = (byteA >> 6) & 0x03;
    String prefix = 'P';
    switch (typeBits) {
      case 0:
        prefix = 'P';
        break;
      case 1:
        prefix = 'C';
        break;
      case 2:
        prefix = 'B';
        break;
      case 3:
        prefix = 'U';
        break;
    }

    final digit1 = ((byteA >> 4) & 0x03).toString();
    final digit2 = (byteA & 0x0F).toRadixString(16).toUpperCase();
    final digit34 = byteB.toRadixString(16).padLeft(2, '0').toUpperCase();

    return '$prefix$digit1$digit2$digit34';
  }

  /// فك تشفير رقم الشاسيه VIN من رد الـ Mode 09 PID 02
  static String parseVin(List<int> bytes) {
    // نبحث عن 49 02
    int dataStart = -1;
    for (int i = 0; i < bytes.length - 1; i++) {
      if (bytes[i] == 0x49 && bytes[i + 1] == 0x02) {
        dataStart = i + 2;
        break;
      }
    }

    if (dataStart == -1) {
      // قد تأتي البايتات مجمعة مباشرة
      dataStart = 0;
    }

    final vinBytes = <int>[];
    for (int i = dataStart; i < bytes.length; i++) {
      final b = bytes[i];
      // الحروف والأرقام الإنجليزية المعتمدة في الـ VIN (ASCII 32-126)
      if (b >= 48 && b <= 90 || (b >= 97 && b <= 122)) {
        vinBytes.add(b);
      }
    }

    final vin = utf8.decode(vinBytes, allowMalformed: true).trim();
    // رقم الـ VIN القياسي يتكون عادة من 17 رمزاً
    if (vin.length > 17) {
      return vin.substring(vin.length - 17);
    }
    return vin;
  }

  /// استخراج فولت البطارية من رد أمر AT RV (مثال "12.6V" -> 12.6)
  static double? parseVoltage(String raw) {
    final clean = cleanRawResponse(raw).replaceAll('V', '').trim();
    return double.tryParse(clean);
  }
}
