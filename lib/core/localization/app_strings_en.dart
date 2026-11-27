/// Comprehensive English localization for AutoSpect OBD2 diagnostic application
class AppStrings {
  // Application branding
  static const String appName = "AutoSpect";
  static const String appSubtitle = "Professional OBD2 Diagnostic System";
  static const String appTagline = "Professional Vehicle Diagnostics & ECU Analysis";
  static const String defaultWorkshopName = "AutoSpect Diagnostic Center";
  static const String defaultWorkshopPhone = "+201553666635";
  static const String defaultWorkshopAddress = "";

  // Navigation & Primary Actions
  static const String quickScan = "Quick Scan (30s)";
  static const String readDtcs = "Diagnostic Codes (DTCs)";
  static const String dtcEncyclopedia = "DTC Encyclopedia";
  static const String liveSensors = "Live Sensors";
  static const String liveGraphs = "Live Waveforms (Graphs)";
  static const String freezeFrame = "Freeze Frame Data";
  static const String fuelTrimAnalysis = "Fuel Trim & Vacuum Analysis";
  static const String batteryTest = "Battery & Cranking Test";
  static const String adapterBenchmark = "Adapter Benchmark";
  static const String vehicleProfiles = "Egyptian Vehicle Profiles";
  static const String inspectionReports = "Inspection Reports";
  static const String terminal = "ELM327 Terminal";
  static const String settings = "Center & Alarm Settings";

  // Connection & Hardware States
  static const String connectionTitle = "ELM327 Connection Manager";
  static const String connected = "Connected to ECU";
  static const String adapterOnlyConnected = "Adapter Ready (Turn Key to ON/RUN)";
  static const String connecting = "Connecting to OBD Adapter...";
  static const String disconnected = "Disconnected";
  static const String simulationMode = "Simulator Mode (No Vehicle)";
  static const String switchMode = "Switch Adapter";
  static const String disconnect = "Disconnect";
  static const String connect = "Connect";
  static const String autoDetect = "Auto Detect & Connect";
  static const String autoDetectSubtitle = "Automatically find & connect to any Bluetooth OBD adapter";
  static const String scanningBluetooth = "Scanning for Bluetooth OBD adapters...";
  static const String pairedDevices = "Paired Devices (OS Settings)";
  static const String discoveredDevices = "Nearby Discovered Devices";
  static const String noPairedDevices = "No paired Bluetooth devices found";
  static const String pairDevicePrompt = "Make sure your OBD-II adapter is plugged into the vehicle's OBD port and paired in Bluetooth settings (PIN usually 1234 or 0000).";
  static const String obdCandidate = "OBD-II Device";
  static const String unknownDevice = "Generic Device";

  // Wi-Fi Connection
  static const String wifiTab = "Wi-Fi";
  static const String wifiSettingsTitle = "ELM327 Wi-Fi Configuration:";
  static const String wifiDescription = "Most Wi-Fi OBD adapters in Egypt broadcast an SSID named 'WiFi_OBDII' and use default IP 192.168.0.10 on port 35000.";
  static const String adapterAddressLabel = "Adapter Address (IP:Port)";
  static const String connectWifi = "Connect via Wi-Fi";

  // Simulator
  static const String simulatorTab = "ECU Simulator";
  static const String simulatorTitle = "Integrated Realistic ECU Simulator";
  static const String simulatorDescription = "Enables testing of all diagnostic features (Live PIDs, Waveforms, DTC reading & clearing, and Battery Tests) without needing a physical OBD adapter or vehicle.";
  static const String startSimulator = "Launch Simulator Mode";

  // Diagnostic Trouble Codes
  static const String storedDtcs = "Confirmed Trouble Codes (Mode 03)";
  static const String pendingDtcs = "Pending Trouble Codes (Mode 07)";
  static const String permanentDtcs = "Permanent Trouble Codes (Mode 0A)";
  static const String noDtcsFound = "No trouble codes found. ECU reports healthy status!";
  static const String clearDtcsButton = "Clear Trouble Codes & Reset MIL (Mode 04)";
  static const String clearWarningTitle = "Important Safety Confirmation";
  static const String clearWarningBody = "Ensure the engine is completely stopped with ignition key ON (Key ON, Engine OFF).\n\nClearing codes will turn off the Check Engine light, reset fuel trim adaptation learned values, and reset readiness monitors. Proceed?";
  static const String confirmClear = "Yes, Key is ON and Engine is OFF";
  static const String cancel = "Cancel";
  static const String dtcsClearedSuccess = "Diagnostic trouble codes cleared and MIL light reset successfully!";
  static const String dtcSeverityHigh = "High Severity";
  static const String dtcSeverityMedium = "Medium Severity";
  static const String dtcSeverityLow = "Low Severity";
  static const String possibleCauses = "Possible Causes:";
  static const String symptoms = "Common Symptoms:";
  static const String workshopCheck = "Inspection & Multimeter Guide:";

