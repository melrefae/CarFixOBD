/// تعريفات أوامر ELM327 وأوضاع تشخيص OBD-II القياسية (SAE J1979)
class ObdCommands {
  // --- أوامر تهيئة محول ELM327 (AT Commands) ---
  static const String reset = "AT Z";
  static const String echoOff = "AT E0";
  static const String linefeedsOff = "AT L0";
  static const String spacesOff = "AT S0";
  static const String headersOff = "AT H0";
  static const String headersOn = "AT H1";
  static const String autoProtocol = "AT SP 0";
  static const String readVoltage = "AT RV";
  static const String readProtocol = "AT DP";
  static const String readProtocolNumber = "AT DPN";
  static const String readVersion = "AT I";
  static const String timeoutMax = "AT ST FF";
  static const String adaptiveTimingOn = "AT AT 1";

  // --- أوضاع التشخيص الأساسية (OBD Modes / Services) ---
  /// Mode 01: قراءة البيانات اللحظية الحية (Live Data / Sensor Readings)
  static const String modeCurrentData = "01";

  /// Mode 02: قراءة لقطة الحساسات عند تسجيل العطل (Freeze Frame)
  static const String modeFreezeFrame = "02";

  /// Mode 03: قراءة أكواد الأعطال المسجلة المؤكدة (Stored DTCs)
  static const String modeStoredDtcs = "03";

  /// Mode 04: مسح أكواد الأعطال وتصفير لمبة Check Engine والبيانات المخزنة
  static const String modeClearDtcs = "04";

  /// Mode 06: اختبارات المراقبة الميدانية غير المستمرة (Misfire & Component Tests)
  static const String modeOnBoardMonitoring = "06";

  /// Mode 07: قراءة أكواد الأعطال المعلقة غير المؤكدة (Pending DTCs)
  static const String modePendingDtcs = "07";

  /// Mode 09: قراءة معلومات السيارة (VIN, CALID, CVN)
  static const String modeVehicleInfo = "09";

  /// Mode 0A: قراءة أكواد الأعطال الدائمة (Permanent DTCs - لا تمسح إلا بعد دورة قيادة)
  static const String modePermanentDtcs = "0A";

  // --- معرفات PIDs القياسية في Mode 01 ---
  static const String pidSupportedPids01_20 = "00";
  static const String pidMonitorStatus = "01"; // لمبة الأعطال واختبارات الجاهزية
  static const String pidDtcCausedFreezeFrame = "02";
  static const String pidFuelSystemStatus = "03";
  static const String pidCalculatedEngineLoad = "04";
  static const String pidEngineCoolantTemp = "05";
  static const String pidShortTermFuelTrimB1 = "06";
  static const String pidLongTermFuelTrimB1 = "07";
  static const String pidShortTermFuelTrimB2 = "08";
  static const String pidLongTermFuelTrimB2 = "09";
  static const String pidFuelPressure = "0A";
  static const String pidIntakeManifoldPressure = "0B"; // MAP Sensor
  static const String pidEngineRpm = "0C";
  static const String pidVehicleSpeed = "0D";
  static const String pidTimingAdvance = "0E";
  static const String pidIntakeAirTemp = "0F"; // IAT
  static const String pidMafAirFlowRate = "10"; // MAF
  static const String pidThrottlePosition = "11"; // TPS
  static const String pidOxygenSensor1Voltage = "14"; // O2 B1S1
  static const String pidOxygenSensor2Voltage = "15"; // O2 B1S2
  static const String pidControlModuleVoltage = "42"; // فولت الكونترول اللحظي
  static const String pidAmbientAirTemp = "46";
  static const String pidFuelRailPressure = "23";

  // --- معرفات PIDs في Mode 09 (Vehicle Info) ---
  static const String pidVin = "02"; // رقم الشاسيه (Vehicle Identification Number)
  static const String pidCalId = "04"; // رقم المعايرة والبرمجة (Calibration ID)
  static const String pidCvn = "06"; // كود تحقق المعايرة (Calibration Verification Number)
  static const String pidEcuName = "0A"; // اسم كونترول الماكينة
}
