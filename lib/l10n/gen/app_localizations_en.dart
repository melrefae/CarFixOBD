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
}
