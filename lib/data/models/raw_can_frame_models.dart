/// Models for Raw OBD-II CAN Bus Protocol Packet Sniffer
class RawCanFrame {
  final int timestampMs;
  final int arbitrationId;
  final int dlc;
  final List<int> payloadBytes;
  final bool isExtended;
  final String ecuName;
  final String decodedInterpretation;

  const RawCanFrame({
    required this.timestampMs,
    required this.arbitrationId,
    required this.dlc,
    required this.payloadBytes,
    this.isExtended = false,
    required this.ecuName,
    required this.decodedInterpretation,
  });

  String get hexId =>
      '0x${arbitrationId.toRadixString(16).toUpperCase().padLeft(isExtended ? 8 : 3, '0')}';

  String get hexPayload => payloadBytes
      .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
      .join(' ');

  String get asciiPayload => payloadBytes
      .map((b) => (b >= 32 && b <= 126) ? String.fromCharCode(b) : '.')
      .join('');

  /// Factory parser for ELM327 CAN monitor strings (e.g., "7E8 04 41 0C 1A F8 00 00")
  factory RawCanFrame.parseElmLine(String line, int timestamp) {
    final cleaned = line.trim().replaceAll(RegExp(r'\s+'), ' ');
    final parts = cleaned.split(' ');
    if (parts.isEmpty) {
      return RawCanFrame(
        timestampMs: timestamp,
        arbitrationId: 0x7E8,
        dlc: 8,
        payloadBytes: List.filled(8, 0),
        ecuName: "ECM",
        decodedInterpretation: "Empty Frame",
      );
    }

    final id = int.tryParse(parts[0], radix: 16) ?? 0x7E8;
    final bytes = <int>[];
    for (int i = 1; i < parts.length && bytes.length < 8; i++) {
      final b = int.tryParse(parts[i], radix: 16);
      if (b != null) bytes.add(b);
    }
    while (bytes.length < 8) {
      bytes.add(0);
    }

    final ecu = _identifyEcu(id);
    final decode = _decodePayload(bytes);

    return RawCanFrame(
      timestampMs: timestamp,
      arbitrationId: id,
      dlc: bytes.length,
      payloadBytes: bytes,
      isExtended: id > 0x7FF,
      ecuName: ecu,
      decodedInterpretation: decode,
    );
  }

  static String _identifyEcu(int id) {
    if (id == 0x7E0 || id == 0x7E8) return "Engine ECM";
    if (id == 0x7E1 || id == 0x7E9) return "Transmission TCU";
    if (id == 0x7E2 || id == 0x7EA) return "ABS / ESC Module";
    if (id == 0x7E3 || id == 0x7EB) return "Airbag SRS";
    if (id == 0x7E4 || id == 0x7EC) return "Body Control (BCM)";
    if (id == 0x7E5 || id == 0x7ED) return "Instrument Cluster (IPC)";
    if (id == 0x7E6 || id == 0x7EE) return "Radar / ADAS Camera";
    return "CAN Node (0x${id.toRadixString(16).toUpperCase()})";
  }

