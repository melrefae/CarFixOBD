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

  @override
  String statusConnectionLost(String p0) {
    return '$p0 connection lost';
  }

  @override
  String get statusLaunchingSimulator => 'Launching ECU simulator...';

  @override
  String get statusSimulatorFailed => 'Failed to start simulator';

  @override
  String statusConnectingBluetooth(String p0) {
    return 'Connecting to Bluetooth adapter ($p0)...';
  }

  @override
  String get statusBluetoothFailed =>
      'Could not connect to adapter. Please check Bluetooth pairing and power.';

  @override
  String statusConnectingWifi(String p0) {
    return 'Connecting to Wi-Fi adapter ($p0)...';
  }

  @override
  String get statusWifiFailed =>
      'Could not connect to Wi-Fi adapter. Ensure you are connected to its Wi-Fi network.';

  @override
  String statusConnectingBle(String p0) {
    return 'Connecting to BLE adapter ($p0)...';
  }

  @override
  String get statusBleGattFailed =>
      'Could not establish GATT connection with BLE adapter. Ensure adapter is powered and nearby.';

  @override
  String statusOpeningSerial(String p0) {
    return 'Opening USB/Serial port ($p0)...';
  }

  @override
  String get statusSerialFailed =>
      'Could not open USB/Serial connection. Check cable, Bluetooth power, or permissions.';

  @override
  String get statusAutoDetecting =>
      'Auto-detecting OBD adapter across USB, Bluetooth, BLE & Wi-Fi...';

  @override
  String statusCheckingRecent(String p0) {
    return 'Checking recent adapter ($p0)...';
  }

  @override
  String get statusCheckingUsb => 'Checking USB-OTG & system serial ports...';

  @override
  String statusProbingSerial(String p0, String p1) {
    return 'Probing Serial $p0 @ $p1 bps...';
  }

  @override
  String get statusScanningBle => 'Scanning nearby BLE 4.0/5.0 OBD adapters...';

  @override
  String statusConnectingBleNamed(String p0) {
    return 'Connecting to BLE adapter: $p0...';
  }

  @override
  String get statusProbingWifi => 'Probing Wi-Fi ELM327 endpoints...';

  @override
  String statusFoundWifi(String p0) {
    return 'Found Wi-Fi OBD at $p0. Connecting...';
  }

  @override
  String get statusNoAdapterFound =>
      'No active OBD adapter found across USB, Bluetooth, BLE, or Wi-Fi. Plug into vehicle OBD-II port and retry.';

  @override
  String statusAutoConnectFailed(String p0) {
    return 'Auto-connect failed: $p0';
  }

  @override
  String get statusAuditing =>
      'Auditing genuine multi-ECU telemetry for pre-purchase evaluation...';

  @override
  String statusAuditDone(String p0) {
    return 'Vehicle audit completed. Overall score: $p0/100';
  }

  @override
  String get statusEvaluating =>
      'Evaluating available OBD adapters for auto-connection...';

  @override
  String get statusNoBtDevices =>
      'No Bluetooth devices available to auto-connect.';

  @override
  String statusBestMatched(String p0, String p1) {
    return 'Best adapter matched: $p0 ($p1). Connecting...';
  }

  @override
  String get statusHandshakeFailed =>
      'Could not complete ELM327 handshake with paired Bluetooth devices.';

  @override
  String get statusRequestingBtPerm => 'Requesting Bluetooth permissions...';

  @override
  String get statusScanningPaired =>
      'Scanning for paired Bluetooth OBD adapters...';

  @override
  String statusFoundAdapter(String p0) {
    return 'Found OBD adapter: $p0. Connecting...';
  }

  @override
  String statusProbingPaired(String p0) {
    return 'Probing paired device: $p0...';
  }

  @override
  String get statusDiscovering =>
      'Discovering nearby Bluetooth OBD adapters...';

  @override
  String statusFoundNearby(String p0) {
    return 'Found nearby OBD: $p0. Connecting...';
  }

  @override
  String get statusNoBtAdapter =>
      'No Bluetooth OBD adapter detected. Check adapter power or try BLE/USB/Wi-Fi.';

  @override
  String statusBtError(String p0) {
    return 'Bluetooth detection error: $p0';
  }

  @override
  String get statusInitProtocol =>
      'Initializing adapter & detecting vehicle protocol... Older cars (K-line) can take up to 40 seconds. Keep the key ON.';

  @override
  String get statusConnectedDetecting =>
      'Connected to ECU | Detecting vehicle & supported PIDs...';

  @override
  String statusConnectedDetected(String p0, String p1) {
    return 'Connected: $p0 | $p1';
  }

  @override
  String statusConnectedProtocol(String p0) {
    return 'Connected to ECU | Protocol: $p0';
  }

  @override
  String statusAdapterReadyKeyOff(String p0) {
    return 'Adapter Ready (${p0}V) - Ignition Key in OFF/ACC. Turn key to ON/RUN.';
  }

  @override
  String statusInitFailed(String p0) {
    return 'Failed to initialize ELM327 adapter. $p0';
  }

  @override
  String get statusRetrying =>
      'Retrying vehicle ECU handshake (Turn Key to ON)...';

  @override
  String get statusEcuNotResponding =>
      'ECU not responding. Make sure ignition key is switched to ON/RUN.';

  @override
  String get statusReadingVin =>
      'Reading VIN, auto-identifying car, and scanning trouble codes...';

  @override
  String get statusQuickScanDone => 'Quick scan completed successfully';

  @override
  String get fuelEconomyEgp => 'Fuel Economy & Cost (EGP)';

  @override
  String get resetTripOdometer => 'Reset Trip Odometer';

  @override
  String get fuelGradeTitle => 'Egyptian Regulated Fuel Grade & Tariff:';

  @override
  String get fuel80 => '80 Octane (13.75 EGP)';

  @override
  String get fuel92 => '92 Octane (15.25 EGP)';

  @override
  String get fuel95 => '95 Octane (17.00 EGP)';

  @override
  String get fuelDiesel => 'Diesel Solar (13.50 EGP)';

  @override
  String get instantConsumption => 'Instantaneous Fuel Consumption';

  @override
  String get idleSuffix => '(Idle)';

  @override
  String get avgEconomy => 'Avg Economy';

  @override
  String get efficiencyLabel => 'Efficiency';

  @override
  String get tripDistance => 'Trip Distance';

  @override
  String get tripCostTitle => 'Trip Cost Breakdown (Egyptian Pounds):';

  @override
  String get fuelTariffSelected => 'Fuel Tariff Selected:';

  @override
  String egpPerLiter(String p0) {
    return '$p0 EGP / Liter';
  }

  @override
  String get totalFuelConsumed => 'Total Fuel Consumed:';

  @override
  String litersValue(String p0) {
    return '$p0 Liters';
  }

  @override
  String get costPerKm => 'Cost Per Kilometer:';

  @override
  String egpPerKm(String p0) {
    return '$p0 EGP / km';
  }

  @override
  String get totalTripCost => 'Total Trip Cost:';

  @override
  String egpValue(String p0) {
    return '$p0 EGP';
  }

  @override
  String get windshieldMirrorOn => 'Windshield Mirror: ON';

  @override
  String get normalMode => 'Normal Mode';

  @override
  String get hudRpm => 'ENGINE RPM';

  @override
  String get hudCoolant => 'COOLANT';

  @override
  String get hudBattery => 'BATTERY';

  @override
  String get clearWarningTitle => 'Warning: Clearing Fault Codes';

  @override
  String get clearWarningBody =>
      'You are about to erase all stored Diagnostic Trouble Codes (DTCs), freeze frame data, and reset readiness monitors. This action cannot be undone. The Check Engine Light will turn off, but the mechanical fault may still exist and the light may return after a drive cycle.';

  @override
  String get mandatoryPreconditions => 'Mandatory Safety Pre-Conditions:';

  @override
  String get confirmEngineOff =>
      'I confirm vehicle engine is completely OFF (RPM = 0)';

  @override
  String get confirmIgnitionOn =>
      'I confirm ignition is ON with instrument cluster illuminated (Key ON / Ignition RUN)';

  @override
  String get confirmClear => 'Confirm & Clear All Codes';

  @override
  String get customPidTitle => 'Add Custom PID';

  @override
  String get sensorNameLabel => 'Sensor Name (e.g. AT Fluid Temp)';

  @override
  String get arabicNameOptional => 'Arabic Name (Optional)';

  @override
  String get modeHexLabel => 'Mode (Hex)';

  @override
  String get pidHexLabel => 'PID (Hex)';

  @override
  String get formulaLabel => 'Formula (e.g. A - 40 or ((A*256)+B)/10)';

  @override
  String get unitLabel => 'Unit (°C / Bar / %)';

  @override
  String get minValueLabel => 'Min Value';

  @override
  String get maxValueLabel => 'Max Value';

  @override
  String get requiredField => 'Required';

  @override
  String get savePid => 'Save PID';

  @override
  String get unitSec => 's';

  @override
  String get unitKmh => 'km/h';

  @override
  String get unitDegC => '°C';

  @override
  String get unitVolt => 'V';

  @override
  String get unitKpa => 'kPa';

  @override
  String get unitMeter => 'm';

  @override
  String get frTitle => 'Black Box Flight Recorder';

  @override
  String get frActive => 'Flight Recording ACTIVE';

  @override
  String get frBlackBox => 'Black Box Flight Logger';

  @override
  String frFramesLogged(int count, String secs) {
    return '$count frames logged (${secs}s)';
  }

  @override
  String get frRecordsDesc => 'Records 10 key telemetry PIDs for road testing';

  @override
  String get frStop => 'Stop & Save Flight Log';

  @override
  String get frStart => 'Start New Flight Recording';

  @override
  String get frVehicleFallback => 'Vehicle';

  @override
  String get frSavedLogs => 'Saved Flight Logs (Road Tests):';

  @override
  String get frNoLogs =>
      'No flight logs recorded yet.\nTap \'Start New Flight Recording\' during a road test to capture telemetry.';

  @override
  String frFramesEntry(String date, int count) {
    return '$date • $count Telemetry Frames';
  }

  @override
  String get frExportCsv => 'Export CSV (Excel / MegaLogViewer)';

  @override
  String get frDeleteLog => 'Delete Log';

  @override
  String get frDuration => 'Duration';

  @override
  String get frMaxSpeed => 'Max Speed';

  @override
  String get frMaxRpm => 'Max RPM';

  @override
  String get frMaxTemp => 'Max Temp';

  @override
  String get frScrub => 'Scrub & Replay Timeline';

  @override
  String frTimestamp(String pos, String total) {
    return 'Timestamp: ${pos}s / ${total}s';
  }

  @override
  String get frSpeed => 'Speed';

  @override
  String get frCoolant => 'Coolant';

  @override
  String get frThrottle => 'Throttle';

  @override
  String get frBattery => 'Battery';

  @override
  String get topoTitle => 'Multi-ECU Network Topology';

  @override
  String get topoRescan => 'Rescan All Systems';

  @override
  String get topoBusTitle => 'CAN Gateway Bus Topology';

  @override
  String topoModulesOnline(int online, int total, int faults) {
    return '$online / $total Modules Online • $faults Total Faults';
  }

  @override
  String get topoScanningBus => 'Scanning Bus...';

  @override
  String get topoSmartScan => 'Smart Scan (All Modules)';

  @override
  String get topoClearAll => 'Clear All';

  @override
  String get topoClearedOk => 'All module trouble codes cleared!';

  @override
  String get topoClearedFail => 'Failed to clear some modules.';

  @override
  String get topoOpenGraph =>
      'Open Interactive Multi-Trunk Bus Graph (CAN/LIN)';

  @override
  String get topoSubsystems => 'Detected Vehicle Subsystems:';

  @override
  String get topoScanning => 'Scanning...';

  @override
  String get topoHealthy => 'Healthy / Pass';

  @override
  String topoFaults(int count) {
    return '$count Fault(s)';
  }

  @override
  String get topoOffline => 'Not Fitted / Offline';

  @override
  String get topoPending => 'Pending Scan';

  @override
  String topoProtocol(String protocol) {
    return 'Protocol: $protocol';
  }

  @override
  String topoLatency(int ms) {
    return 'Latency: ${ms}ms';
  }

  @override
  String get topoStoredCodes => 'Stored Trouble Codes:';

  @override
  String topoSupportedPids(int count) {
    return 'Supported PIDs (read from this module): $count';
  }

  @override
  String get topoNoMode01 =>
      'This module does not report standard Mode 01 PIDs (UDS only or no data).';

  @override
  String get o2Title => 'Dual O2 & Catalytic Health';

  @override
  String get o2Pause => 'Pause Live Waveform';

  @override
  String get o2Start => 'Start Live Waveform';

  @override
  String get o2HealthTitle => 'Catalytic Converter Health';

  @override
  String o2Efficiency(int pct) {
    return '$pct% Efficiency';
  }

  @override
  String get o2Upstream => 'Upstream Transitions';

  @override
  String get o2Downstream => 'Downstream Transitions';

  @override
  String get o2Ratio => 'Switching Ratio';

  @override
  String get o2Waveforms => 'Dual O2 Waveforms (0.0V - 1.0V)';

  @override
  String get o2UpstreamShort => 'B1S1 (Upstream)';

  @override
  String get o2DownstreamShort => 'B1S2 (Downstream)';

  @override
  String get o2TapPlay =>
      'Tap Play button above to start live O2 sensor telemetry';

  @override
  String get o2Assessment => 'Diagnostic Assessment:';

  @override
  String get o2Guide => 'Technician Action Guide:';

  @override
  String get o2StatusInsufficient => 'Normal / Insufficient Samples';

  @override
  String get o2DiagInsufficient => 'Collecting oxygen sensor telemetry data...';

  @override
  String get o2RecInsufficient =>
      'Allow engine to idle or cruise steadily for 15 seconds to accumulate sensor waveforms.';

  @override
  String get o2StatusExcellent => 'Excellent / High Efficiency (OEM Benchmark)';

  @override
  String o2DiagExcellent(int upCross, String avgDown) {
    return 'Upstream sensor switches rapidly ($upCross transitions) while downstream sensor remains flat and steady (~${avgDown}V). The catalytic substrate has strong oxygen storage capacity.';
  }

  @override
  String get o2RecExcellent =>
      'No service required. Emissions system is operating within optimum Euro 4/5/6 compliance limits.';

  @override
  String get o2StatusAging => 'Aging Catalytic Converter (Moderate Efficiency)';

  @override
  String o2DiagAging(int downCross, int upCross, String degradation) {
    return 'Downstream sensor is beginning to mimic upstream switching ($downCross transitions vs $upCross). Oxygen storage capacity has degraded by $degradation%.';
  }

  @override
  String get o2RecAging =>
      'Inspect for minor exhaust manifold gasket leaks or unburnt fuel from rich misfires. Add high-grade catalytic converter cleaner additive.';

  @override
  String get o2StatusFailing =>
      'Severely Degraded / Catalytic Failure (P0420 Precursor)';

  @override
  String o2DiagFailing(String ratio) {
    return 'Downstream oxygen sensor is mirroring upstream oscillations with high switching ratio ($ratio%). The catalytic converter is no longer storing oxygen or reducing emissions.';
  }

  @override
  String get o2RecFailing =>
      'Catalytic converter core is melted, hollowed, or poisoned by leaded/contaminated fuel. Replacement of the converter or cleaning core is required.';

  @override
  String get dynoTitle => '0-100 km/h & Dyno HP Meter';

  @override
  String get dynoArmed => 'ARMED: Stop vehicle completely to begin';

  @override
  String get dynoAccelerating => 'ACCELERATING: Floor the accelerator!';

  @override
  String get dynoCompleted => 'RUN COMPLETED: 0-100 km/h Recorded!';

  @override
  String get dynoReset => 'Reset Performance Timers';

  @override
  String get dynoZeroHundred => '0 – 100 km/h (0 – 62 mph)';

  @override
  String get dynoZeroSixty => '0-60 km/h Split';

  @override
  String get dynoDistance => 'Distance Covered';

  @override
  String get dynoMaxSpeed => 'Max Speed';

  @override
  String get dynoQuarter => '400m Quarter Mile';

  @override
  String dynoTrap(String speed) {
    return 'Trap: $speed km/h';
  }

  @override
  String get dynoBraking => '100 – 0 Braking';

  @override
  String get dynoEmergencyStop => 'Emergency Stop';

  @override
  String get dynoEstTitle => 'Estimated Dyno Power & Torque:';

  @override
  String dynoWeight(int kg) {
    return 'Weight: $kg kg';
  }

  @override
  String get dynoPeakWHP => 'Peak Wheel Horsepower';

  @override
  String get dynoPeakTorque => 'Peak Engine Torque';

  @override
  String dynoAdjustWeight(int kg) {
    return 'Adjust Vehicle Weight ($kg kg):';
  }

  @override
  String get lanTitle => 'Workshop LAN Sync Hub';

  @override
  String get lanUnspecified => 'Unspecified';

  @override
  String lanNewReport(String name) {
    return 'New inspection report received for: $name';
  }

  @override
  String get lanTabServer => 'Local Server (Master)';

  @override
  String get lanTabSync => 'Sync Reports (Client)';

  @override
  String get lanServerActive => 'Local LAN Server Active';

  @override
  String get lanServerStopped => 'Local LAN Server Stopped';

  @override
  String get lanActiveDesc =>
      'Any desktop, laptop, or smartphone on workshop Wi-Fi can open the URL below';

  @override
  String get lanStoppedDesc =>
      'Tap the button below to start broadcasting live diagnostics and job cards over local Wi-Fi';

  @override
  String get lanCopyUrl => 'Copy URL';

  @override
  String get lanCopied => 'Server URL copied to clipboard!';

  @override
  String get lanStop => 'Stop LAN Server';

  @override
  String get lanStart => 'Start Workshop Server (Port 8080)';

  @override
  String get lanStartFail =>
      'Unable to start server. Ensure device is connected to Wi-Fi / Hotspot.';

  @override
  String get lanHowTitle => 'How Does Offline LAN Hub Work?';

  @override
  String get lanHowSteps =>
      '1. Ensure the diagnostic tablet and reception/accounting PC are connected to the same workshop Wi-Fi router or phone Hotspot.\n2. No external internet or cellular data is required; data communicates entirely offline across local subnet.\n3. Open Google Chrome on the reception PC and enter the URL shown above.\n4. A real-time dashboard appears displaying live telemetry, trouble codes, and printable PDF inspection job cards for standard A4 printers.';

  @override
  String get lanSyncTitle => 'Sync Inspection Job Cards with Master PC';

  @override
  String get lanSyncDesc =>
      'If using this tablet under the vehicle or in the service bay, push saved inspection job cards directly to the main reception PC with one tap.';

  @override
  String get lanMasterIp => 'Master PC IP Address';

  @override
  String get lanSyncing => 'Syncing...';

  @override
  String lanSyncAll(int count) {
    return 'Sync All Reports ($count)';
  }

  @override
  String get lanInvalidIp =>
      'Please enter a valid IP address for the Master PC';

  @override
  String lanSyncResultOk(int success) {
    return 'Sync result: Sent $success report(s) successfully without errors! ✅';
  }

  @override
  String lanSyncResultFail(int success, int fail) {
    return 'Sync result: Sent $success report(s) successfully, $fail failed.';
  }

  @override
  String get unitMs => 'ms';

  @override
  String get benchTitle => 'Adapter Benchmark';

  @override
  String get benchTapToStart => 'Tap the button below to start benchmark';

  @override
  String get benchRunningDesc =>
      'Transmitting diagnostic commands and profiling round-trip latency...';

  @override
  String get benchIdleDesc =>
      'Tests PIC18F25K80 chip authenticity, UART baud buffer, and bus packet throughput';

  @override
  String get benchAvg => 'Avg';

  @override
  String get benchBest => 'Best';

  @override
  String get benchMax => 'Max';

  @override
  String get benchSuccess => 'Success';

  @override
  String get benchHwProfile => 'Hardware Profile:';

  @override
  String get benchFirmware => 'Firmware Version (ATI):';

  @override
  String get benchChip => 'Chip Identifier (AT@1):';

  @override
  String get benchVoltage => 'Supply Voltage (ATRV):';

  @override
  String get benchProtocol => 'Detected Protocol (ATDP):';

  @override
  String get benchRunning => 'Running Benchmark Tests...';

  @override
  String get benchStart => 'Start Benchmark (10 Diagnostic Pings)';

  @override
  String get benchNeedConnection =>
      'Please connect to a physical OBD adapter (Bluetooth Classic, BLE, Wi-Fi, or USB OTG) to run benchmark.';

  @override
  String get benchLogTitle => 'Benchmark Serial Log:';

  @override
  String get benchLogRunning => 'Running benchmark tests...';

  @override
  String get benchLogAti => 'Sending ATI (Version query)...';

  @override
  String get benchLogAt1 => 'Sending AT@1 (Device query)...';

  @override
  String get benchLogAtrv => 'Sending ATRV (Voltage query)...';

  @override
  String get benchLogAtdp => 'Sending ATDP (Protocol query)...';

  @override
  String benchPingOk(int n, int ms) {
    return 'Ping #$n: ${ms}ms [OK]';
  }

  @override
  String benchPingFail(int n, int ms) {
    return 'Ping #$n: ${ms}ms [FAIL]';
  }

  @override
  String get benchResultExcellent =>
      'High-Quality PIC18F25K80 Chip (Fast & Authentic) ✅';

  @override
  String get benchResultStandard =>
      'Standard Diagnostic Adapter (Good for daily use) 👍';

  @override
  String get benchResultClone =>
      'Budget Clone Adapter (Clone v2.1 - Slow Response) ⚠️';

  @override
  String benchLogError(String e) {
    return 'Benchmark error: $e';
  }

  @override
  String benchInterrupted(String e) {
    return 'Benchmark interrupted: $e';
  }

  @override
  String get encTitle => 'DTC Encyclopedia';

  @override
  String get encSearchHint =>
      'Search DTC code or keyword (e.g., P0300, Misfire)...';

  @override
  String get encCatAll => 'All';

  @override
  String get encCatPowertrain => 'Powertrain';

  @override
  String get encCatTransmission => 'Transmission';

  @override
  String get encCatChassis => 'Chassis';

  @override
  String get encCatNetwork => 'Network';

  @override
  String get encCatBody => 'Body';

  @override
  String encAvailable(int count) {
    return 'Available Fault Codes: $count';
  }

  @override
  String get encPresets => 'Egyptian Automotive Presets';

  @override
  String get encEmpty =>
      'No matching trouble codes found.\nTry searching with a code like \'P0171\' or \'misfire\'.';

  @override
  String get sevNormal => 'Normal';

  @override
  String get sevCritical => 'Critical';

  @override
  String get sevHigh => 'High';

  @override
  String get sevMedium => 'Medium';

  @override
  String get encTechDesc => 'Technical Description:';

  @override
  String get encSymptoms => 'Common Symptoms:';

  @override
  String get encCauses => 'Common Workshop Causes:';

  @override
  String get encMultimeter => 'Multimeter & Pinout Inspection Guide:';

  @override
  String get encViewGuide => 'View Full Interactive Repair Guide';

  @override
  String get sfTitle => 'Diagzone Special Functions';

  @override
  String get sfSearchHint =>
      'Search service reset (e.g. Oil, EPB, SAS, BMS, Throttle)...';

  @override
  String sfTargetEcu(String ecu) {
    return 'Target ECU: $ecu';
  }

  @override
  String get sfSafety => 'Safety Prerequisites:';

  @override
  String get sfExecuting => 'Executing OBD Reset...';

  @override
  String get sfExecute => 'Execute Automated OBD Reset';

  @override
  String sfCompleted(String title) {
    return '$title completed successfully!';
  }

  @override
  String get sfRejected =>
      'OBD automated reset command rejected by ECU. Use manual procedure below.';

  @override
  String get sfCatBodyBcm => 'Body & BCM';

  @override
  String get sfCatBodyElectrical => 'Body & Electrical';

  @override
  String get sfCatBodyLighting => 'Body & Lighting';

  @override
  String get sfCatBrakes => 'Brakes';

  @override
  String get sfCatChassisBrakes => 'Chassis & Brakes';

  @override
  String get sfCatChassisStability => 'Chassis & Stability';

  @override
  String get sfCatCoolingEngine => 'Cooling & Engine';

  @override
  String get sfCatDashboard => 'Dashboard';

  @override
  String get sfCatElectrical => 'Electrical';

  @override
  String get sfCatElectronics => 'Electronics';

  @override
  String get sfCatEmissions => 'Emissions';

  @override
  String get sfCatMaintenance => 'Maintenance';

  @override
  String get sfCatSafetyAirbag => 'Safety & Airbag';

  @override
  String get sfCatSecurity => 'Security';

  @override
  String get sfCatSteeringSuspension => 'Steering & Suspension';

  @override
  String get sfCatWheelsTires => 'Wheels & Tires';

  @override
  String get dtcTypeStored => 'Stored';

  @override
  String get dtcTypePending => 'Pending';

  @override
  String get dtcTypePermanent => 'Permanent';

  @override
  String get codTitle => 'ECU Variant Coding';

  @override
  String get codRestoreTip => 'Restore Original Factory Coding';

  @override
  String get codGeneric => 'Generic';

  @override
  String get codGenericVehicle => 'Generic Vehicle / Standalone ECU';

  @override
  String get codConnected => 'Connected • Ready to read/write variant coding';

  @override
  String get codDisconnected => 'Offline / Disconnected from ECU';

  @override
  String codOnlyMake(String make) {
    return 'Only $make';
  }

  @override
  String get codCatDashboard => 'Dashboard & Cluster';

  @override
  String get codCatLighting => 'Lighting & Vision';

  @override
  String get codCatComfort => 'Comfort & Convenience';

  @override
  String get codCatSafety => 'Safety & Chimes';

  @override
  String codEmptyMake(String make) {
    return 'No specific coding options found for $make.\nTurn off vehicle filter to view all universal options.';
  }

  @override
  String get codEmptyCat => 'No features match selected category.';

  @override
  String codCompatible(String brands) {
    return 'Compatible: $brands';
  }

  @override
  String codEnabled(String title) {
    return '$title is now ENABLED!';
  }

  @override
  String codDisabled(String title) {
    return '$title is now DISABLED!';
  }

  @override
  String get codWriteFailed =>
      'Failed to write coding to ECU. Check ignition state.';

  @override
  String get codRestoreTitle => 'Restore Factory Coding?';

  @override
  String get codRestoreBody =>
      'This will revert all modified features back to the initial backup snapshot recorded when this session started.';

  @override
  String get codCancel => 'Cancel';

  @override
  String get codRestoreBtn => 'Restore Backup';

  @override
  String get codRestored => 'All factory codings restored!';

  @override
  String get codRestoreFailed => 'Restore failed for some modules.';

  @override
  String get daTitle => 'Diagnostic Assistant';

  @override
  String get daTabFuel => 'Fuel Trim & Vacuum';

  @override
  String get daTabBattery => 'Battery & Alternator';

  @override
  String get daMethod =>
      'Diagnostic Method: Record Fuel Trims (STFT + LTFT) at idle, then hold engine at 2500 RPM under load. Observe how trim values change to instantly distinguish between vacuum leaks and fuel pump starvation.';

  @override
  String get daCaptureIdle => 'Capture Idle Live';

  @override
  String get daCaptureLoad => 'Capture 2500 RPM';

  @override
  String get daReadingIdle => 'Reading Idle STFT / LTFT from ECU...';

  @override
  String get daReadingLoad => 'Reading 2500 RPM STFT / LTFT from ECU...';

  @override
  String daCaptured(int rpm, String stft, String ltft) {
    return 'Captured live ($rpm RPM): STFT $stft%, LTFT $ltft%';
  }

  @override
  String get daNoData => 'ECU returned no 0106/0107 Fuel Trim data.';

  @override
  String get daIdleTrims => 'Idle Trims (STFT + LTFT):';

  @override
  String get daIdleStft => 'Idle STFT (%)';

  @override
  String get daIdleLtft => 'Idle LTFT (%)';

  @override
  String get daLoadTrims => '2500 RPM Trims (Under Load):';

  @override
  String get daLoadStft => 'Load STFT (%)';

  @override
  String get daLoadLtft => 'Load LTFT (%)';

  @override
  String get daAction => 'Workshop Recommended Action:';

  @override
  String daLiveVolts(String v) {
    return 'Live Adapter Voltage: ${v}V • Start Live Cranking Test with engine off, then crank starter & let engine idle to automatically record sag & charging output.';
  }

  @override
  String daStopSampling(String v) {
    return 'Stop Live Cranking & Alternator Sampling (${v}V)';
  }

  @override
  String get daStartSampling => 'Start Live 12V Cranking & Alternator Test';

  @override
  String daResting(String v) {
    return 'Resting Battery Voltage (Engine OFF): ${v}V';
  }

  @override
  String daCranking(String v) {
    return 'Min Cranking Voltage Drop (Starter Crank): ${v}V';
  }

  @override
  String daRunning(String v) {
    return 'Alternator Output Voltage (Engine Running): ${v}V';
  }

  @override
  String daBatteryHealth(String s) {
    return 'Battery Health: $s';
  }

  @override
  String daAlternatorHealth(String s) {
    return 'Alternator Health: $s';
  }

  @override
  String daRecommendation(String s) {
    return 'Recommendation: $s';
  }

  @override
  String get copTitle => 'AI Diagnostic Copilot';

  @override
  String get copCopyTooltip => 'Copy Report Summary';

  @override
  String get copGenericVehicle => 'Generic OBD-II Vehicle';

  @override
  String copOnline(int count) {
    return 'Live Telemetry Connected • $count Active DTCs';
  }

  @override
  String get copOffline =>
      'Offline Mode • Connect OBD adapter for live streaming';

  @override
  String get copChange => 'CHANGE';

  @override
  String get copHypothesis => 'Primary Diagnostic Hypothesis';

  @override
  String copMatch(int pct) {
    return '$pct% Match';
  }

  @override
  String get copEvidence => 'Correlated Live Evidence & Telemetry';

  @override
  String get copRoadmap => '4-Step Workshop Diagnostic Roadmap';

  @override
  String copExpected(String value) {
    return 'Expected Good Value: $value';
  }

  @override
  String get copBulletin => 'Egyptian Workshop Technical Bulletin';

  @override
  String get copNextActions => 'Next Workshop Actions:';

  @override
  String get copActuatorTests => 'Actuator Tests';

  @override
  String get copCatAnalyzer => 'Cat Analyzer';

  @override
  String get copLiveGraphs => 'Live Graphs';

  @override
  String get copCopied => 'AI Diagnostic Report copied to clipboard';

  @override
  String get copRepHeader => '=== AI DIAGNOSTIC COPILOT REPORT ===';

  @override
  String copRepVehicle(String v) {
    return 'Vehicle: $v';
  }

  @override
  String copRepHyp(String h, int pct) {
    return 'Primary Hypothesis: $h ($pct% Confidence)';
  }

  @override
  String copRepUrgency(String u) {
    return 'Urgency: $u';
  }

  @override
  String get copRepEvidence => 'Key Evidence:';

  @override
  String get copRepRoadmap => 'Mechanic Roadmap:';

  @override
  String copRepAction(String a) {
    return 'Action: $a';
  }

  @override
  String get copRepBulletin => 'Egyptian Workshop Bulletin:';

  @override
  String reportVinLine(String vin) {
    return 'VIN: $vin';
  }

  @override
  String get vatLabel => 'VAT';
}
