// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pdfFileNotFound => 'PDF file not found';

  @override
  String get deleteThisVisit => 'Delete this visit?';

  @override
  String get theSavedRecordAndIts =>
      'The saved record and its PDF are removed from this phone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get carHistory => 'Car History';

  @override
  String get noSavedVisitsYetFinish =>
      'No saved visits yet. Finish an inspection and press \"Save visit\".';

  @override
  String get searchPlateCustomerVin => 'Search plate, customer, VIN';

  @override
  String get noMatch => 'No match';

  @override
  String get unknownCar => 'Unknown car';

  @override
  String get visits => 'visits';

  @override
  String get carRead => 'car read';

  @override
  String get handInspectionOnly => 'hand inspection only';

  @override
  String get compare2SelectedVisits => 'Compare 2 selected visits';

  @override
  String get jobCardsQuotes => 'Job Cards & Quotes';

  @override
  String get newJobCard => 'New job card';

  @override
  String get noJobCardsYet => 'No job cards yet.';

  @override
  String get searchPlateCustomerPhone => 'Search plate, customer, phone';

  @override
  String get saved => 'Saved';

  @override
  String get enterTheCustomerPhoneFirst => 'Enter the customer phone first';

  @override
  String get couldNotOpenWhatsapp => 'Could not open WhatsApp';

  @override
  String get jobCard => 'Job card';

  @override
  String get customer => 'Customer';

  @override
  String get phoneWhatsapp => 'Phone (WhatsApp)';

  @override
  String get plate => 'Plate';

  @override
  String get odometerKm => 'Odometer km';

  @override
  String get vehicle => 'Vehicle';

  @override
  String get complaint => 'Complaint';

  @override
  String get findingsWorkDone => 'Findings / work done';

  @override
  String get status => 'Status';

  @override
  String get partsAndLabourEgp => 'Parts and labour (EGP)';

  @override
  String get part => 'Part';

  @override
  String get labour => 'Labour';

  @override
  String get discountEgp => 'Discount EGP';

  @override
  String get vatIfAny => 'VAT % (if any)';

  @override
  String get parts => 'Parts';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'TOTAL';

  @override
  String get quotePdf => 'Quote PDF';

  @override
  String get invoicePdf => 'Invoice PDF';

  @override
  String get whatsappQuote => 'WhatsApp quote';

  @override
  String get whatsappInvoice => 'WhatsApp invoice';

  @override
  String get labourDescription => 'Labour description';

  @override
  String get partName => 'Part name';

  @override
  String get qty => 'Qty';

  @override
  String get unitPrice => 'Unit price';

  @override
  String get continueSavedDraft => 'Continue saved draft?';

  @override
  String get anUnfinishedInspectionWasSaved =>
      'An unfinished inspection was saved on this phone.';

  @override
  String unfinishedInspectionFor(Object p0) {
    return 'Unfinished inspection for $p0.';
  }

  @override
  String get startNew => 'Start new';

  @override
  String get continueAction => 'Continue';

  @override
  String get visitSaved => 'Visit saved';

  @override
  String get connectTheAdapterToThe => 'Connect the adapter to the car first.';

  @override
  String get s1ReadFromCar => '1. Read from car';

  @override
  String get s2InspectionForm => '2. Inspection form';

  @override
  String get s3Report => '3. Report';

  @override
  String get usedCarInspection => 'Used-car inspection';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get thisStepReadsOnlyWhat =>
      'This step reads only what the car reports: odometer in the ECUs, stored codes and clearing history, VIN, battery voltage, misfires. Everything else is entered by hand in step 2.';

  @override
  String get adapterConnected => 'Adapter connected';

  @override
  String get notConnected => 'Not connected';

  @override
  String get connect => 'Connect';

  @override
  String get reading => 'Reading...';

  @override
  String get readFromCar => 'Read from car';

  @override
  String get readAgain => 'Read again';

  @override
  String get carReadingsRestoredFromThe =>
      'Car readings restored from the saved draft. Read again to refresh them.';

  @override
  String get skipNoCarHandInspection => 'Skip, no car (hand inspection only)';

  @override
  String get odometerEcmTcmAbsCluster => 'Odometer (ECM / TCM / ABS / cluster)';

  @override
  String get codeClearingHistory => 'Code clearing history';

  @override
  String get vin => 'VIN';

  @override
  String get battery => 'Battery';

  @override
  String get misfires => 'Misfires';

  @override
  String get valuesTheCarDidNot =>
      'Values the car did not answer are shown as not read. Not a final verdict: finish step 2.';

  @override
  String get handEnteredAnythingLeftEmpty =>
      'Hand-entered. Anything left empty or \"not checked\" is printed as not checked, never as OK.';

  @override
  String get odometerShownKm => 'Odometer shown (km)';

  @override
  String get paintThicknessUmGaugeNeeded =>
      'Paint thickness (um), gauge needed';

  @override
  String get bodyNotesDentsPanelGaps =>
      'Body notes (dents, panel gaps, rust, glass)';

  @override
  String get tiresTreadDepthMm => 'Tires: tread depth (mm)';

  @override
  String get tireNoteAgeUnevenWear => 'Tire note (age, uneven wear)';

  @override
  String get brakes => 'Brakes';

  @override
  String get frontPads => 'Front pads %';

  @override
  String get rearPads => 'Rear pads %';

  @override
  String get frontDiscs => 'Front discs';

  @override
  String get rearDiscs => 'Rear discs';

  @override
  String get fluids => 'Fluids';

  @override
  String get testDrive => 'Test drive';

  @override
  String get mechanicalChecklist => 'Mechanical checklist';

  @override
  String get photos => 'Photos';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get technicianNotes => 'Technician notes';

  @override
  String get notes => 'Notes';

  @override
  String get couldNotOpenTheCamera => 'Could not open the camera or gallery';

  @override
  String get ok => 'OK';

  @override
  String get marginal => 'Marginal';

  @override
  String get fail => 'Fail';

  @override
  String get leak => 'Leak';

  @override
  String get theReportPrintsCarReadings =>
      'The report prints car readings and hand-entered data in separate sections. The score is a simple formula from the car readings, not a verdict.';

  @override
  String get fromTheCar => 'From the car';

  @override
  String get fromTheCarSavedReadings => 'From the car (saved readings)';

  @override
  String get noCarReadingHandInspection =>
      'No car reading, hand inspection only';

  @override
  String get paint => 'Paint';

  @override
  String get checklist => 'Checklist';

  @override
  String get tiresFluidsTestDrive => 'Tires / fluids / test drive';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get print => 'Print';

  @override
  String get savedSaveAgain => 'Saved. Save again';

  @override
  String get saveVisitToCarHistory => 'Save visit to car history';

  @override
  String get saveAndCreateJobCard => 'Save and create job card / quote';

  @override
  String get logoSavedItPrintsOn => 'Logo saved. It prints on the next PDF.';

  @override
  String backupFailed(Object p0) {
    return 'Backup failed: $p0';
  }

  @override
  String get couldNotReadTheFile => 'Could not read the file';

  @override
  String importedVisitsAndJobCards(Object p0, Object p1, Object p2) {
    return 'Imported $p0 visits and $p1 job cards. Skipped $p2 already on this phone.';
  }

  @override
  String importFailed(Object p0) {
    return 'Import failed: $p0';
  }

  @override
  String get logoOnPdfsOptional => 'Logo on PDFs (optional)';

  @override
  String get choose => 'Choose';

  @override
  String get remove => 'Remove';

  @override
  String get backupOfSavedVisitsAnd => 'Backup of saved visits and job cards';

  @override
  String get savedDataLivesOnlyOn =>
      'Saved data lives only on this phone. Export a file and keep it somewhere safe (WhatsApp to yourself, Drive, email). Import adds records from a backup and never overwrites what is already here.';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get importBackup => 'Import backup';

  @override
  String get appName => 'AutoSpect';

  @override
  String get darkWorkshopMode => 'Dark Workshop Mode';

  @override
  String get brightDaylightMode => 'Bright Daylight Sunlight Mode';

  @override
  String get centerAlarmSettings => 'Center & Alarm Settings';

  @override
  String get shieldNotTested => 'Shield = not yet tested on a real car';

  @override
  String get ecuScanTree => 'ECU scan tree';

  @override
  String get findModulesGateway => 'Find modules on the gateway';

  @override
  String get interactiveBusMap => 'Interactive bus map';

  @override
  String get canLinGraph => 'CAN/LIN graph and node inspection';

  @override
  String get daily => 'Daily';

  @override
  String get readClearDtc => 'Read / Clear DTC';

  @override
  String get liveData => 'Live Data';

  @override
  String get liveGraphs => 'Live Graphs';

  @override
  String get freezeFrame => 'Freeze Frame';

  @override
  String get readiness => 'Readiness';

  @override
  String get ecuInfo => 'ECU Info';

  @override
  String get mode06Monitors => 'Mode 06';

  @override
  String get vehicleProfile => 'Vehicle Profile';

  @override
  String get inspectionCustomers => 'Inspection & Customers';

  @override
  String get usedCarAudit => 'Used-Car Audit';

  @override
  String savedReportsCount(Object count) {
    return 'Saved Reports ($count)';
  }

  @override
  String get whatsappDispatch => 'WhatsApp Dispatch';

  @override
  String get lanHub => 'LAN Hub';

  @override
  String get analysisTools => 'Analysis & Tools';

  @override
  String get networkMap => 'Network Map';

  @override
  String get o2Catalyst => 'O2 & Catalyst';

  @override
  String get fuelTrimBattery => 'Fuel Trim & Battery';

  @override
  String get dtcEncyclopedia => 'DTC Encyclopedia';

  @override
  String get wiring => 'Wiring';

  @override
  String get canSniffer => 'CAN Sniffer';

  @override
  String get adapterTest => 'Adapter Test';

  @override
  String get terminal => 'Terminal';

  @override
  String get rawLog => 'Raw Log';

  @override
  String get labExperimentalPin => 'Lab (experimental, PIN)';

  @override
  String get labFeaturesUnverified =>
      'Resets, coding, immobilizer, actuators, ADAS, DPF, EV, scope, dyno. Not verified on a car.';

  @override
  String get moreTools => 'More tools';

  @override
  String get classicAudit9Tabs => 'Classic Audit (9 tabs)';

  @override
  String get voiceAssistant => 'Voice Assistant';

  @override
  String get arHud => 'AR HUD';

  @override
  String get aiCopilot => 'AI Copilot';

  @override
  String get flightRecorder => 'Flight Recorder';

  @override
  String get fuelCost => 'Fuel Cost';

  @override
  String get hudDisplay => 'HUD Display';

  @override
  String get connectedToEcu => 'Connected to ECU';

  @override
  String get adapterReadyTurnKey => 'Adapter Ready (Turn Key to ON/RUN)';

  @override
  String get connectingObdAdapter => 'Connecting to OBD Adapter...';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get switchAdapter => 'Switch Adapter';

  @override
  String batterySummary(Object summary, Object voltage) {
    return 'Battery: ${voltage}V | $summary';
  }

  @override
  String batteryVehicle(Object model, Object voltage) {
    return 'Battery: ${voltage}V | Vehicle: $model';
  }

  @override
  String get genericVehicle => 'Generic';

  @override
  String get fullVehicleTest => '1-Click Full Vehicle Test';

  @override
  String selectedProfileNotConnected(Object name) {
    return 'Selected profile (not connected): $name';
  }

  @override
  String get tapToSelectVehicle => 'Tap to select vehicle & start full test';

  @override
  String get fullScanSubtitle =>
      '10-stage full network scan, deep health index & PDF report';

  @override
  String get quickScan30s => 'Quick Scan (30s)';

  @override
  String get quickScanSubtitle =>
      'Instant 30s vehicle scan: DTCs, Live Sensors, VIN & Voltage';

  @override
  String get connectAdapterFirst =>
      'Please connect to a real OBD adapter (Bluetooth Classic, BLE, Wi-Fi, or USB OTG) first.';

  @override
  String get workshopSettings => 'Workshop & Center Settings';

  @override
  String get workshopBrandingSaved =>
      'Workshop branding and alarm settings saved successfully! ✅';

  @override
  String get suiteTagline => 'Automotive Diagnostic & Fleet Telemetry Suite';

  @override
  String get copyNumber => 'Copy Number';

  @override
  String get phoneCopied => 'Phone number copied to clipboard';

  @override
  String get workshopInfoPdf => 'Workshop Information (PDF Reports):';

  @override
  String get workshopCenterName => 'Workshop Center Name';

  @override
  String get workshopAddress => 'Workshop Address';

  @override
  String get defaultInspectionEngineer => 'Default Inspection Engineer';

  @override
  String get standardInspectionFee => 'Standard Inspection Fee';

  @override
  String get safetyThresholdsAlarms => 'Safety Thresholds & Real-Time Alarms:';

  @override
  String get enableAlarmSounds => 'Enable Alarm Sounds & Haptic Vibrate';

  @override
  String get alarmSoundsSubtitle =>
      'Triggers popup alert and haptic feedback when a sensor exceeds safe limits';

  @override
  String get engineOverheatLimit => 'Engine Overheating Alarm Limit:';

  @override
  String get alternatorLowVoltage => 'Alternator Low Voltage Limit:';

  @override
  String get cloudBackupSync => 'Cloud Backup & Fleet Webhook Sync';

  @override
  String get obdAdapterAutoReconnect => 'OBD Adapter & Auto-Reconnect';

  @override
  String get autoReconnectLaunch => 'Auto-reconnect on app launch';

  @override
  String get autoReconnectSubtitle =>
      'Automatically connects to the last paired adapter on startup';

  @override
  String get pairedObdAdapter => 'Paired OBD Adapter';

  @override
  String get forget => 'Forget';

  @override
  String get noSavedAdapterYet =>
      'No saved adapter yet. Connect your adapter to save it for auto-reconnect.';

  @override
  String get saveWorkshopSettings => 'Save Workshop Settings';

  @override
  String get connectionTitle => 'ELM327 Connection Manager';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get autoDetectConnect => 'Auto Detect & Connect';

  @override
  String get pairedDevicesOs => 'Paired Devices (OS Settings)';

  @override
  String get noPairedDevices => 'No paired Bluetooth devices found';

  @override
  String get discoveredDevices => 'Nearby Discovered Devices';

  @override
  String get unknownDevice => 'Generic Device';

  @override
  String get wifiSettingsTitle => 'ELM327 Wi-Fi Configuration:';

  @override
  String get wifiDescription =>
      'Most Wi-Fi OBD adapters in Egypt broadcast an SSID named \'WiFi_OBDII\' and use default IP 192.168.0.10 on port 35000.';

  @override
  String get adapterAddressLabel => 'Adapter Address (IP:Port)';

  @override
  String get connectWifi => 'Connect via Wi-Fi';

  @override
  String get protocolPickerLabel => 'Protocol: ';

  @override
  String get checkAdapter20s => 'Check adapter (about 20 s)';

  @override
  String get adapterCheckTitle => 'Adapter check';

  @override
  String get readModulesUds => 'Read modules, UDS (read-only, CAN only)';

  @override
  String get modulesUdsTitle => 'Modules (UDS)';

  @override
  String get lastAttempt => 'Last attempt:';

  @override
  String get retryEcuHandshake => 'Retry ECU Handshake (Key in ON/RUN)';

  @override
  String quickReconnect(Object name, Object type) {
    return 'Quick Reconnect: $name ($type)';
  }

  @override
  String get autoDetectSubtitle =>
      'Probes USB-OTG / Paired Serial, BT Classic, BLE 5.0 & Wi-Fi automatically + auto-detects car VIN/Model';

  @override
  String get autoDetecting => 'Auto-Detecting...';

  @override
  String get autoDetectAnyAdapter => 'Auto-Detect & Connect Any OBD Adapter';

  @override
  String connectedToAdapter(Object adapter) {
    return 'Connected to $adapter!';
  }

  @override
  String get scanning => 'Scanning...';

  @override
  String get scanNearby => 'Scan Nearby';

  @override
  String get refreshPaired => 'Refresh Paired';

  @override
  String get pairedNonAndroidNote =>
      'On laptop/desktop or non-Android devices, check USB / Serial tab for paired Bluetooth COM/cu ports or BLE 5.0 tab.';

  @override
  String get listeningNearby => 'Listening for nearby Bluetooth adapters...';

  @override
  String get pairedBadge => 'Paired';

  @override
  String get nearbyBadge => 'Nearby';

  @override
  String chipLabel(Object chip) {
    return 'Chip: $chip';
  }

  @override
  String scoreLabel(Object score) {
    return 'Score: $score';
  }

  @override
  String get autoProbeWifi => 'Auto-Probe Active Wi-Fi OBD Gateway';

  @override
  String get noWifiGateway =>
      'No Wi-Fi ELM327 gateway responded on standard ports.';

  @override
  String get bleTitle => 'Bluetooth Low Energy (BLE 4.0 / 5.0 GATT)';

  @override
  String get bleDescription =>
      'Scans live nearby BLE peripherals supporting Nordic UART (6E400001), 0xFFF0 (Veepeak/Vgate), 0x18F0 (OBDLink/vLinker), and 0xFFE0 GATT characteristics.';

  @override
  String get scanningBle => 'Scanning Nearby BLE Peripherals...';

  @override
  String get scanBleAdapters => 'Scan Nearby BLE OBD Adapters';

  @override
  String bleScanResults(Object count) {
    return 'Live BLE Scan Results ($count)';
  }

  @override
  String get listening => 'Listening...';

  @override
  String get searchingBle => 'Searching BLE advertisements...';

  @override
  String get tapScanBle =>
      'Tap \'Scan Nearby BLE OBD Adapters\' above to discover powered BLE dongles.';

  @override
  String bleIdRssi(Object id, Object rssi) {
    return 'ID: $id • RSSI: $rssi dBm';
  }

  @override
  String get manualBleId => 'Manual BLE Remote ID / Address:';

  @override
  String get bleIdHint => 'e.g. 00:1B:10:E2:33:44 or device UUID';

  @override
  String get usbSerialTitle => 'USB OTG & Serial / Paired COM Ports';

  @override
  String get usbSerialDescription =>
      'Real Android USB-OTG drivers (FTDI, CH340, CP2102, PL2303, CDC-ACM) plus macOS/Linux POSIX serial & paired Bluetooth serial ports (/dev/cu.*).';

  @override
  String get enumeratingPorts => 'Enumerating Attached Ports...';

  @override
  String get refreshUsbDevices => 'Refresh Attached USB / Serial Devices';

  @override
  String detectedSerialPorts(Object count) {
    return 'Detected Hardware Serial Ports ($count):';
  }

  @override
  String get noUsbDetected =>
      'No USB OTG cables or OBD serial ports detected right now. Plug in USB cable or pair Bluetooth adapter, then tap Refresh.';

  @override
  String portLine(Object port, Object transport) {
    return 'Port: $port • $transport';
  }

  @override
  String get manualSerialOverride => 'Manual Serial Port / Baud Override';

  @override
  String get serialPortPathLabel => 'USB / Serial Port Path or Device ID';

  @override
  String get uartBaudRate => 'UART Baud Rate: ';

  @override
  String get openSerialPort => 'Open Specified Serial Port';

  @override
  String get noDtcsFound =>
      'No trouble codes found. ECU reports healthy status!';

  @override
  String get vinLabel => 'Chassis Number (VIN):';

  @override
  String get protocolLabel => 'Active Protocol:';

  @override
  String get batteryVoltageLabel => 'Battery Voltage:';

  @override
  String get milStatusLabel => 'MIL (Check Engine) Status:';

  @override
  String get milOn => 'ON (Active Trouble Codes)';

  @override
  String get milOff => 'OFF (No Active Faults)';

  @override
  String get saveReport => 'Save Inspection Report';

  @override
  String get rescan => 'Rescan';

  @override
  String get scanningVinMil =>
      'Scanning VIN, MIL status, DTCs, and system voltage...';

  @override
  String detectedDtcs(Object count) {
    return 'Detected Trouble Codes ($count):';
  }

  @override
  String get activeFaults => 'Active Faults';

  @override
  String get optimalHealth => 'Engine & Emissions in Optimal Health';

  @override
  String get codesDetectedCel =>
      'Trouble Codes Detected & Check Engine Active!';

  @override
  String get noMisfires =>
      'No misfires, catalyst, or emission-related trouble codes logged in ECU.';

  @override
  String get saveJobCard => 'Save Inspection Job Card:';

  @override
  String get licensePlateLabel => 'License Plate (e.g. ABC 1234)';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phoneWhatsappNumber => 'Phone / WhatsApp Number';

  @override
  String get enterPlate => 'Please enter the license plate number';

  @override
  String get walkInCustomer => 'Walk-in Customer';

  @override
  String get jobCardSaved => 'Job card saved successfully!';

  @override
  String get readDtcs => 'Diagnostic Codes (DTCs)';

  @override
  String get storedDtcs => 'Confirmed Trouble Codes (Mode 03)';

  @override
  String get pendingDtcs => 'Pending Trouble Codes (Mode 07)';

  @override
  String get permanentDtcs => 'Permanent Trouble Codes (Mode 0A)';

  @override
  String get searchDtcHint =>
      'Search DTC code or keyword (e.g., P0300, Misfire)...';

  @override
  String get clearDtcsButton => 'Clear Trouble Codes & Reset MIL (Mode 04)';

  @override
  String get dtcsClearedSuccess =>
      'Diagnostic trouble codes cleared and MIL light reset successfully!';

  @override
  String get dtcsClearedFail =>
      'Failed to clear trouble codes. Ensure Key is ON and Engine is OFF.';

  @override
  String clearPartialRemaining(Object codes, Object count) {
    return 'The ECU accepted the clear but $count code(s) are still stored: $codes. The fault is probably still present.';
  }

  @override
  String get clearUnconfirmed =>
      'The ECU accepted the clear but the read-back could not confirm it. Read the codes again.';

  @override
  String get noStoredDtcs => 'No confirmed trouble codes found.';

  @override
  String get noPendingDtcs => 'No pending trouble codes found.';

  @override
  String get noPermanentDtcs => 'No permanent trouble codes found.';

  @override
  String get rescanDtcs => 'Rescan DTCs';

  @override
  String noDtcsMatching(Object query) {
    return 'No diagnostic trouble codes found matching \'$query\'';
  }

  @override
  String get liveSensorsTitle => 'Live Sensors';

  @override
  String get liveGraphsTitle => 'Live Waveforms (Graphs)';

  @override
  String get discoverPids => 'Discover Supported PIDs';

  @override
  String get pausePolling => 'Pause Live Polling';

  @override
  String get startPolling => 'Start Live Polling';

  @override
  String get allSensors => 'All Sensors';

  @override
  String get engineSensors => 'Engine & Speed';

  @override
  String get coolingSensors => 'Cooling System';

  @override
  String get electricalSensors => 'Electrical & Battery';

  @override
  String get fuelAir => 'Fuel & Air';

  @override
  String get railTurbo => 'Rail & Turbo';

  @override
  String get transmission => 'Transmission';

  @override
  String get absSpeeds => '4-Wheel ABS';

  @override
  String get oemCustom => 'OEM Custom';

  @override
  String get noSensorsCategory => 'No sensors found in this category';

  @override
  String get variance5 => 'Variance > 5 km/h';

  @override
  String get disableDual => 'Disable Dual Channel';

  @override
  String get enableDual => 'Enable Dual Channel';

  @override
  String get channel1 => 'Channel 1 (Yellow):';

  @override
  String get channel2 => 'Channel 2 Comparison (Cyan):';

  @override
  String get freezeFrameTitle => 'Freeze Frame Data';

  @override
  String get refreshFreezeFrame => 'Refresh Freeze Frame';

  @override
  String get queryingFreezeFrame =>
      'Querying Freeze Frame data from ECU (Mode 02)...';

  @override
  String get noFreezeFrame => 'No Freeze Frame logged in ECU memory';

  @override
  String get freezeFrameStoredWhen =>
      'Freeze frame data is stored only when a confirmed DTC is first triggered';

  @override
  String get triggeringFaultCode => 'Triggering Fault Code:';

  @override
  String get sensorSnapshot => 'Sensor Snapshot at Event Occurrence:';

  @override
  String get engineSpeedRpm => 'Engine Speed (RPM):';

  @override
  String get vehicleSpeedLabel => 'Vehicle Speed:';

  @override
  String get coolantTempLabel => 'Coolant Temperature:';

  @override
  String get engineLoadLabel => 'Calculated Engine Load:';

  @override
  String get throttlePositionLabel => 'Throttle Position (TPS):';

  @override
  String get manifoldPressureLabel => 'Manifold Absolute Pressure:';

  @override
  String get intakeAirTempLabel => 'Intake Air Temp (IAT):';

  @override
  String get stftLabel => 'Short Term Fuel Trim (STFT):';

  @override
  String get ltftLabel => 'Long Term Fuel Trim (LTFT):';

  @override
  String get workshopAnalysis => 'Workshop Analysis & Operating Context:';

  @override
  String faultContextLine1(Object coolant, Object rpm, Object speed) {
    return 'This fault was triggered while driving at $speed km/h with engine running at $rpm RPM and coolant at $coolant°C.';
  }

  @override
  String faultContextLine2(Object condition, Object ltft) {
    return 'Long Term Fuel Trim was ($ltft%), indicating the ECU was compensating for a $condition at the moment the fault occurred.';
  }

  @override
  String get leanCondition =>
      'lean condition (intake vacuum leak or low fuel pressure)';

  @override
  String get richCondition =>
      'rich condition (dripping injector or restricted air intake)';

  @override
  String get normalCondition => 'normal air-fuel ratio';

  @override
  String codesNeedInspection(Object count) {
    return '$count diagnostic trouble code(s) detected requiring technical inspection.';
  }

  @override
  String get absCompareTitle => '4-Wheel Independent ABS Speeds';

  @override
  String get targetVsActual => 'Target vs Actual OEM Tracking';

  @override
  String get railPressure => 'Common Rail Fuel Pressure';

  @override
  String get turboBoost => 'Turbo Boost Pressure';

  @override
  String actualValue(Object value) {
    return 'Actual: $value';
  }

  @override
  String targetValue(Object value) {
    return 'Target: $value';
  }

  @override
  String get inspectionReports => 'Inspection Reports';

  @override
  String get cloudBackupTooltip => 'Cloud Backup & Fleet Sync';

  @override
  String get searchReportsHint => 'Search by plate number, VIN, or customer...';

  @override
  String get noReportsFound => 'No saved inspection reports found';

  @override
  String get noReportsHint =>
      'Run a \'Quick Scan\' to generate and save customer inspection reports';

  @override
  String get deleteReportTooltip => 'Delete Report';

  @override
  String reportCustomerLine(String p0, String p1) {
    return 'Customer: $p0 | Phone: $p1';
  }

  @override
  String reportDateLine(String p0) {
    return 'Date: $p0';
  }

  @override
  String get allSystemsClear => 'All Systems Clear';

  @override
  String troubleCodesCount(String p0) {
    return '$p0 Trouble Codes';
  }

  @override
  String voltageLine(String p0) {
    return 'Voltage: ${p0}V';
  }

  @override
  String reportNotesLine(String p0) {
    return 'Technician Notes: $p0';
  }

  @override
  String get exportPdf => 'Export PDF Report';

  @override
  String get shareWhatsapp => 'Share with Customer via WhatsApp';

  @override
  String get vehicleProfiles => 'Egyptian Vehicle Profiles';

  @override
  String get searchVehicles => 'Search vehicles (Make, Model, Year, Engine)...';

  @override
  String get tabEgyptianPresets => 'Egyptian Presets';

  @override
  String get tabGlobalBrands => '250+ Global Brands';

  @override
  String noProfilesFound(String p0, String p1) {
    return 'No vehicle profiles found in \'$p0\' matching \'$p1\'';
  }

  @override
  String noBrandsFound(String p0, String p1) {
    return 'No brands found for \'$p0\' matching \'$p1\'';
  }

  @override
  String get activeProfile => 'Active Profile';

  @override
  String get activateProfile => 'Activate';

  @override
  String get fullTest => 'Full Test';

  @override
  String get engineLabel => 'Engine';

  @override
  String get transmissionLabel => 'Transmission';

  @override
  String get workshopNote => 'Workshop Note';

  @override
  String get addCustomPid => 'Add Custom PID';

  @override
  String egyptianPresetsCount(String p0) {
    return '$p0 Egyptian Presets';
  }

  @override
  String get genericUdsObd2 => 'Generic UDS / OBD2';

  @override
  String get selectModel => 'Select Model';

  @override
  String activatedGenericProfile(String p0) {
    return 'Activated generic diagnostic profile for $p0';
  }

  @override
  String brandModelsTitle(String p0) {
    return '$p0 Models';
  }

  @override
  String get testShort => 'Test';

  @override
  String get readinessMonitors => 'Emissions Readiness Monitors';

  @override
  String get refreshReadiness => 'Refresh Readiness';

  @override
  String get readinessQuerying =>
      'Querying I/M Readiness drive cycle monitors (Mode 01 PID 01)...';

  @override
  String get readinessNoData => 'No readiness monitor data retrieved yet';

  @override
  String get readinessAllReady => 'All Drive Cycle Monitors Ready';

  @override
  String readinessIncomplete(String p0) {
    return 'Incomplete Monitors Detected ($p0)';
  }

  @override
  String readinessSummary(String p0, String p1, String p2) {
    return 'Ready: $p0 | Incomplete: $p1 | Check Engine: $p2';
  }

  @override
  String get readinessTip =>
      'Pre-purchase Inspection Tip: If the Check Engine Light is OFF but several monitors show \'Incomplete\', this indicates fault codes were cleared recently to temporarily hide the light without completing a full drive cycle!';

  @override
  String get readinessSubtitle => 'Subsystem Readiness Status:';

  @override
  String get badgeUnsupported => 'Unsupported';

  @override
  String get badgeReady => 'Ready';

  @override
  String get badgeIncomplete => 'Incomplete';

  @override
  String get refreshEcuDetails => 'Refresh ECU Details';

  @override
  String get ecuQuerying =>
      'Querying VIN and calibration identification numbers (Mode 09)...';

  @override
  String get ecuModuleLabel => 'Electronic Control Module:';

  @override
  String get ecuDefaultName => 'Engine Control Module (ECM/PCM)';

  @override
  String get notAvailable => 'Not Available';

  @override
  String get notDetected => 'Not Detected';

  @override
  String get calIdLabel => 'Calibration ID (CALID):';

  @override
  String get calIdSubtitle =>
      'Software revision and firmware version installed on the engine control unit';

  @override
  String get cvnLabel => 'Calibration Verification Number (CVN):';

  @override
  String get cvnSubtitle =>
      'Cryptographic checksum ensuring software calibration integrity and authenticity';

  @override
  String get vinSubtitle =>
      'Standard vehicle electronic identification number stored in ECU flash memory';

  @override
  String get protocolSubtitle =>
      'Active serial communications bus protocol over OBD-II DLC connector';

  @override
  String get ecuTechNoteTitle =>
      'Technician Note (ECU Software & Remap Check):';

  @override
  String get ecuTechNoteBody =>
      'CALID and CVN codes are used by service centers to verify whether vehicle software has been altered with aftermarket ECU tunes/remaps, or if an official OEM factory reflash is needed to resolve technical service bulletins.';

  @override
  String get terminalTitle => 'OBD Terminal';

  @override
  String get clearTerminalTooltip => 'Clear Terminal Logs';

  @override
  String get terminalReadyHint =>
      'ELM327 Serial Terminal Ready.\nType an AT or OBD command below or tap a quick shortcut above.';

  @override
  String get terminalInputHint =>
      'Enter AT or OBD command (e.g. AT RV or 01 0C)...';

  @override
  String get sendCommandTooltip => 'Send Command';

  @override
  String get connectFirstSnack => 'Please connect to OBD adapter first';

  @override
  String get qcResetAdapter => 'Reset Adapter';

  @override
  String get qcReadBattery => 'Read Battery';

  @override
  String get qcActiveProtocol => 'Active Protocol';

  @override
  String get qcSupportedPids => 'Supported PIDs 1-20';

  @override
  String get qcEngineRpm => 'Engine RPM';

  @override
  String get qcVehicleSpeed => 'Vehicle Speed';

  @override
  String get qcReadStoredDtcs => 'Read Stored DTCs';

  @override
  String get qcReadPendingDtcs => 'Read Pending DTCs';

  @override
  String get qcReadVin => 'Read VIN';

  @override
  String get mode06Title => 'Mode \$06 Misfire & Component Monitor';

  @override
  String get mode06ScanTooltip => 'Scan Mode \$06';

  @override
  String mode06Summary(String p0, String p1) {
    return 'Mode \$06 Summary: $p0 Monitors ($p1 Out-of-Spec)';
  }

  @override
  String get mode06Subtitle =>
      'Reads early cylinder misfire counters, catalyst & O2 margins before a Check Engine light triggers.';

  @override
  String get mode06ConnectFirst =>
      'Connect an OBD adapter to query real-time Mode \$06 component monitors.';

  @override
  String get mode06Scanning => 'Interrogating ECU Mode \$06 Test IDs...';

  @override
  String get mode06NoResults =>
      'No Mode \$06 test records returned by this ECU for the current filter.';

  @override
  String get mode06Rescan => 'Re-Scan Mode \$06';

  @override
  String get filterAll => 'All';

  @override
  String get filterMisfires => 'Misfires';

  @override
  String get filterO2Cat => 'O2 & Catalyst';

  @override
  String get filterFailedOnly => 'Failed Only';

  @override
  String get statusNoResult => 'NO RESULT YET';

  @override
  String get statusInfo => 'INFO';

  @override
  String get statusPass => 'PASS';

  @override
  String get statusFail => 'FAIL';

  @override
  String minLimitLabel(String p0, String p1) {
    return 'Min: $p0 $p1';
  }

  @override
  String maxLimitLabel(String p0, String p1) {
    return 'Max: $p0 $p1';
  }

  @override
  String get neverCompleted => 'Never completed since codes were erased';

  @override
  String get constantNoLimits => 'Constant (no limits)';

  @override
  String get rawUnit => '(raw)';

  @override
  String get sensorWord => 'sensor';

  @override
  String rawLogTitle(String p0) {
    return 'Raw log ($p0)';
  }

  @override
  String get exportTooltip => 'Export';

  @override
  String get exportEvidenceTooltip => 'Export log + feature status';

  @override
  String get clearTooltip => 'Clear';

  @override
  String get noCommandsYet => 'No commands sent yet';

  @override
  String get waitingForData => 'Waiting...';

  @override
  String get protocolAutoSearch => 'Auto (adapter searches all protocols)';

  @override
  String get hwChipUsb => 'USB / Serial';

  @override
  String get hwChipBtClassic => 'BT Classic SPP';

  @override
  String get hwChipBle => 'BLE 4.0 / 5.0';

  @override
  String get hwChipWifi => 'Wi-Fi TCP';

  @override
  String get hwChipAutoVin => 'Auto Car VIN';

  @override
  String get statusDisconnected => 'Disconnected from adapter';

  @override
  String get statusDisconnectedShort => 'Disconnected';

  @override
  String get regionAll => 'All Regions';

  @override
  String get regionAsian => 'Asian';

  @override
  String get regionEuropean => 'European';

  @override
  String get regionAmerican => 'American';

  @override
  String get regionChinese => 'Chinese';

  @override
  String get regionCommercial => 'Commercial';
}