  static String _decodePayload(List<int> bytes) {
    if (bytes.length < 3) return "Raw Data";
    final mode = bytes[1];
    final pid = bytes[2];

    if (mode == 0x41) {
      // Mode 01 Live Telemetry Response
      if (pid == 0x0C && bytes.length >= 5) {
        final rpm = ((bytes[3] * 256) + bytes[4]) / 4.0;
        return "Engine RPM: ${rpm.toStringAsFixed(0)} rpm";
      }
      if (pid == 0x0D && bytes.length >= 4) {
        return "Vehicle Speed: ${bytes[3]} km/h";
      }
      if (pid == 0x05 && bytes.length >= 4) {
        return "Coolant Temp: ${bytes[3] - 40} deg C";
      }
      if (pid == 0x11 && bytes.length >= 4) {
        return "Throttle: ${(bytes[3] * 100 / 255).toStringAsFixed(1)} %";
      }
      if (pid == 0x10 && bytes.length >= 5) {
        final maf = ((bytes[3] * 256) + bytes[4]) / 100.0;
        return "MAF Flow: ${maf.toStringAsFixed(2)} g/s";
      }
      if (pid == 0x01 && bytes.length >= 4) {
        final mil = (bytes[3] & 0x80) != 0;
        final dtcCount = bytes[3] & 0x7F;
        return "Status: MIL ${mil ? 'ON' : 'OFF'}, $dtcCount DTCs";
      }
      return "Mode 01 PID 0x${pid.toRadixString(16).toUpperCase()} Response";
    }

    if (mode == 0x43) {
      return "Mode 03 Stored DTC Query Response";
    }

    if (mode == 0x47) {
      return "Mode 07 Pending DTC Query Response";
    }

    if (mode == 0x49) {
      return "Mode 09 Vehicle Identification Data (VIN/Calibration)";
    }

    return "Raw Frame (${bytes.length} bytes)";
  }

  static List<RawCanFrame> sampleLiveCanStream = [
    RawCanFrame(
      timestampMs: 1042,
      arbitrationId: 0x7E8,
      dlc: 8,
      payloadBytes: [0x04, 0x41, 0x0C, 0x0B, 0xB8, 0x00, 0x00, 0x00],
      ecuName: "Engine ECM",
      decodedInterpretation: "Engine RPM: 750 rpm (Warm Idle)",
    ),
    RawCanFrame(
      timestampMs: 1064,
      arbitrationId: 0x7E8,
      dlc: 8,
      payloadBytes: [0x03, 0x41, 0x0D, 0x00, 0x00, 0x00, 0x00, 0x00],
      ecuName: "Engine ECM",
      decodedInterpretation: "Vehicle Speed: 0 km/h",
    ),
    RawCanFrame(
      timestampMs: 1088,
      arbitrationId: 0x7E8,
      dlc: 8,
      payloadBytes: [0x03, 0x41, 0x05, 0x82, 0x00, 0x00, 0x00, 0x00],
      ecuName: "Engine ECM",
      decodedInterpretation: "Coolant Temp: 90 deg C (Nominal)",
    ),
    RawCanFrame(
      timestampMs: 1120,
      arbitrationId: 0x7E9,
      dlc: 8,
      payloadBytes: [0x04, 0x41, 0xB2, 0x03, 0x54, 0x00, 0x00, 0x00],
      ecuName: "Transmission TCU",
      decodedInterpretation: "ATF Fluid Temp: 85 deg C | Gear: P",
    ),
    RawCanFrame(
      timestampMs: 1152,
      arbitrationId: 0x7EA,
      dlc: 8,
      payloadBytes: [0x08, 0x22, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00],
      ecuName: "ABS / ESC Module",
      decodedInterpretation: "Wheel Speeds: FL:0 FR:0 RL:0 RR:0 km/h",
    ),
  ];
}

class CanSnifferFilter {
  final int? targetArbitrationId;
  final String? ecuFilter;
  final String? hexSearch;

  const CanSnifferFilter({
    this.targetArbitrationId,
    this.ecuFilter,
    this.hexSearch,
  });

  bool matches(RawCanFrame frame) {
    if (targetArbitrationId != null && frame.arbitrationId != targetArbitrationId) {
      return false;
    }
    if (ecuFilter != null && ecuFilter!.isNotEmpty) {
      if (!frame.ecuName.toLowerCase().contains(ecuFilter!.toLowerCase())) {
        return false;
      }
    }
    if (hexSearch != null && hexSearch!.isNotEmpty) {
      final clean = hexSearch!.replaceAll(' ', '').toUpperCase();
      final frameHex = frame.payloadBytes
          .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
          .join('');
      if (!frameHex.contains(clean)) return false;
    }
    return true;
  }
}
