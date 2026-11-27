import 'dart:convert';

/// Decoded ISO 14229 UDS DTC record (3-byte DTC + Status Availability Mask)
class UdsDtcRecord {
  final String code;
  final int failureTypeByte;
  final int statusByte;

  const UdsDtcRecord({
    required this.code,
    required this.failureTypeByte,
    required this.statusByte,
  });

  bool get isConfirmed => (statusByte & 0x08) != 0;
  bool get isPending => (statusByte & 0x04) != 0;
  bool get isCurrent => (statusByte & 0x01) != 0;
}

/// Decoded SAE J1979 Mode $06 On-Board Component Test Result
class Mode06TestResult {
  final int mid;
  final int tid;
  final int uasid;
  final double measuredValue;
  final double minLimit;
  final double maxLimit;
  final bool isPassed;
  final String monitorName;
  final String unit;

  const Mode06TestResult({
    required this.mid,
    required this.tid,
    required this.uasid,
    required this.measuredValue,
    required this.minLimit,
    required this.maxLimit,
    required this.isPassed,
    required this.monitorName,
    required this.unit,
  });

  String get midHex => '0x${mid.toRadixString(16).toUpperCase().padLeft(2, '0')}';
  String get tidHex => '0x${tid.toRadixString(16).toUpperCase().padLeft(2, '0')}';
}

