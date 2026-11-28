import '../../data/datasources/elm327_driver.dart';
import '../../core/utils/hex_parser.dart';

/// One DTC from UDS service 0x19 (ReadDTCInformation, sub-function 0x02).
class UdsDtc {
  final String code; // e.g. P0301 (first two bytes decoded the SAE J2012 way)
  final int failureType; // third DTC byte (ISO 14229 FTB), shown raw
  final int status; // ISO 14229 status byte
  const UdsDtc(this.code, this.failureType, this.status);
  bool get testFailed => status & 0x01 != 0;
  bool get pending => status & 0x04 != 0;
  bool get confirmed => status & 0x08 != 0;
  bool get warningLamp => status & 0x80 != 0;
  String get statusText {
    final p = <String>[];
    if (testFailed) p.add('test failed now');
    if (pending) p.add('pending');
    if (confirmed) p.add('confirmed');
    if (warningLamp) p.add('warning lamp on');
    if (p.isEmpty) p.add('stored, not active (status 0x${status.toRadixString(16).toUpperCase().padLeft(2, '0')})');
    return p.join(', ');
  }
}

class UdsEcuResult {
  final String header; // request CAN id, e.g. 7E0
  final bool answered;
  final List<UdsDtc> dtcs;
  final bool dtcServiceAnswered;
  final Map<String, String> ident; // DID hex -> text
  final String note;
  const UdsEcuResult(this.header, this.answered, this.dtcs, this.dtcServiceAnswered, this.ident, this.note);
}

class UdsReadReport {
  final List<UdsEcuResult> ecus;
  final String note;
  const UdsReadReport(this.ecus, this.note);
  bool get anyAnswered => ecus.any((e) => e.answered);
}

/// Read-only UDS (ISO 14229) reads on 11-bit CAN. Only services 0x19 02 and 0x22 (identification DIDs) are sent.
/// Nothing is written, cleared or controlled. Only the standard OBD physical ids 7E0..7E7 are tried:
/// body/ABS/airbag modules on most cars use maker-specific ids that are not known here.
/// A car without CAN (e.g. a 2007 Hyundai Matrix) will not answer.
class UdsReadService {
  static const identDids = <String, String>{
    'F190': 'VIN',
    'F187': 'Part number',
    'F189': 'Software version',
    'F191': 'Hardware number',
    'F18C': 'Serial number',
  };

  static List<UdsDtc> parseDtcReport(List<int> bytes) {
    final out = <UdsDtc>[];
    for (var i = 0; i + 2 < bytes.length; i++) {
      if (bytes[i] == 0x59 && bytes[i + 1] == 0x02) {
        // 59 02 <availabilityMask> then 4-byte records: DTC hi, DTC lo, FTB, status
        var j = i + 3;
        while (j + 4 <= bytes.length) {
          final a = bytes[j], b = bytes[j + 1], c = bytes[j + 2], s = bytes[j + 3];
          out.add(UdsDtc(HexParser.decodeSingleDtc(a, b), c, s));
          j += 4;
        }
        break;
      }
    }
    return out;
  }

  static String? parseIdent(List<int> bytes, String did) {
    final hi = int.parse(did.substring(0, 2), radix: 16), lo = int.parse(did.substring(2), radix: 16);
    for (var i = 0; i + 2 < bytes.length; i++) {
      if (bytes[i] == 0x62 && bytes[i + 1] == hi && bytes[i + 2] == lo) {
        final data = bytes.sublist(i + 3).where((b) => b != 0x00).toList();
        if (data.isEmpty) return null;
        final printable = data.every((b) => b >= 0x20 && b < 0x7F);
        return printable
            ? String.fromCharCodes(data)
            : data.map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0')).join(' ');
      }
    }
    return null;
  }

  static bool _negative(List<int> bytes, int sid) {
    for (var i = 0; i + 2 < bytes.length; i++) {
      if (bytes[i] == 0x7F && bytes[i + 1] == sid) return true;
    }
    return false;
  }

  static Future<UdsReadReport> run(Elm327Driver d, {List<String> headers = const ['7E0', '7E1', '7E2', '7E3', '7E4', '7E5', '7E6', '7E7']}) async {
    final p = d.activeProtocol.toUpperCase();
    final isCan = p.contains('CAN') || p.contains('15765');
    if (!isCan) {
      return UdsReadReport(const [], 'UDS needs a CAN connection. This car is connected on "${d.activeProtocol}", so no UDS read was tried. Older cars (before about 2008) usually do not answer UDS.');
    }
    final ecus = <UdsEcuResult>[];
    for (final h in headers) {
      var answered = false;
      var dtcAnswered = false;
      var dtcs = <UdsDtc>[];
      final ident = <String, String>{};
      final notes = <String>[];
      final r19 = await d.sendToModule(h, '1902FF', timeout: const Duration(milliseconds: 1500));
      final b19 = HexParser.extractBytes(r19);
      if (r19 != 'TIMEOUT' && b19.isNotEmpty) {
        answered = true;
        if (_negative(b19, 0x19)) {
          notes.add('Service 19 refused (code 0x${b19.last.toRadixString(16).toUpperCase().padLeft(2, '0')}).');
        } else if (b19.contains(0x59)) {
          dtcAnswered = true;
          dtcs = parseDtcReport(b19);
        }
      }
      for (final e in identDids.entries) {
        final r = await d.sendToModule(h, '22${e.key}', timeout: const Duration(milliseconds: 1200));
        final b = HexParser.extractBytes(r);
        if (r == 'TIMEOUT' || b.isEmpty) continue;
        answered = true;
        final v = parseIdent(b, e.key);
        if (v != null) ident[e.value] = v;
      }
      ecus.add(UdsEcuResult(h, answered, dtcs, dtcAnswered, ident, notes.join(' ')));
      if (!answered && h == headers.first) {
        // keep scanning: engine id may be silent while others answer
      }
    }
    final note = ecus.any((e) => e.answered)
        ? 'Read-only. Only modules at the standard ids 7E0 to 7E7 were asked. Other modules (body, ABS, airbag) may use maker-specific ids that are not tried.'
        : 'No module answered UDS at 7E0 to 7E7. The car probably does not support UDS on these ids (normal for older cars), or the adapter cannot address them.';
    return UdsReadReport(ecus, note);
  }
}