  // Quick Scan & Vehicle Summary
  static const String vinLabel = "Chassis Number (VIN):";
  static const String protocolLabel = "Active Protocol:";
  static const String batteryVoltageLabel = "Battery Voltage:";
  static const String milStatusLabel = "MIL (Check Engine) Status:";
  static const String milOn = "ON (Active Trouble Codes)";
  static const String milOff = "OFF (No Active Faults)";
  static const String readinessMonitors = "Emissions Readiness Monitors:";
  static const String quickScanTitle = "30-Second Comprehensive Quick Scan";
  static const String runQuickScan = "Start 30s Quick Scan";
  static const String scanningVinMil = "Reading VIN, Protocol, and Diagnostic Status...";
  static const String quickScanComplete = "Quick Scan Completed Successfully";

  // Common Sensors (PIDs)
  static const String allSensors = "All Sensors";
  static const String engineSensors = "Engine & Speed";
  static const String fuelAirSensors = "Fuel & Air System";
  static const String coolingSensors = "Cooling System";
  static const String electricalSensors = "Electrical & Battery";
  static const String rpmName = "Engine RPM";
  static const String speedName = "Vehicle Speed";
  static const String coolantTempName = "Coolant Temperature";
  static const String intakeTempName = "Intake Air Temp (IAT)";
  static const String mapName = "Manifold Pressure (MAP)";
  static const String mafName = "Air Flow Rate (MAF)";
  static const String throttleName = "Throttle Position (TPS)";
  static const String stftName = "Short Term Fuel Trim (STFT)";
  static const String ltftName = "Long Term Fuel Trim (LTFT)";
  static const String o2Bank1Sensor1Name = "O2 Sensor Bank 1 Sensor 1 (Upstream)";
  static const String o2Bank1Sensor2Name = "O2 Sensor Bank 1 Sensor 2 (Downstream)";
  static const String fuelPressureName = "Fuel Rail Pressure";
  static const String moduleVoltageName = "ECU Module Voltage";

  // Vehicle Profiles Screen
  static const String searchVehicles = "Search vehicles (Make, Model, Year, Engine)...";
  static const String searchVehicleHint = "Search by Make, Model, or Year (e.g., Sunny, Verna, Tipo, 2018)...";
  static const String activeProfile = "Active Profile";
  static const String activateProfile = "Activate";
  static const String engineSpec = "Engine:";
  static const String transmissionSpec = "Trans:";
  static const String engineLabel = "Engine";
  static const String transmissionLabel = "Transmission";
  static const String protocolSpec = "Protocol:";
  static const String technicianNotes = "Technician Notes:";
  static const String workshopNote = "Workshop Note";
  static const String customPidsCount = "Custom PIDs:";
  static const String addCustomPid = "Add Custom PID";

  // Screen Titles & Additional Constants
  static const String diagnosticAssistant = "Diagnostic Assistant";
  static const String searchDtcHint = "Search DTC code or keyword (e.g., P0300, Misfire)...";
  static const String dtcsClearedFail = "Failed to clear trouble codes. Ensure Key is ON and Engine is OFF.";
  static const String noStoredDtcs = "No confirmed trouble codes found.";
  static const String noPendingDtcs = "No pending trouble codes found.";
  static const String noPermanentDtcs = "No permanent trouble codes found.";
  static const String ecuInfo = "ECU & Calibration Information";
  static const String workshopLanSync = "Workshop LAN Sync Hub";
  static const String workshopSettings = "Workshop & Center Settings";

  // Inspection Report & Workshop Cards
  static const String plateNumber = "License Plate:";
  static const String customerName = "Customer Name:";
  static const String customerPhone = "Phone Number:";
  static const String mechanicNotes = "Technician Notes & Recommendations:";
  static const String saveReport = "Save Inspection Report";
  static const String exportPdf = "Export PDF Report";
  static const String shareWhatsapp = "Share with Customer via WhatsApp";
  static const String printReport = "Print Report";
  static const String savedReports = "Saved Inspection Records";
  static const String noSavedReports = "No saved inspection reports found";

  // Safety Alarms
  static const String coolantAlarmTitle = "CRITICAL: Engine Overheating!";
  static const String coolantAlarmBody = "Coolant temperature exceeded safety limit (>105°C). Turn off engine immediately!";
  static const String batteryAlarmTitle = "WARNING: Low Battery Voltage!";
  static const String batteryAlarmBody = "Voltage dropped below 11.8V. Check alternator or battery charging system.";
  static const String clearAlarms = "Dismiss Alarms";