/// معالج ومحلل بايتات الـ Hex وسلاسل ردود محول ELM327
class HexParser {
  /// تنظيف الرد الخام من الرموز الزائدة والـ Prompt `>`
  static String cleanRawResponse(String raw) {
    return raw
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('>', '')
        .replaceAll(RegExp(r'\s+'), ' ')
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
    final hasMultiFramePrefix = tokens.any((t) => RegExp(r'^[0-9A-Fa-f]:$').hasMatch(t));
    final List<int> bytes = [];

    for (var i = 0; i < tokens.length; i++) {
      var token = tokens[i].trim();
      if (token.isEmpty) continue;

      // تجاهل عدادات الأسطر في بروتوكول CAN مثل "0:" أو "1:" أو "2:"
      if (RegExp(r'^[0-9A-Fa-f]:$').hasMatch(token)) continue;

      // تجاهل طول الإطار ISO-TP مثل "014" قبل "0:"
      if (hasMultiFramePrefix &&
          RegExp(r'^0[0-9A-Fa-f]{2}$').hasMatch(token) &&
          i + 1 < tokens.length &&
          tokens[i + 1].trim() == '0:') {
        continue;
      }

      // تجاهل عناوين CAN مثل 7E8 أو 7EA أو 728 إن كانت موجودة في الترويسة
      if (token.length == 3 && RegExp(r'^7[0-9A-Fa-f]{2}$').hasMatch(token)) {
        continue;
      }

      // إذا كانت التوكن عبارة عن سلسلة أطول من بايتين متصلة (مثل 410C0FA0) نقسمها لبايتات
      if (token.length > 2 && token.length % 2 == 0) {
        for (int j = 0; j < token.length; j += 2) {
          final byteStr = token.substring(j, j + 2);
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

  /// Decode Mode 01 supported PID bitmask (`01 00`, `01 20`, `01 40`, `01 60`, `01 80`, `01 A0`)
  /// Returns 2-digit uppercase hex strings such as {'04', '05', '0C', '0D'}
  static Set<String> parseSupportedPidBitmask(List<int> payload4Bytes, int basePid) {
    final supported = <String>{};
    if (payload4Bytes.length < 4) return supported;

    for (int byteIdx = 0; byteIdx < 4; byteIdx++) {
      final b = payload4Bytes[byteIdx];
      for (int bit = 7; bit >= 0; bit--) {
        if ((b & (1 << bit)) != 0) {
          final pidNum = basePid + (byteIdx * 8) + (7 - bit) + 1;
          supported.add(pidNum.toRadixString(16).toUpperCase().padLeft(2, '0'));
        }
      }
    }
    return supported;
  }

  /// فك تشفير مصفوفة البايتات إلى قائمة أكواد أعطال قياسية (Standard DTCs)
  /// مثال: [0x43, 0x01, 0x33, 0x03, 0x00] -> ["P0133", "P0300"]
  /// Parse DTCs from an adapter reply. On legacy buses (ISO 9141-2, KWP2000, J1850) every ECU
  /// line is "43" plus 6 data bytes (3 code slots, padded with 00), and the driver joins the
  /// lines into one string. Reading that as one block would take the next line's "43" for
  /// code data, so a reply made of whole 7-byte groups that each start with the response byte
  /// is parsed group by group. A CAN reply has an even length here (response byte, count,
  /// then pairs) or lines with "0:" / "1:", so it still goes through [parseDtcs].
  static List<String> parseDtcsRaw(String raw, int mode) {
    final expected = mode + 0x40;
    final bytes = extractBytes(raw);
    if (!raw.contains(':') && bytes.length >= 7 && bytes.length % 7 == 0 &&
        [for (var i = 0; i < bytes.length; i += 7) bytes[i]].every((b) => b == expected)) {
      final out = <String>[];
      for (var g = 0; g < bytes.length; g += 7) {
        for (var i = g + 1; i + 1 < g + 7; i += 2) {
          if (bytes[i] == 0 && bytes[i + 1] == 0) continue;
          final d = decodeSingleDtc(bytes[i], bytes[i + 1]);
          if (d.isNotEmpty && !out.contains(d)) out.add(d);
        }
      }
      return out;
    }
    return parseDtcs(bytes, mode);
  }

  static List<String> parseDtcs(List<int> bytes, int mode) {
    final expectedResponseMode = mode + 0x40; // 0x03 -> 0x43, 0x07 -> 0x47, 0x0A -> 0x4A
    final List<String> dtcs = [];

    int startIndex = -1;
    // ابحث عن بداية بايت الرد
    for (int i = 0; i < bytes.length; i++) {
      if (bytes[i] == expectedResponseMode) {
        startIndex = i + 1;
        break;
      }
    }
    if (startIndex == -1) return dtcs;

    var remaining = bytes.sublist(startIndex);
    // في بروتوكول CAN ISO 15765-4 يسبق الأكواد أحياناً بايت يحدد عدد الأعطال (إذا كان الطول فردياً)
    if (remaining.length >= 3 && remaining.length % 2 == 1) {
      remaining = remaining.sublist(1);
    }

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

  /// Decode ISO 14229 UDS 0x19 0x02 (`0x59 0x02`) DTC response containing 3-byte DTC + Status Mask records
  static List<UdsDtcRecord> parseUdsDtcs(List<int> bytes) {
    final results = <UdsDtcRecord>[];
    int idx = -1;
    for (int i = 0; i < bytes.length - 2; i++) {
      if (bytes[i] == 0x59 && bytes[i + 1] == 0x02) {
        idx = i + 3; // skip 0x59, 0x02, and StatusAvailabilityMask byte
        break;
      }
    }
    if (idx == -1) return results;

    for (int i = idx; i + 3 < bytes.length; i += 4) {
      final high = bytes[i];
      final mid = bytes[i + 1];
      final ftb = bytes[i + 2];
      final status = bytes[i + 3];
      if (high == 0 && mid == 0) continue;

      final baseCode = decodeSingleDtc(high, mid);
      if (baseCode.isNotEmpty) {
        results.add(UdsDtcRecord(
          code: baseCode,
          failureTypeByte: ftb,
          statusByte: status,
        ));
      }
    }
    return results;
  }

  /// Convenience helper to extract DTC list directly from raw ELM327 response (supports Mode 03 & UDS 59 02)
  static List<String> extractDtcList(String rawResponse) {
    final bytes = extractBytes(rawResponse);
    final udsDtcs = parseUdsDtcs(bytes);
    if (udsDtcs.isNotEmpty) {
      return udsDtcs.map((e) => e.code).toSet().toList();
    }
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

  /// Decode printable ASCII string from Mode 09 (`02` VIN, `04` CALID, `0A` ECU Name) responses
  static String parseAsciiResponse(List<int> bytes, int mode, int pid) {
    final expectedMode = mode + 0x40;
    int dataStart = -1;
    for (int i = 0; i < bytes.length - 1; i++) {
      if (bytes[i] == expectedMode && bytes[i + 1] == pid) {
        dataStart = i + 2;
        break;
      }
    }
    if (dataStart == -1) return "";

    // Skip ISO-TP item count byte (typically 0x01 or <= 0x04) right after mode/pid
    if (dataStart < bytes.length && bytes[dataStart] <= 0x10) {
      dataStart++;
    }

    final asciiBytes = <int>[];
    for (int i = dataStart; i < bytes.length; i++) {
      final b = bytes[i];
      if ((b >= 48 && b <= 57) || // 0-9
          (b >= 65 && b <= 90) || // A-Z
          (b >= 97 && b <= 122) || // a-z
          b == 45 || // -
          b == 95 || // _
          b == 46 || // .
          b == 32) { // space
        asciiBytes.add(b);
      }
    }

    return utf8.decode(asciiBytes, allowMalformed: true).replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Decode printable ASCII string from UDS Service 0x22 (`0x62 DID_HI DID_LO ...`)
  static String parseUdsAsciiDid(List<int> bytes, int didHi, int didLo) {
    int start = -1;
    for (int i = 0; i < bytes.length - 2; i++) {
      if (bytes[i] == 0x62 && bytes[i + 1] == didHi && bytes[i + 2] == didLo) {
        start = i + 3;
        break;
      }
    }
    if (start == -1) return "";

    final asciiBytes = <int>[];
    for (int i = start; i < bytes.length; i++) {
      final b = bytes[i];
      if (b >= 32 && b <= 126) {
        asciiBytes.add(b);
      }
    }
    return utf8.decode(asciiBytes, allowMalformed: true).trim();
  }

  /// فك تشفير رقم الشاسيه VIN من رد الـ Mode 09 PID 02 (أو UDS DID F190)
  static String parseVin(List<int> bytes) {
    // Check UDS DID F1 90 first if present
    final udsVin = parseUdsAsciiDid(bytes, 0xF1, 0x90).replaceAll(' ', '');
    if (udsVin.length >= 15) {
      return udsVin.length > 17 ? udsVin.substring(udsVin.length - 17) : udsVin;
    }

    // Standard OBD-II Mode 09 PID 02 (search for 49 02)
    int dataStart = -1;
    for (int i = 0; i < bytes.length - 1; i++) {
      if (bytes[i] == 0x49 && bytes[i + 1] == 0x02) {
        dataStart = i + 2;
        break;
      }
    }

    if (dataStart == -1) {
      // Fallback: bytes already extracted as payload
      dataStart = 0;
    }

    final vinBytes = <int>[];
    for (int i = dataStart; i < bytes.length; i++) {
      final b = bytes[i];
      if ((b >= 48 && b <= 57) || (b >= 65 && b <= 90) || (b >= 97 && b <= 122)) {
        vinBytes.add(b);
      }
    }

    final vin = utf8.decode(vinBytes, allowMalformed: true).trim().toUpperCase();
    // رقم الـ VIN القياسي يتكون عادة من 17 رمزاً
    if (vin.length > 17) {
      return vin.substring(vin.length - 17);
    }
    return vin;
  }

  /// Parse SAE J1979 Mode $06 (CAN 9-byte record format after 0x46 header)
  static List<Mode06TestResult> parseMode06Results(List<int> bytes) {
    final results = <Mode06TestResult>[];
    int i = 0;
    while (i < bytes.length) {
      if (bytes[i] == 0x46) {
        i++;
        // Each CAN Mode $06 monitor test record is 9 bytes:
        // [MID, TID, UASID, ValHi, ValLo, MinHi, MinLo, MaxHi, MaxLo]
        while (i + 8 < bytes.length) {
          if (bytes[i] == 0x46) {
            i++;
            continue;
          }
          final mid = bytes[i];
          final tid = bytes[i + 1];
          final uasid = bytes[i + 2];
          final rawVal = (bytes[i + 3] << 8) | bytes[i + 4];
          final rawMin = (bytes[i + 5] << 8) | bytes[i + 6];
          final rawMax = (bytes[i + 7] << 8) | bytes[i + 8];
          i += 9;

          final (scale, unit, signed) = _uasidScale(uasid);
          final val = _scaleUasid(rawVal, scale, signed);
          final minVal = _scaleUasid(rawMin, scale, signed);
          final maxVal = _scaleUasid(rawMax, scale, signed);
          final passed = val >= minVal && val <= maxVal;

          results.add(Mode06TestResult(
            mid: mid,
            tid: tid,
            uasid: uasid,
            measuredValue: val,
            minLimit: minVal,
            maxLimit: maxVal,
            isPassed: passed,
            monitorName: _mode06MonitorName(mid, tid),
            unit: unit,
          ));
        }
        break;
      }
      i++;
    }
    return results;
  }

  static double _scaleUasid(int raw16, double scale, bool isSigned) {
    int val = raw16;
    if (isSigned && (raw16 & 0x8000) != 0) {
      val = raw16 - 0x10000;
    }
    return val * scale;
  }

  static (double, String, bool) _uasidScale(int uasid) {
    switch (uasid) {
      case 0x01:
      case 0x24:
        return (1.0, 'counts', false);
      case 0x81:
        return (1.0, 'counts', true);
      case 0x02:
      case 0x10:
        return (1.0, 'ms', false);
      case 0x0A:
        return (0.122, 'mV', false);
      case 0x0B:
        return (0.001, 'V', false);
      case 0x8B:
        return (0.001, 'V', true);
      case 0x15:
      case 0x16:
        return (0.1, 'kPa', false);
      case 0x96:
        return (0.1, '°C', true);
      case 0x9C:
        return (0.01, '°', true);
      case 0x20:
        return (0.001, 'ratio', false);
      case 0x25:
        return (0.01, 'mA', false);
      default:
        return (1.0, 'raw', uasid >= 0x80);
    }
  }

  static String _mode06MonitorName(int mid, int tid) {
    if (mid >= 0x01 && mid <= 0x08) {
      return "O2 Sensor Bank ${(mid + 1) ~/ 2} Monitor (TID 0x${tid.toRadixString(16).toUpperCase()})";
    }
    if (mid == 0x21 || mid == 0x22) {
      return "Catalyst Efficiency Bank ${mid - 0x20} (TID 0x${tid.toRadixString(16).toUpperCase()})";
    }
    if (mid >= 0x31 && mid <= 0x34) {
      return "EGR / VVT Monitor Bank ${mid - 0x30} (TID 0x${tid.toRadixString(16).toUpperCase()})";
    }
    if (mid >= 0x3A && mid <= 0x3D) {
      return "EVAP Leak Monitor (MID 0x${mid.toRadixString(16).toUpperCase()})";
    }
    if (mid == 0xA1) {
      return "Misfire General Cylinder Data (TID 0x${tid.toRadixString(16).toUpperCase()})";
    }
    if (mid >= 0xA2 && mid <= 0xA9) {
      return "Cylinder ${mid - 0xA1} Misfire Counter (TID 0x${tid.toRadixString(16).toUpperCase()})";
    }
    return "Monitor MID 0x${mid.toRadixString(16).toUpperCase().padLeft(2, '0')} / TID 0x${tid.toRadixString(16).toUpperCase().padLeft(2, '0')}";
  }

  /// استخراج فولت البطارية من رد أمر AT RV (مثال "12.6V" -> 12.6)
  static double? parseVoltage(String raw) {
    final clean = cleanRawResponse(raw).replaceAll('V', '').trim();
    return double.tryParse(clean);
  }
}
