import 'mode06_tables.dart';
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
  /// "Mode 06" (CAN) or "Mode 05" (older buses).
  final String source;
  /// False when the UASID is not in the standard table: the numbers are raw, not converted.
  final bool scalingKnown;
  /// False when the standard says the ECU sent no limits (constant tests in Mode 05).
  final bool hasLimits;
  /// True when value and both limits are all 0. The standard uses this for "supported but never
  /// completed since the codes were erased", so it is not a pass.
  final bool noResult;

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
    this.source = 'Mode 06',
    this.scalingKnown = true,
    this.hasLimits = true,
    this.noResult = false,
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

  /// Parse SAE J1979 Mode $06 results (CAN, ISO 15765-4). After the 0x46 response byte each test
  /// record is 9 bytes: MID, TID, UASID, value(2), min(2), max(2). Values are converted with the
  /// Unit and Scaling table of the standard. An unknown UASID keeps the raw number and says so.
  static List<Mode06TestResult> parseMode06Results(List<int> bytes) {
    final results = <Mode06TestResult>[];
    int i = 0;
    while (i < bytes.length) {
      // A message is 0x46 plus whole 9-byte records. Skip a 0x46 that starts a message, but not
      // a MID that is itself 0x46 (heater monitor B2S2): decide by how many bytes are left.
      final rem = bytes.length - i;
      if (bytes[i] == 0x46 && (rem % 9 == 1 || rem % 10 == 0)) {
        i++;
        continue;
      }
      if (i + 8 >= bytes.length) break;
      final mid = bytes[i];
      final tid = bytes[i + 1];
      final uasid = bytes[i + 2];
      final rawVal = (bytes[i + 3] << 8) | bytes[i + 4];
      final rawMin = (bytes[i + 5] << 8) | bytes[i + 6];
      final rawMax = (bytes[i + 7] << 8) | bytes[i + 8];
      i += 9;

      final conv = uasConvert(uasid, rawVal);
      final known = conv != null;
      final val = conv ?? rawVal.toDouble();
      final minVal = uasConvert(uasid, rawMin) ?? rawMin.toDouble();
      final maxVal = uasConvert(uasid, rawMax) ?? rawMax.toDouble();
      final none = rawVal == 0 && rawMin == 0 && rawMax == 0;
      final passed = !none && val >= minVal && val <= maxVal;

      results.add(Mode06TestResult(
        mid: mid,
        tid: tid,
        uasid: uasid,
        measuredValue: val,
        minLimit: minVal,
        maxLimit: maxVal,
        isPassed: passed,
        monitorName: '${mode06MidName(mid)}: ${standardTidName(tid)}',
        unit: known ? uasUnit(uasid) : 'raw (scaling 0x${uasid.toRadixString(16).toUpperCase()} not in the standard table)',
        scalingKnown: known,
        noResult: none,
      ));
    }
    return results;
  }

  /// Parse Mode $05 replies (older buses): 45, TID, sensor, value [, min, max], one byte each.
  /// Constant tests (TID 01-04) carry no limits.
  static List<Mode06TestResult> parseMode05Results(List<int> bytes) {
    final results = <Mode06TestResult>[];
    var i = bytes.indexOf(0x45);
    while (i >= 0 && i + 3 < bytes.length) {
      final tid = bytes[i + 1];
      final sensor = bytes[i + 2];
      final sc = mode05Scale(tid);
      final constant = tid >= 0x01 && tid <= 0x04;
      final need = constant ? 4 : 6;
      if (i + need > bytes.length) break;
      final scale = sc?.$1 ?? 1.0;
      final unit = sc?.$2 ?? 'raw (manufacturer test)';
      final v = bytes[i + 3] * scale;
      final mn = constant ? v : bytes[i + 4] * scale;
      final mx = constant ? v : bytes[i + 5] * scale;
      results.add(Mode06TestResult(
        mid: sensor,
        tid: tid,
        uasid: 0,
        measuredValue: v,
        minLimit: mn,
        maxLimit: mx,
        isPassed: constant ? true : (v >= mn && v <= mx),
        monitorName: 'O2 sensor ${o2SensorName(sensor)}: ${standardTidName(tid)}',
        unit: unit,
        source: 'Mode 05',
        scalingKnown: sc != null,
        hasLimits: !constant,
      ));
      i += need;
      if (i < bytes.length && bytes[i] != 0x45) {
        final j = bytes.indexOf(0x45, i);
        i = j;
      }
    }
    return results;
  }

  /// استخراج فولت البطارية من رد أمر AT RV (مثال "12.6V" -> 12.6)
  static double? parseVoltage(String raw) {
    final clean = cleanRawResponse(raw).replaceAll('V', '').trim();
    return double.tryParse(clean);
  }
}
