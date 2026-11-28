/// Scaling and names for OBD-II Mode 05 / Mode 06 test results.
/// Source: SAE J1979 (2006 edition, ISO 15031-5) Annex C (TID scaling for Mode 05),
/// Annex D (OBDMID names) and Annex E (Unit and Scaling IDs, Mode 06, CAN only).
/// Only IDs printed in that standard are listed. An unknown ID is shown as raw, never converted.
class Uas {
  final double scale;
  final String unit;
  final bool signed;
  final double offset;
  const Uas(this.scale, this.unit, {this.signed = false, this.offset = 0});
}

const Map<int, Uas> kUasTable = {
  0x01: Uas(1, ''),
  0x02: Uas(0.1, ''),
  0x03: Uas(0.01, ''),
  0x04: Uas(0.001, ''),
  0x05: Uas(0.0000305, ''),
  0x06: Uas(0.000305, ''),
  0x07: Uas(0.25, 'rpm'),
  0x08: Uas(0.01, 'km/h'),
  0x09: Uas(1, 'km/h'),
  0x0A: Uas(0.122, 'mV'),
  0x0B: Uas(0.001, 'V'),
  0x0C: Uas(0.01, 'V'),
  0x0D: Uas(0.00390625, 'mA'),
  0x0E: Uas(0.001, 'A'),
  0x0F: Uas(0.01, 'A'),
  0x10: Uas(1, 'ms'),
  0x11: Uas(0.1, 's'),
  0x12: Uas(1, 's'),
  0x13: Uas(1, 'mOhm'),
  0x14: Uas(1, 'Ohm'),
  0x15: Uas(1, 'kOhm'),
  0x16: Uas(0.1, '°C', offset: -40),
  0x17: Uas(0.01, 'kPa'),
  0x18: Uas(0.0117, 'kPa'),
  0x19: Uas(0.079, 'kPa'),
  0x1A: Uas(1, 'kPa'),
  0x1B: Uas(10, 'kPa'),
  0x1C: Uas(0.01, '°'),
  0x1D: Uas(0.5, '°'),
  0x1E: Uas(0.0000305, 'lambda'),
  0x1F: Uas(0.05, 'A/F'),
  0x20: Uas(0.0039062, ''),
  0x21: Uas(0.001, 'Hz'),
  0x22: Uas(1, 'Hz'),
  0x23: Uas(1, 'kHz'),
  0x24: Uas(1, 'counts'),
  0x25: Uas(1, 'km'),
  0x26: Uas(0.1, 'mV/ms'),
  0x27: Uas(0.01, 'g/s'),
  0x28: Uas(1, 'g/s'),
  0x29: Uas(0.25, 'Pa/s'),
  0x2A: Uas(0.001, 'kg/h'),
  0x2B: Uas(1, 'switches'),
  0x2C: Uas(0.01, 'g/cyl'),
  0x2D: Uas(0.01, 'mg/stroke'),
  0x2E: Uas(1, ''), // true/false: 0 = false, 1 = true
  0x2F: Uas(0.01, '%'),
  0x30: Uas(0.001526, '%'),
  0x31: Uas(0.001, 'L'),
  0x32: Uas(0.0000305, 'inch'),
  0x33: Uas(0.00024414, 'lambda'),
  0x34: Uas(1, 'min'),
  0x35: Uas(10, 'ms'),
  0x36: Uas(0.01, 'g'),
  0x37: Uas(0.1, 'g'),
  0x38: Uas(1, 'g'),
  0x39: Uas(0.01, '%', signed: true),
  0x81: Uas(1, '', signed: true),
  0x82: Uas(0.1, '', signed: true),
  0x83: Uas(0.01, '', signed: true),
  0x84: Uas(0.001, '', signed: true),
  0x85: Uas(0.0000305, '', signed: true),
  0x86: Uas(0.000305, '', signed: true),
  0x8A: Uas(0.122, 'mV', signed: true),
  0x8B: Uas(0.001, 'V', signed: true),
  0x8C: Uas(0.01, 'V', signed: true),
  0x8D: Uas(0.00390625, 'mA', signed: true),
  0x8E: Uas(0.001, 'A', signed: true),
  0x90: Uas(1, 'ms', signed: true),
  0x96: Uas(0.1, '°C', signed: true),
  0x9C: Uas(0.01, '°', signed: true),
  0x9D: Uas(0.5, '°', signed: true),
  0xA8: Uas(1, 'g/s', signed: true),
  0xA9: Uas(0.25, 'Pa/s', signed: true),
  0xAF: Uas(0.01, '%', signed: true),
  0xB0: Uas(0.003052, '%', signed: true),
  0xB1: Uas(2, 'mV/s', signed: true),
  0xFD: Uas(0.001, 'kPa', signed: true),
  0xFE: Uas(0.25, 'Pa', signed: true),
};

/// Convert a 16-bit Mode 06 field with its UASID. Returns null when the UASID is not in the standard table.
double? uasConvert(int uasid, int raw16) {
  final u = kUasTable[uasid];
  if (u == null) return null;
  var v = raw16;
  if (u.signed && (raw16 & 0x8000) != 0) v = raw16 - 0x10000;
  return v * u.scale + u.offset;
}

