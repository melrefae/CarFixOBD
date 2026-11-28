import '../../core/utils/hex_parser.dart';
import '../../data/datasources/elm327_driver.dart';

/// Per-ECU Mode 01 capability map (real PID discovery).
///
/// Walks the SAE J1979 supported-PID bitmask chain (01 00, 01 20, 01 40, ...)
/// against ONE module addressed by its CAN header and returns only the PIDs the
/// module itself reported as supported. Nothing is invented here: an empty set
/// means the module did not report Mode 01 support (UDS-only modules, or no answer).
class EcuCapabilityService {
  static const List<int> _chainStarts = [0x00, 0x20, 0x40, 0x60, 0x80, 0xA0, 0xC0, 0xE0];

  /// [firstResponse] may carry an already-fetched raw reply to `01 00` for this
  /// header (from the module ping) so it is not asked twice.
  static Future<Set<String>> discoverForModule(
    Elm327Driver driver,
    String header, {
    String? firstResponse,
  }) async {
    final discovered = <String>{};
    String? raw = firstResponse;

    for (var i = 0; i < _chainStarts.length; i++) {
      final basePid = _chainStarts[i];
      raw ??= await driver.sendToModule(
        header,
        '01${basePid.toRadixString(16).toUpperCase().padLeft(2, '0')}',
        timeout: const Duration(milliseconds: 1200),
      );

      final chunk = parseChainResponse(raw, basePid);
      if (chunk == null) break;
      discovered.addAll(chunk);

      final nextIndex = i + 1;
      if (nextIndex >= _chainStarts.length) break;
      final nextPidHex = _chainStarts[nextIndex].toRadixString(16).toUpperCase().padLeft(2, '0');
      if (!chunk.contains(nextPidHex)) break; // continuation bit clear: no higher range
      raw = null; // fetch next chain step
    }
    return discovered;
  }

  /// Parses one chain-step response. Returns null when the module gave no usable
  /// answer (timeout, error text, negative response, or wrong/short payload).
  static Set<String>? parseChainResponse(String raw, int basePid) {
    if (raw == 'TIMEOUT' || HexParser.isErrorResponse(raw) || raw.contains('?')) return null;
    final bytes = HexParser.extractBytes(raw);
    if (bytes.length >= 2 && bytes[0] == 0x7F) return null; // UDS negative response
    final payload = HexParser.extractPayload(bytes, 0x01, basePid);
    if (payload.length < 4) return null;
    return HexParser.parseSupportedPidBitmask(payload.sublist(0, 4), basePid);
  }
}
