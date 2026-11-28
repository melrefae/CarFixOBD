import 'dart:async';
import 'dart:math';
import 'obd_connection.dart';

/// محاكي واقعي لسيارة ومحول ELM327 لتجربة وتطوير التطبيق بدون سيارة حقيقية
class MockObdConnection implements ObdConnection {
  final StreamController<String> _responseController = StreamController<String>.broadcast();
  bool _isConnected = false;
  Timer? _simulationTimer;
  double _timeTick = 0.0;

  // حالة السيارة في المحاكي
  bool _milOn = true;
  List<String> _storedDtcs = ["P0171", "P0300"];
  List<String> _pendingDtcs = ["P0133"];
  final List<String> _permanentDtcs = ["P0420"];
  String _activeHeader = "7DF";

  @override
  bool get isConnected => _isConnected;

  @override
  String get connectionType => "ECU Simulator";

  @override
  Stream<String> get responseStream => _responseController.stream;

  @override
  Future<bool> connect(String target) async {
    await disconnect();
    _isConnected = true;
    _startSimulatorLoop();
    return true;
  }

  void _startSimulatorLoop() {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _timeTick += 0.1;
    });
  }

  @override
  Future<void> send(String command) async {
    if (!_isConnected) {
      throw Exception("Simulator is disconnected");
    }

    final cmd = command.replaceAll('\r', '').trim().toUpperCase();

    // تأخير واقعي لمحاكاة زمن استجابة الـ CAN Bus (بين 20 إلى 40 ملي ثانية)
    await Future.delayed(const Duration(milliseconds: 30));

    String reply = "";

    if (cmd == "AT Z") {
      reply = "ELM327 v1.5 OBDII Simulator\r\r>";
    } else if (cmd.startsWith("AT E") ||
        cmd.startsWith("AT L") ||
        cmd.startsWith("AT S") ||
        cmd.startsWith("AT H") ||
        cmd.startsWith("AT SP") ||
        cmd.startsWith("AT AT") ||
        cmd.startsWith("AT ST") ||
        cmd.startsWith("AT CRA") ||
        cmd == "AT AR") {
      reply = "OK\r\r>";
    } else if (cmd == "AT RV") {
      // محاكاة فولت البطارية والشحن
      final v = 14.1 + 0.15 * sin(_timeTick);
      reply = "${v.toStringAsFixed(1)}V\r\r>";
    } else if (cmd == "AT DP" || cmd == "AT DPN") {
      reply = "ISO 15765-4 (CAN 11/500)\r\r>";
    } else if (cmd == "0100") {
      // الحساسات المدعومة
      reply = "41 00 BE 3F B8 13\r\r>";
    } else if (cmd == "0101" || cmd == "01 01") {
      // حالة لمبة الموتور Check Engine
      final milByte = _milOn ? "81" : "00";
      reply = "41 01 $milByte 07 65 04\r\r>";
    } else if (cmd.startsWith("010C") || cmd.startsWith("01 0C")) {
      // دوران المحرك RPM (محاكاة تسارع وتناقص واقعي بين 800 و 2600 دورة)
      final rpm = 850 + 700 * (1 + sin(_timeTick * 0.8));
      final raw = (rpm * 4).toInt();
      final a = (raw >> 8) & 0xFF;
      final b = raw & 0xFF;
      reply = "41 0C ${_toHex(a)} ${_toHex(b)}\r\r>";
    } else if (cmd.startsWith("010D") || cmd.startsWith("01 0D")) {
      // سرعة السيارة (0 إلى 65 كم/س)
      final speed = (30 + 25 * sin(_timeTick * 0.5)).clamp(0, 180).toInt();
      reply = "41 0D ${_toHex(speed)}\r\r>";
    } else if (cmd.startsWith("0105") || cmd.startsWith("01 05")) {
      // حرارة مياه التبريد (89°C)
      const tempC = 89;
      final a = tempC + 40;
      reply = "41 05 ${_toHex(a)}\r\r>";
    } else if (cmd.startsWith("0111") || cmd.startsWith("01 11")) {
      // فتحة البوابة TPS (15% إلى 45%)
      final tps = (18 + 12 * (1 + sin(_timeTick * 0.8))).toInt();
      final a = (tps * 255) ~/ 100;
      reply = "41 11 ${_toHex(a)}\r\r>";
    } else if (cmd.startsWith("0106") || cmd.startsWith("01 06")) {
      // STFT (+3.1% تصحيح لحظي)
      const trim = 3.1;
      final a = ((trim * 128 / 100) + 128).round();
      reply = "41 06 ${_toHex(a)}\r\r>";
    } else if (cmd.startsWith("0107") || cmd.startsWith("01 07")) {
      // LTFT (+17.5% دلالة على وجود تسريب فاكيوم خفيف)
      const trim = 17.5;
      final a = ((trim * 128 / 100) + 128).round();
      reply = "41 07 ${_toHex(a)}\r\r>";
    } else if (cmd.startsWith("010B") || cmd.startsWith("01 0B")) {
      // ضغط المانيفولد MAP (34 kPa)
      const mapVal = 34;
      reply = "41 0B ${_toHex(mapVal)}\r\r>";
    } else if (cmd.startsWith("0110") || cmd.startsWith("01 10")) {
      // تدفق الهواء MAF (3.25 g/s)
      const maf = 3.25;
      final raw = (maf * 100).toInt();
      final a = (raw >> 8) & 0xFF;
      final b = raw & 0xFF;
      reply = "41 10 ${_toHex(a)} ${_toHex(b)}\r\r>";
    } else if (cmd.startsWith("010F") || cmd.startsWith("01 0F")) {
      // حرارة الهواء الداخل IAT (32°C)
      const iat = 32;
      reply = "41 0F ${_toHex(iat + 40)}\r\r>";
    } else if (cmd.startsWith("0114") || cmd.startsWith("01 14")) {
      // حساس الشكمان الأول B1S1 (موجة متذبذبة سريعة بين 0.1V و 0.85V)
      final volt = 0.45 + 0.38 * sin(_timeTick * 3.0);
      final a = (volt * 200).toInt().clamp(0, 255);
      reply = "41 14 ${_toHex(a)} FF\r\r>";
    } else if (cmd.startsWith("0115") || cmd.startsWith("01 15")) {
      // حساس الشكمان الثاني B1S2 (قراءة هادئة وثابتة 0.65V دلالة على كفاءة العلبة)
      final volt = 0.65 + 0.04 * sin(_timeTick * 0.5);
      final a = (volt * 200).toInt().clamp(0, 255);
      reply = "41 15 ${_toHex(a)} FF\r\r>";
    } else if (cmd.startsWith("0142") || cmd.startsWith("01 42")) {
      // فولت الكونترول (14.05V)
      const raw = 14050;
      final a = (raw >> 8) & 0xFF;
      final b = raw & 0xFF;
      reply = "41 42 ${_toHex(a)} ${_toHex(b)}\r\r>";
    } else if (cmd == "03") {
      // قراءة الأعطال المسجلة Stored DTCs
      if (_storedDtcs.isEmpty) {
        reply = "43 00 00 00 00 00 00\r\r>";
      } else {
        // P0171 (01 71) و P0300 (03 00)
        reply = "43 01 71 03 00 00 00\r\r>";
      }
    } else if (cmd == "07") {
      // الأعطال المعلقة Pending
      if (_pendingDtcs.isEmpty) {
        reply = "47 00 00 00 00 00 00\r\r>";
      } else {
        reply = "47 01 33 00 00 00 00\r\r>"; // P0133
      }
    } else if (cmd == "0A") {
      // الأعطال الدائمة Permanent
      if (_permanentDtcs.isEmpty) {
        reply = "4A 00 00 00 00 00 00\r\r>";
      } else {
        reply = "4A 04 20 00 00 00 00\r\r>"; // P0420
      }
    } else if (cmd == "04") {
      // مسح أكواد الأعطال وتصفير اللمبة
      _storedDtcs = [];
      _pendingDtcs = [];
      _milOn = false;
      reply = "44\r\r>";
    } else if (cmd == "0902" || cmd == "09 02") {
      // رقم الشاسيه VIN (سيارة نيسان صني مصرية افتراضية)
      // NMAAA157K123456
      reply = "49 02 01 4E 4D 41 41 41 31 35 37 4B 31 32 33 34 35 36\r\r>";
    } else if (cmd == "0904" || cmd == "09 04") {
      // Calibration ID (CALID)
      // 23710-1KA0A
      reply = "49 04 01 32 33 37 31 30 2D 31 4B 41 30 41\r\r>";
    } else if (cmd == "0906" || cmd == "09 06") {
      // Calibration Verification Number (CVN)
      // ABCD1234
      reply = "49 06 01 41 42 43 44 31 32 33 34\r\r>";
    } else if (cmd == "090A" || cmd == "09 0A") {
      // ECU Name
      reply = "49 0A 01 45 4E 47 49 4E 45 20 43 4F 4E 54 52 4F 4C\r\r>";
    } else if (cmd.startsWith("0202") || cmd.startsWith("02 02")) {
      // Freeze Frame DTC (P0171)
      reply = "42 02 01 71\r\r>";
    } else if (cmd.startsWith("020C") || cmd.startsWith("02 0C")) {
      // Freeze Frame RPM (1125 RPM)
      reply = "42 0C 11 94\r\r>";
    } else if (cmd.startsWith("020D") || cmd.startsWith("02 0D")) {
      // Freeze Frame Speed (45 km/h)
      reply = "42 0D 2D\r\r>";
    } else if (cmd.startsWith("0205") || cmd.startsWith("02 05")) {
      // Freeze Frame Coolant Temp (92 °C)
      reply = "42 05 84\r\r>";
    } else if (cmd.startsWith("0204") || cmd.startsWith("02 04")) {
      // Freeze Frame Engine Load (37.6 %)
      reply = "42 04 60\r\r>";
    } else if (cmd.startsWith("0211") || cmd.startsWith("02 11")) {
      // Freeze Frame Throttle (22 %)
      reply = "42 11 38\r\r>";
    } else if (cmd.startsWith("020F") || cmd.startsWith("02 0F")) {
      // Freeze Frame IAT (30 °C)
      reply = "42 0F 46\r\r>";
    } else if (cmd.startsWith("020B") || cmd.startsWith("02 0B")) {
      // Freeze Frame MAP (40 kPa)
      reply = "42 0B 28\r\r>";
    } else if (cmd.startsWith("0206") || cmd.startsWith("02 06")) {
      // Freeze Frame STFT (+6.2 %)
      reply = "42 06 88\r\r>";
    } else if (cmd.startsWith("0207") || cmd.startsWith("02 07")) {
      // Freeze Frame LTFT (+25.0 %)
      reply = "42 07 A0\r\r>";
    } else if (cmd.startsWith("AT SH")) {
      final parts = cmd.split(" ");
      if (parts.length >= 3) {
        _activeHeader = parts[2];
      }
      reply = "OK\r\r>";
    } else if (cmd.startsWith("31")) {
      // UDS RoutineControl (Diagzone Pro 16 Special Resets)
      reply = "71 01 02 OK\r\r>";
    } else if (cmd.startsWith("2F")) {
      // UDS InputOutputControlByIdentifier (Bi-directional Actuator Tests)
      reply = "6F 01 10 OK\r\r>";
    } else if (cmd.startsWith("08")) {
      // Mode 08 Request Control of On-Board Component
      reply = "48 01 00\r\r>";
    } else if (cmd == "0600" || cmd == "06 00") {
      // Mode 06 Supported MIDs bitmask (MIDs 01, 02, 21, 3A, A1-A5)
      reply = "46 00 C0 00 00 01\r\r>";
    } else if (cmd == "0620" || cmd == "06 20") {
      reply = "46 20 80 00 00 41\r\r>";
    } else if (cmd == "0640" || cmd == "06 40") {
      reply = "46 40 00 00 00 01\r\r>";
    } else if (cmd == "0660" || cmd == "06 60") {
      reply = "46 60 00 00 00 01\r\r>";
    } else if (cmd == "0680" || cmd == "06 80") {
      reply = "46 80 00 00 00 01\r\r>";
    } else if (cmd == "06A0" || cmd == "06 A0") {
      reply = "46 A0 F8 00 00 00\r\r>";
    } else if (cmd == "0601" || cmd == "06 01") {
      // O2 Sensor Bank 1 Sensor 1 Rich-to-Lean Voltage Threshold (MID 01, TID 01, UASID 0A = mV)
      reply = "46 01 01 0A 01 90 00 64 03 E8\r\r>";
    } else if (cmd == "0602" || cmd == "06 02") {
      // O2 Sensor Bank 1 Sensor 2 Lean-to-Rich Threshold (MID 02, TID 01, UASID 0A = mV)
      reply = "46 02 01 0A 01 C2 00 64 03 E8\r\r>";
    } else if (cmd == "0621" || cmd == "06 21") {
      // Catalyst Monitor Bank 1 Efficiency Index (MID 21, TID 80, UASID 10 = ms/index)
      reply = "46 21 80 10 00 B4 00 64 03 E8\r\r>";
    } else if (cmd == "063A" || cmd == "06 3A") {
      // EVAP Purge Flow Monitor (MID 3A, TID 01, UASID 24 = counts)
      reply = "46 3A 01 24 00 05 00 00 00 32\r\r>";
    } else if (cmd == "06A1" || cmd == "06 A1") {
      // Total Misfire Data (MID A1, TID 0C, UASID 24 = counts)
      reply = "46 A1 0C 24 00 02 00 00 00 32\r\r>";
    } else if (cmd == "06A2" || cmd == "06 A2") {
      // Cylinder 1 Misfire Monitor (MID A2, TID 0B, UASID 24, Val: 0, Max: 25)
      reply = "46 A2 0B 24 00 00 00 00 00 19\r\r>";
    } else if (cmd == "06A3" || cmd == "06 A3") {
      // Cylinder 2 Misfire Monitor (MID A3, TID 0B, UASID 24, Val: 1, Max: 25)
      reply = "46 A3 0B 24 00 01 00 00 00 19\r\r>";
    } else if (cmd == "06A4" || cmd == "06 A4") {
      // Cylinder 3 Misfire Monitor (MID A4, TID 0B, UASID 24, Val: 0, Max: 25)
      reply = "46 A4 0B 24 00 00 00 00 00 19\r\r>";
    } else if (cmd == "06A5" || cmd == "06 A5") {
      // Cylinder 4 Misfire Monitor (MID A5, TID 0B, UASID 24, Val: 1, Max: 25)
      reply = "46 A5 0B 24 00 01 00 00 00 19\r\r>";
    } else if (cmd.startsWith("06")) {
      // Unsupported Mode 06 MID returns standard NO DATA
      reply = "NO DATA\r\r>";
    } else if (cmd.startsWith("0132") || cmd.startsWith("01 32")) {
      // EVAP Vapor Pressure (0.00 kPa / 0 Pa)
      reply = "41 32 80 00\r\r>";
    } else if (cmd.startsWith("012E") || cmd.startsWith("01 2E")) {
      // Commanded Evaporative Purge (0.0%)
      reply = "41 2E 00\r\r>";
    } else if (cmd.startsWith("22 11 05") || cmd == "221105") {
      // UDS: Transmission Fluid Temperature (82°C -> 0x52)
      reply = "62 11 05 52\r\r>";
    } else if (cmd.startsWith("22 11 06") || cmd == "221106") {
      // UDS: Torque Converter Slip (15 RPM)
      reply = "62 11 06 00 0F\r\r>";
    } else if (cmd.startsWith("22 2B 01") || cmd == "222B01") {
      // UDS: 4-Wheel Speed Sensor Sweep (0, 0, 0, 0 km/h)
      reply = "62 2B 01 00 00 00 00\r\r>";
    } else if (cmd.startsWith("22 2B 02") || cmd == "222B02") {
      // UDS: Steering Angle Sensor SAS (0.0 deg)
      reply = "62 2B 02 00 00\r\r>";
    } else if (cmd.startsWith("22 3C 01") || cmd == "223C01") {
      // UDS: SRS Airbag Squib Loop Resistance (Driver: 2.4Ω, Pass: 2.6Ω, Curtain: 2.5Ω)
      reply = "62 3C 01 18 1A 19\r\r>";
    } else if (cmd.startsWith("22 4D 01") || cmd == "224D01") {
      // UDS: HVAC A/C Refrigerant High Side Pressure (11.5 Bar / 1150 kPa)
      reply = "62 4D 01 04 7E\r\r>";
    } else if (cmd.startsWith("22 5E 01") || cmd == "225E01") {
      // UDS: EPS Electric Power Steering Motor Torque (0.0 Nm)
      reply = "62 5E 01 00 00\r\r>";

    } else if (_activeHeader == "7E1" && (cmd == "0100" || cmd == "01 00")) {
      // Transmission Module Ping
      reply = "41 00 BE 3E B8 11\r\r>";
    } else if (_activeHeader == "7E1" && cmd == "03") {
      // Transmission DTCs (P0700 Transmission Control Malfunction)
      reply = "43 07 00 00 00 00 00\r\r>";
    } else if (_activeHeader == "7E2" && (cmd == "0100" || cmd == "01 00")) {
      // ABS Module Ping
      reply = "41 00 80 00 00 00\r\r>";
    } else if (_activeHeader == "7E2" && cmd == "03") {
      // ABS DTCs (Clean / No faults)
      reply = "43 00 00 00 00 00 00\r\r>";
    } else if (_activeHeader == "7E3" && (cmd == "0100" || cmd == "01 00")) {
      // Airbag (SRS) Module Ping
      reply = "41 00 80 00 00 00\r\r>";
    } else if (_activeHeader == "7E3" && cmd == "03") {
      // SRS DTCs (Clean)
      reply = "43 00 00 00 00 00 00\r\r>";
    } else if (_activeHeader == "7E4" && (cmd == "0100" || cmd == "01 00")) {
      // Body Control Module (BCM) Ping
      reply = "41 00 80 00 00 00\r\r>";
    } else if (_activeHeader == "7E4" && cmd == "03") {
      // BCM DTCs (Clean)
      reply = "43 00 00 00 00 00 00\r\r>";
    } else {
      reply = "NO DATA\r\r>";
    }

    _responseController.add(reply);
  }

  String _toHex(int val) {
    return val.toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  @override
  Future<void> disconnect() async {
    _simulationTimer?.cancel();
    _simulationTimer = null;
    _isConnected = false;
  }
}