String uasUnit(int uasid) => kUasTable[uasid]?.unit ?? '';

/// OBDMID names (SAE J1979 Annex D, CAN only).
String mode06MidName(int mid) {
  String s(int base, String prefix, {int perBank = 4}) {
    final idx = mid - base;
    return '$prefix Bank ${idx ~/ perBank + 1} - Sensor ${idx % perBank + 1}';
  }
  if (mid >= 0x01 && mid <= 0x10) return s(0x01, 'Oxygen sensor monitor');
  if (mid >= 0x21 && mid <= 0x24) return 'Catalyst monitor Bank ${mid - 0x20}';
  if (mid >= 0x31 && mid <= 0x34) return 'EGR monitor Bank ${mid - 0x30}';
  if (mid >= 0x35 && mid <= 0x38) return 'VVT monitor Bank ${mid - 0x34}';
  if (mid == 0x39) return 'EVAP monitor (cap off / 0.150")';
  if (mid == 0x3A) return 'EVAP monitor (0.090")';
  if (mid == 0x3B) return 'EVAP monitor (0.040")';
  if (mid == 0x3C) return 'EVAP monitor (0.020")';
  if (mid == 0x3D) return 'Purge flow monitor';
  if (mid >= 0x41 && mid <= 0x50) return s(0x41, 'Oxygen sensor heater monitor');
  if (mid >= 0x61 && mid <= 0x64) return 'Heated catalyst monitor Bank ${mid - 0x60}';
  if (mid >= 0x71 && mid <= 0x74) return 'Secondary air monitor ${mid - 0x70}';
  if (mid >= 0x81 && mid <= 0x84) return 'Fuel system monitor Bank ${mid - 0x80}';
  if (mid == 0x85 || mid == 0x86) return 'Boost pressure control monitor Bank ${mid - 0x84}';
  if (mid == 0x90 || mid == 0x91) return 'NOx adsorber monitor Bank ${mid - 0x8F}';
  if (mid == 0x98 || mid == 0x99) return 'NOx catalyst monitor Bank ${mid - 0x97}';
  if (mid == 0xA1) return 'Misfire monitor, general data';
  if (mid >= 0xA2 && mid <= 0xAD) return 'Misfire cylinder ${mid - 0xA1}';
  if (mid == 0xB0 || mid == 0xB1) return 'PM filter monitor Bank ${mid - 0xAF}';
  if (mid >= 0xE1) return 'Manufacturer-defined monitor 0x${mid.toRadixString(16).toUpperCase()}';
  return 'Monitor 0x${mid.toRadixString(16).toUpperCase().padLeft(2, '0')}';
}

/// Standardized TID names for Mode 06 (J1979 Table 161) and Mode 05 (same TIDs 01-0A).
String standardTidName(int tid) {
  switch (tid) {
    case 0x01: return 'Rich to lean sensor threshold voltage';
    case 0x02: return 'Lean to rich sensor threshold voltage';
    case 0x03: return 'Low sensor voltage for switch time calculation';
    case 0x04: return 'High sensor voltage for switch time calculation';
    case 0x05: return 'Rich to lean sensor switch time';
    case 0x06: return 'Lean to rich sensor switch time';
    case 0x07: return 'Minimum sensor voltage for test cycle';
    case 0x08: return 'Maximum sensor voltage for test cycle';
    case 0x09: return 'Time between sensor transitions';
    case 0x0A: return 'Sensor period';
    case 0x0B: return 'Misfire counts, average of last 10 drive cycles';
    case 0x0C: return 'Misfire counts, last/current drive cycle';
  }
  return tid >= 0x80
      ? 'Manufacturer test 0x${tid.toRadixString(16).toUpperCase()} (name is in the maker\'s service data)'
      : 'Test 0x${tid.toRadixString(16).toUpperCase().padLeft(2, '0')}';
}

/// Mode 05 (non-CAN) scaling per TID, J1979 Annex C. Returns (scale, unit) or null if not standardized.
(double, String)? mode05Scale(int tid) {
  if (tid >= 0x01 && tid <= 0x04) return (0.005, 'V');
  if (tid == 0x05 || tid == 0x06) return (0.004, 's');
  if (tid == 0x07 || tid == 0x08) return (0.005, 'V');
  if (tid == 0x09 || tid == 0x0A) return (0.04, 's');
  if (tid >= 0x21 && tid <= 0x2F) return (0.004, 's');
  if (tid >= 0x30 && tid <= 0x3F) return (0.04, 's');
  if (tid >= 0x41 && tid <= 0x4F) return (0.005, 'V');
  if (tid >= 0x50 && tid <= 0x5F) return (0.05, 'V');
  if (tid >= 0x61 && tid <= 0x6F) return (0.1, 'Hz');
  if (tid >= 0x70 && tid <= 0x7F) return (1, 'counts');
  return null;
}

/// O2 sensor location from the Mode 05 sensor byte (one bit set), J1979 Table 61 (first column, PID 13).
String o2SensorName(int bit) {
  for (var i = 0; i < 8; i++) {
    if (bit & (1 << i) != 0) return 'B${i ~/ 4 + 1}S${i % 4 + 1}';
  }
  return 'sensor 0x${bit.toRadixString(16)}';
}
