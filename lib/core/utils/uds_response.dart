/// Result of a UDS/OBD service request, evaluated from the raw adapter reply.
/// Nothing is assumed: a request counts as accepted only if the ECU answered
/// with the positive response for that service (request SID + 0x40).
enum UdsOutcome { positive, negative, noResponse, notConnected }

class UdsResult {
  final UdsOutcome outcome;
  final String raw;
  final String? nrc; // negative response code, hex, when outcome == negative

  const UdsResult(this.outcome, this.raw, [this.nrc]);

  bool get isPositive => outcome == UdsOutcome.positive;

  /// Evaluate [rawReply] for a request whose first byte (service id) is [requestSid].
  factory UdsResult.evaluate(String rawReply, int requestSid) {
    final raw = rawReply.trim();
    if (raw.startsWith('ERROR: Not connected')) {
      return UdsResult(UdsOutcome.notConnected, raw);
    }
    final hex = raw.toUpperCase().replaceAll(RegExp(r'[^0-9A-F]'), '');
    final posByte = (requestSid + 0x40).toRadixString(16).toUpperCase().padLeft(2, '0');
    final sidHex = requestSid.toRadixString(16).toUpperCase().padLeft(2, '0');
    if (hex.isEmpty ||
        raw.toUpperCase().contains('NO DATA') ||
        raw.toUpperCase().contains('UNABLE TO CONNECT') ||
        raw.toUpperCase().contains('TIMEOUT') ||
        raw.toUpperCase().contains('ERROR')) {
      return UdsResult(UdsOutcome.noResponse, raw);
    }
    final neg = '7F$sidHex';
    final negIdx = hex.indexOf(neg);
    if (negIdx >= 0 && hex.length >= negIdx + 6) {
      return UdsResult(UdsOutcome.negative, raw, hex.substring(negIdx + 4, negIdx + 6));
    }
    if (hex.contains(posByte)) return UdsResult(UdsOutcome.positive, raw);
    return UdsResult(UdsOutcome.noResponse, raw);
  }
}