  // Diagzone 16 Special Functions
  static const String diagzoneSpecialFunctions = "Diagzone Special Functions (16 Resets)";
  static const String diagzoneSubtitle = "Oil, EPB, SAS, BMS, DPF, ABS Bleed & Throttle Relearn";
  static const String actuatorTests = "Bi-Directional Actuator Tests";
  static const String actuatorSubtitle = "Fan, Fuel Pump, EVAP, Injectors & Needle Sweep";
  static const String multiEcuTopology = "Multi-ECU Network Topology";
  static const String multiEcuSubtitle = "Scan ECM, TCM, ABS, SRS & BCM Gateway Bus";
  static const String catalyticAnalyzer = "Dual O2 & Catalytic Health";
  static const String catalyticSubtitle = "Upstream B1S1 vs Downstream B1S2 Converter Test";
  static const String flightRecorder = "Black Box Flight Recorder";
  static const String flightRecorderSubtitle = "High-Speed Telemetry Logging & Timeline Replay";
  static const String performanceDyno = "0-100 km/h & Dyno HP Meter";
  static const String performanceSubtitle = "Acceleration Timers, 400m Drag & Estimated WHP";
  static const String fuelEconomyEgp = "Fuel Economy & Cost (EGP)";
  static const String fuelEconomySubtitle = "L/100km & Egyptian Fuel Grades 80/92/95/Diesel";
  static const String hudNightMode = "Heads-Up Display (Night HUD)";
  static const String hudSubtitle = "Mirrored Windshield Projection Mode";
  static const String aiCopilot = "AI Diagnostic Copilot";
  static const String aiCopilotSubtitle = "Prioritized Mechanic Troubleshooting Trees";
  static const String ecuCoding = "ECU Variant Coding & Hidden Features";
  static const String ecuCodingSubtitle = "Unlock Needle Sweep, Mirror Fold, DRL, Chimes & Horn Chirp";
  static const String sgwAssistant = "Security Gateway (SGW) Bypass Assistant";
  static const String sgwAssistantSubtitle = "FCA 12+8 Pin, Renault & Nissan Pinout Visualizer";

  // Navigation aliases
  static const String actuatorTesting = actuatorTests;
  static const String dynoPerformance = performanceDyno;
  static const String fuelCostCalculator = fuelEconomyEgp;
  static const String hudDisplayMode = hudNightMode;

  // 1-Click Full Vehicle Test
  static const String fullVehicleTest = "1-Click Full Vehicle Test";
  static const String fullVehicleTestSubtitle = "10-Stage Comprehensive Topology, Health & Emissions Diagnostic";
  static const String startFullTest = "START FULL SYSTEM HEALTH TEST";
  static const String testingInProgress = "Full System Diagnostic in Progress...";
  static const String testCompleted = "Full Vehicle Inspection Completed";
  static const String overallHealthIndex = "Vehicle Health Index";
  static const String pass = "PASS";
  static const String fail = "FAULT";
  static const String warning = "WARN";
  static const String runFullTestNow = "Run 1-Click Full Test";
  static const String viewInspectionReport = "View Inspection Report";
  static const String selectVehicleFirst = "Please select or verify the vehicle profile first";
  static const String vehicleHealthSummary = "Vehicle Health Summary";
  static const String cancelTest = "Cancel Test";

  // Diagzone Pro Flagship Extensions
  static const String canTopologyVisual = "CAN Bus Topology Graph";
  static const String canTopologyVisualSubtitle = "Interactive Multi-Trunk Bus Map & Node Inspection";
  static const String immoKeySuite = "IMMO & Key Programming";
  static const String immoKeySuiteSubtitle = "RFID Transponder, RF Tester & PIN Calculator";
  static const String evHybridBatteryLab = "EV & Hybrid Battery Lab";
  static const String evHybridBatteryLabSubtitle = "96-Cell Delta (mV), HV Isolation & SOH%";

  // Workshop Power Modules
  static const String usedCarAudit = "Used Car Fraud & Pre-Purchase Audit";
  static const String usedCarAuditSubtitle = "Odometer Rollback Hunter & 100-Point Inspection Scorecard";
  static const String labScopeWaveform = "Digital Lab Scope & Waveform Library";
  static const String labScopeWaveformSubtitle = "CKP/CMP Timing Chain Stretch & Dual Oscilloscope";
  static const String wiringSchematics = "Interactive Wiring Schematics & Pinouts";
  static const String wiringSchematicsSubtitle = "Vector Color Diagrams & ECU Multimeter Probe Guide";
  static const String adasCalibration = "ADAS Camera & Radar Calibration Matrix";
  static const String adasCalibrationSubtitle = "Target Placement Coordinates & Dynamic Road Learning";
  static const String dpfRegeneration = "DPF / GPF & SCR AdBlue Suite";
  static const String dpfRegenerationSubtitle = "Stationary Forced Regeneration & Soot/Ash Mass Monitor";

  // Workshop UX Powerhouse Suite
  static const String voiceAssistant = "Hands-Free Voice Assistant";
  static const String voiceAssistantSubtitle = "Voice-Guided Inspection & Spoken Automotive Telemetry";
  static const String arEngineBay = "AR Engine Bay HUD Overlay";
  static const String arEngineBaySubtitle = "Interactive Component Pinouts & Camera Sensor HUD";
  static const String customerDispatch = "WhatsApp Customer Care Hub";
  static const String customerDispatchSubtitle = "5-Stage Progress Dispatch & 1-Tap PDF Customer Share";
  static const String offlineVault = "Offline Vault & CAN Sniffer";
  static const String offlineVaultSubtitle = "100% Offline Diagnostics & Raw CAN Bus Hex Packet Monitor";
}

