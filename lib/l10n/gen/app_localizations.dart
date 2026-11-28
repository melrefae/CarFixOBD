import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @pdfFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'PDF file not found'**
  String get pdfFileNotFound;

  /// No description provided for @deleteThisVisit.
  ///
  /// In en, this message translates to:
  /// **'Delete this visit?'**
  String get deleteThisVisit;

  /// No description provided for @theSavedRecordAndIts.
  ///
  /// In en, this message translates to:
  /// **'The saved record and its PDF are removed from this phone.'**
  String get theSavedRecordAndIts;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @carHistory.
  ///
  /// In en, this message translates to:
  /// **'Car History'**
  String get carHistory;

  /// No description provided for @noSavedVisitsYetFinish.
  ///
  /// In en, this message translates to:
  /// **'No saved visits yet. Finish an inspection and press \"Save visit\".'**
  String get noSavedVisitsYetFinish;

  /// No description provided for @searchPlateCustomerVin.
  ///
  /// In en, this message translates to:
  /// **'Search plate, customer, VIN'**
  String get searchPlateCustomerVin;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get noMatch;

  /// No description provided for @unknownCar.
  ///
  /// In en, this message translates to:
  /// **'Unknown car'**
  String get unknownCar;

  /// No description provided for @visits.
  ///
  /// In en, this message translates to:
  /// **'visits'**
  String get visits;

  /// No description provided for @carRead.
  ///
  /// In en, this message translates to:
  /// **'car read'**
  String get carRead;

  /// No description provided for @handInspectionOnly.
  ///
  /// In en, this message translates to:
  /// **'hand inspection only'**
  String get handInspectionOnly;

  /// No description provided for @compare2SelectedVisits.
  ///
  /// In en, this message translates to:
  /// **'Compare 2 selected visits'**
  String get compare2SelectedVisits;

  /// No description provided for @jobCardsQuotes.
  ///
  /// In en, this message translates to:
  /// **'Job Cards & Quotes'**
  String get jobCardsQuotes;

  /// No description provided for @newJobCard.
  ///
  /// In en, this message translates to:
  /// **'New job card'**
  String get newJobCard;

  /// No description provided for @noJobCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No job cards yet.'**
  String get noJobCardsYet;

  /// No description provided for @searchPlateCustomerPhone.
  ///
  /// In en, this message translates to:
  /// **'Search plate, customer, phone'**
  String get searchPlateCustomerPhone;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @enterTheCustomerPhoneFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter the customer phone first'**
  String get enterTheCustomerPhoneFirst;

  /// No description provided for @couldNotOpenWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp'**
  String get couldNotOpenWhatsapp;

  /// No description provided for @jobCard.
  ///
  /// In en, this message translates to:
  /// **'Job card'**
  String get jobCard;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @phoneWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Phone (WhatsApp)'**
  String get phoneWhatsapp;

  /// No description provided for @plate.
  ///
  /// In en, this message translates to:
  /// **'Plate'**
  String get plate;

  /// No description provided for @odometerKm.
  ///
  /// In en, this message translates to:
  /// **'Odometer km'**
  String get odometerKm;

  /// No description provided for @vehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicle;

  /// No description provided for @complaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// No description provided for @findingsWorkDone.
  ///
  /// In en, this message translates to:
  /// **'Findings / work done'**
  String get findingsWorkDone;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @partsAndLabourEgp.
  ///
  /// In en, this message translates to:
  /// **'Parts and labour (EGP)'**
  String get partsAndLabourEgp;

  /// No description provided for @part.
  ///
  /// In en, this message translates to:
  /// **'Part'**
  String get part;

  /// No description provided for @labour.
  ///
  /// In en, this message translates to:
  /// **'Labour'**
  String get labour;

  /// No description provided for @discountEgp.
  ///
  /// In en, this message translates to:
  /// **'Discount EGP'**
  String get discountEgp;

  /// No description provided for @vatIfAny.
  ///
  /// In en, this message translates to:
  /// **'VAT % (if any)'**
  String get vatIfAny;

  /// No description provided for @parts.
  ///
  /// In en, this message translates to:
  /// **'Parts'**
  String get parts;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @quotePdf.
  ///
  /// In en, this message translates to:
  /// **'Quote PDF'**
  String get quotePdf;

  /// No description provided for @invoicePdf.
  ///
  /// In en, this message translates to:
  /// **'Invoice PDF'**
  String get invoicePdf;

  /// No description provided for @whatsappQuote.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp quote'**
  String get whatsappQuote;

  /// No description provided for @whatsappInvoice.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp invoice'**
  String get whatsappInvoice;

  /// No description provided for @labourDescription.
  ///
  /// In en, this message translates to:
  /// **'Labour description'**
  String get labourDescription;

  /// No description provided for @partName.
  ///
  /// In en, this message translates to:
  /// **'Part name'**
  String get partName;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPrice;

  /// No description provided for @continueSavedDraft.
  ///
  /// In en, this message translates to:
  /// **'Continue saved draft?'**
  String get continueSavedDraft;

  /// No description provided for @anUnfinishedInspectionWasSaved.
  ///
  /// In en, this message translates to:
  /// **'An unfinished inspection was saved on this phone.'**
  String get anUnfinishedInspectionWasSaved;

  /// No description provided for @unfinishedInspectionFor.
  ///
  /// In en, this message translates to:
  /// **'Unfinished inspection for {p0}.'**
  String unfinishedInspectionFor(Object p0);

  /// No description provided for @startNew.
  ///
  /// In en, this message translates to:
  /// **'Start new'**
  String get startNew;

  /// No description provided for @continueAction.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueAction;

  /// No description provided for @visitSaved.
  ///
  /// In en, this message translates to:
  /// **'Visit saved'**
  String get visitSaved;

  /// No description provided for @connectTheAdapterToThe.
  ///
  /// In en, this message translates to:
  /// **'Connect the adapter to the car first.'**
  String get connectTheAdapterToThe;

  /// No description provided for @s1ReadFromCar.
  ///
  /// In en, this message translates to:
  /// **'1. Read from car'**
  String get s1ReadFromCar;

  /// No description provided for @s2InspectionForm.
  ///
  /// In en, this message translates to:
  /// **'2. Inspection form'**
  String get s2InspectionForm;

  /// No description provided for @s3Report.
  ///
  /// In en, this message translates to:
  /// **'3. Report'**
  String get s3Report;

  /// No description provided for @usedCarInspection.
  ///
  /// In en, this message translates to:
  /// **'Used-car inspection'**
  String get usedCarInspection;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @thisStepReadsOnlyWhat.
  ///
  /// In en, this message translates to:
  /// **'This step reads only what the car reports: odometer in the ECUs, stored codes and clearing history, VIN, battery voltage, misfires. Everything else is entered by hand in step 2.'**
  String get thisStepReadsOnlyWhat;

  /// No description provided for @adapterConnected.
  ///
  /// In en, this message translates to:
  /// **'Adapter connected'**
  String get adapterConnected;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @reading.
  ///
  /// In en, this message translates to:
  /// **'Reading...'**
  String get reading;

  /// No description provided for @readFromCar.
  ///
  /// In en, this message translates to:
  /// **'Read from car'**
  String get readFromCar;

  /// No description provided for @readAgain.
  ///
  /// In en, this message translates to:
  /// **'Read again'**
  String get readAgain;

  /// No description provided for @carReadingsRestoredFromThe.
  ///
  /// In en, this message translates to:
  /// **'Car readings restored from the saved draft. Read again to refresh them.'**
  String get carReadingsRestoredFromThe;

  /// No description provided for @skipNoCarHandInspection.
  ///
  /// In en, this message translates to:
  /// **'Skip, no car (hand inspection only)'**
  String get skipNoCarHandInspection;

  /// No description provided for @odometerEcmTcmAbsCluster.
  ///
  /// In en, this message translates to:
  /// **'Odometer (ECM / TCM / ABS / cluster)'**
  String get odometerEcmTcmAbsCluster;

  /// No description provided for @codeClearingHistory.
  ///
  /// In en, this message translates to:
  /// **'Code clearing history'**
  String get codeClearingHistory;

  /// No description provided for @vin.
  ///
  /// In en, this message translates to:
  /// **'VIN'**
  String get vin;

  /// No description provided for @battery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// No description provided for @misfires.
  ///
  /// In en, this message translates to:
  /// **'Misfires'**
  String get misfires;

  /// No description provided for @valuesTheCarDidNot.
  ///
  /// In en, this message translates to:
  /// **'Values the car did not answer are shown as not read. Not a final verdict: finish step 2.'**
  String get valuesTheCarDidNot;

  /// No description provided for @handEnteredAnythingLeftEmpty.
  ///
  /// In en, this message translates to:
  /// **'Hand-entered. Anything left empty or \"not checked\" is printed as not checked, never as OK.'**
  String get handEnteredAnythingLeftEmpty;

  /// No description provided for @odometerShownKm.
  ///
  /// In en, this message translates to:
  /// **'Odometer shown (km)'**
  String get odometerShownKm;

  /// No description provided for @paintThicknessUmGaugeNeeded.
  ///
  /// In en, this message translates to:
  /// **'Paint thickness (um), gauge needed'**
  String get paintThicknessUmGaugeNeeded;

  /// No description provided for @bodyNotesDentsPanelGaps.
  ///
  /// In en, this message translates to:
  /// **'Body notes (dents, panel gaps, rust, glass)'**
  String get bodyNotesDentsPanelGaps;

  /// No description provided for @tiresTreadDepthMm.
  ///
  /// In en, this message translates to:
  /// **'Tires: tread depth (mm)'**
  String get tiresTreadDepthMm;

  /// No description provided for @tireNoteAgeUnevenWear.
  ///
  /// In en, this message translates to:
  /// **'Tire note (age, uneven wear)'**
  String get tireNoteAgeUnevenWear;

  /// No description provided for @brakes.
  ///
  /// In en, this message translates to:
  /// **'Brakes'**
  String get brakes;

  /// No description provided for @frontPads.
  ///
  /// In en, this message translates to:
  /// **'Front pads %'**
  String get frontPads;

  /// No description provided for @rearPads.
  ///
  /// In en, this message translates to:
  /// **'Rear pads %'**
  String get rearPads;

  /// No description provided for @frontDiscs.
  ///
  /// In en, this message translates to:
  /// **'Front discs'**
  String get frontDiscs;

  /// No description provided for @rearDiscs.
  ///
  /// In en, this message translates to:
  /// **'Rear discs'**
  String get rearDiscs;

  /// No description provided for @fluids.
  ///
  /// In en, this message translates to:
  /// **'Fluids'**
  String get fluids;

  /// No description provided for @testDrive.
  ///
  /// In en, this message translates to:
  /// **'Test drive'**
  String get testDrive;

  /// No description provided for @mechanicalChecklist.
  ///
  /// In en, this message translates to:
  /// **'Mechanical checklist'**
  String get mechanicalChecklist;

  /// No description provided for @photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get photos;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @technicianNotes.
  ///
  /// In en, this message translates to:
  /// **'Technician notes'**
  String get technicianNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @couldNotOpenTheCamera.
  ///
  /// In en, this message translates to:
  /// **'Could not open the camera or gallery'**
  String get couldNotOpenTheCamera;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @marginal.
  ///
  /// In en, this message translates to:
  /// **'Marginal'**
  String get marginal;

  /// No description provided for @fail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get fail;

  /// No description provided for @leak.
  ///
  /// In en, this message translates to:
  /// **'Leak'**
  String get leak;

  /// No description provided for @theReportPrintsCarReadings.
  ///
  /// In en, this message translates to:
  /// **'The report prints car readings and hand-entered data in separate sections. The score is a simple formula from the car readings, not a verdict.'**
  String get theReportPrintsCarReadings;

  /// No description provided for @fromTheCar.
  ///
  /// In en, this message translates to:
  /// **'From the car'**
  String get fromTheCar;

  /// No description provided for @fromTheCarSavedReadings.
  ///
  /// In en, this message translates to:
  /// **'From the car (saved readings)'**
  String get fromTheCarSavedReadings;

  /// No description provided for @noCarReadingHandInspection.
  ///
  /// In en, this message translates to:
  /// **'No car reading, hand inspection only'**
  String get noCarReadingHandInspection;

  /// No description provided for @paint.
  ///
  /// In en, this message translates to:
  /// **'Paint'**
  String get paint;

  /// No description provided for @checklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get checklist;

  /// No description provided for @tiresFluidsTestDrive.
  ///
  /// In en, this message translates to:
  /// **'Tires / fluids / test drive'**
  String get tiresFluidsTestDrive;

  /// No description provided for @sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get sharePdf;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @savedSaveAgain.
  ///
  /// In en, this message translates to:
  /// **'Saved. Save again'**
  String get savedSaveAgain;

  /// No description provided for @saveVisitToCarHistory.
  ///
  /// In en, this message translates to:
  /// **'Save visit to car history'**
  String get saveVisitToCarHistory;

  /// No description provided for @saveAndCreateJobCard.
  ///
  /// In en, this message translates to:
  /// **'Save and create job card / quote'**
  String get saveAndCreateJobCard;

  /// No description provided for @logoSavedItPrintsOn.
  ///
  /// In en, this message translates to:
  /// **'Logo saved. It prints on the next PDF.'**
  String get logoSavedItPrintsOn;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {p0}'**
  String backupFailed(Object p0);

  /// No description provided for @couldNotReadTheFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read the file'**
  String get couldNotReadTheFile;

  /// No description provided for @importedVisitsAndJobCards.
  ///
  /// In en, this message translates to:
  /// **'Imported {p0} visits and {p1} job cards. Skipped {p2} already on this phone.'**
  String importedVisitsAndJobCards(Object p0, Object p1, Object p2);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: {p0}'**
  String importFailed(Object p0);

  /// No description provided for @logoOnPdfsOptional.
  ///
  /// In en, this message translates to:
  /// **'Logo on PDFs (optional)'**
  String get logoOnPdfsOptional;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @backupOfSavedVisitsAnd.
  ///
  /// In en, this message translates to:
  /// **'Backup of saved visits and job cards'**
  String get backupOfSavedVisitsAnd;

  /// No description provided for @savedDataLivesOnlyOn.
  ///
  /// In en, this message translates to:
  /// **'Saved data lives only on this phone. Export a file and keep it somewhere safe (WhatsApp to yourself, Drive, email). Import adds records from a backup and never overwrites what is already here.'**
  String get savedDataLivesOnlyOn;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AutoSpect'**
  String get appName;

  /// No description provided for @darkWorkshopMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Workshop Mode'**
  String get darkWorkshopMode;

  /// No description provided for @brightDaylightMode.
  ///
  /// In en, this message translates to:
  /// **'Bright Daylight Sunlight Mode'**
  String get brightDaylightMode;

  /// No description provided for @centerAlarmSettings.
  ///
  /// In en, this message translates to:
  /// **'Center & Alarm Settings'**
  String get centerAlarmSettings;

  /// No description provided for @shieldNotTested.
  ///
  /// In en, this message translates to:
  /// **'Shield = not yet tested on a real car'**
  String get shieldNotTested;

  /// No description provided for @ecuScanTree.
  ///
  /// In en, this message translates to:
  /// **'ECU scan tree'**
  String get ecuScanTree;

  /// No description provided for @findModulesGateway.
  ///
  /// In en, this message translates to:
  /// **'Find modules on the gateway'**
  String get findModulesGateway;

  /// No description provided for @interactiveBusMap.
  ///
  /// In en, this message translates to:
  /// **'Interactive bus map'**
  String get interactiveBusMap;

  /// No description provided for @canLinGraph.
  ///
  /// In en, this message translates to:
  /// **'CAN/LIN graph and node inspection'**
  String get canLinGraph;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @readClearDtc.
  ///
  /// In en, this message translates to:
  /// **'Read / Clear DTC'**
  String get readClearDtc;

  /// No description provided for @liveData.
  ///
  /// In en, this message translates to:
  /// **'Live Data'**
  String get liveData;

  /// No description provided for @liveGraphs.
  ///
  /// In en, this message translates to:
  /// **'Live Graphs'**
  String get liveGraphs;

  /// No description provided for @freezeFrame.
  ///
  /// In en, this message translates to:
  /// **'Freeze Frame'**
  String get freezeFrame;

  /// No description provided for @readiness.
  ///
  /// In en, this message translates to:
  /// **'Readiness'**
  String get readiness;

  /// No description provided for @ecuInfo.
  ///
  /// In en, this message translates to:
  /// **'ECU Info'**
  String get ecuInfo;

  /// No description provided for @mode06Monitors.
  ///
  /// In en, this message translates to:
  /// **'Mode 06'**
  String get mode06Monitors;

  /// No description provided for @vehicleProfile.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Profile'**
  String get vehicleProfile;

  /// No description provided for @inspectionCustomers.
  ///
  /// In en, this message translates to:
  /// **'Inspection & Customers'**
  String get inspectionCustomers;

  /// No description provided for @usedCarAudit.
  ///
  /// In en, this message translates to:
  /// **'Used-Car Audit'**
  String get usedCarAudit;

  /// No description provided for @savedReportsCount.
  ///
  /// In en, this message translates to:
  /// **'Saved Reports ({count})'**
  String savedReportsCount(Object count);

  /// No description provided for @whatsappDispatch.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Dispatch'**
  String get whatsappDispatch;

  /// No description provided for @lanHub.
  ///
  /// In en, this message translates to:
  /// **'LAN Hub'**
  String get lanHub;

  /// No description provided for @analysisTools.
  ///
  /// In en, this message translates to:
  /// **'Analysis & Tools'**
  String get analysisTools;

  /// No description provided for @networkMap.
  ///
  /// In en, this message translates to:
  /// **'Network Map'**
  String get networkMap;

  /// No description provided for @o2Catalyst.
  ///
  /// In en, this message translates to:
  /// **'O2 & Catalyst'**
  String get o2Catalyst;

  /// No description provided for @fuelTrimBattery.
  ///
  /// In en, this message translates to:
  /// **'Fuel Trim & Battery'**
  String get fuelTrimBattery;

  /// No description provided for @dtcEncyclopedia.
  ///
  /// In en, this message translates to:
  /// **'DTC Encyclopedia'**
  String get dtcEncyclopedia;

  /// No description provided for @wiring.
  ///
  /// In en, this message translates to:
  /// **'Wiring'**
  String get wiring;

  /// No description provided for @canSniffer.
  ///
  /// In en, this message translates to:
  /// **'CAN Sniffer'**
  String get canSniffer;

  /// No description provided for @adapterTest.
  ///
  /// In en, this message translates to:
  /// **'Adapter Test'**
  String get adapterTest;

  /// No description provided for @terminal.
  ///
  /// In en, this message translates to:
  /// **'Terminal'**
  String get terminal;

  /// No description provided for @rawLog.
  ///
  /// In en, this message translates to:
  /// **'Raw Log'**
  String get rawLog;

  /// No description provided for @labExperimentalPin.
  ///
  /// In en, this message translates to:
  /// **'Lab (experimental, PIN)'**
  String get labExperimentalPin;

  /// No description provided for @labFeaturesUnverified.
  ///
  /// In en, this message translates to:
  /// **'Resets, coding, immobilizer, actuators, ADAS, DPF, EV, scope, dyno. Not verified on a car.'**
  String get labFeaturesUnverified;

  /// No description provided for @moreTools.
  ///
  /// In en, this message translates to:
  /// **'More tools'**
  String get moreTools;

  /// No description provided for @classicAudit9Tabs.
  ///
  /// In en, this message translates to:
  /// **'Classic Audit (9 tabs)'**
  String get classicAudit9Tabs;

  /// No description provided for @voiceAssistant.
  ///
  /// In en, this message translates to:
  /// **'Voice Assistant'**
  String get voiceAssistant;

  /// No description provided for @arHud.
  ///
  /// In en, this message translates to:
  /// **'AR HUD'**
  String get arHud;

  /// No description provided for @aiCopilot.
  ///
  /// In en, this message translates to:
  /// **'AI Copilot'**
  String get aiCopilot;

  /// No description provided for @flightRecorder.
  ///
  /// In en, this message translates to:
  /// **'Flight Recorder'**
  String get flightRecorder;

  /// No description provided for @fuelCost.
  ///
  /// In en, this message translates to:
  /// **'Fuel Cost'**
  String get fuelCost;

  /// No description provided for @hudDisplay.
  ///
  /// In en, this message translates to:
  /// **'HUD Display'**
  String get hudDisplay;

  /// No description provided for @connectedToEcu.
  ///
  /// In en, this message translates to:
  /// **'Connected to ECU'**
  String get connectedToEcu;

  /// No description provided for @adapterReadyTurnKey.
  ///
  /// In en, this message translates to:
  /// **'Adapter Ready (Turn Key to ON/RUN)'**
  String get adapterReadyTurnKey;

  /// No description provided for @connectingObdAdapter.
  ///
  /// In en, this message translates to:
  /// **'Connecting to OBD Adapter...'**
  String get connectingObdAdapter;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @switchAdapter.
  ///
  /// In en, this message translates to:
  /// **'Switch Adapter'**
  String get switchAdapter;

  /// No description provided for @batterySummary.
  ///
  /// In en, this message translates to:
  /// **'Battery: {voltage}V | {summary}'**
  String batterySummary(Object summary, Object voltage);

  /// No description provided for @batteryVehicle.
  ///
  /// In en, this message translates to:
  /// **'Battery: {voltage}V | Vehicle: {model}'**
  String batteryVehicle(Object model, Object voltage);

  /// No description provided for @genericVehicle.
  ///
  /// In en, this message translates to:
  /// **'Generic'**
  String get genericVehicle;

  /// No description provided for @fullVehicleTest.
  ///
  /// In en, this message translates to:
  /// **'1-Click Full Vehicle Test'**
  String get fullVehicleTest;

  /// No description provided for @selectedProfileNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Selected profile (not connected): {name}'**
  String selectedProfileNotConnected(Object name);

  /// No description provided for @tapToSelectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Tap to select vehicle & start full test'**
  String get tapToSelectVehicle;

  /// No description provided for @fullScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'10-stage full network scan, deep health index & PDF report'**
  String get fullScanSubtitle;

  /// No description provided for @quickScan30s.
  ///
  /// In en, this message translates to:
  /// **'Quick Scan (30s)'**
  String get quickScan30s;

  /// No description provided for @quickScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Instant 30s vehicle scan: DTCs, Live Sensors, VIN & Voltage'**
  String get quickScanSubtitle;

  /// No description provided for @connectAdapterFirst.
  ///
  /// In en, this message translates to:
  /// **'Please connect to a real OBD adapter (Bluetooth Classic, BLE, Wi-Fi, or USB OTG) first.'**
  String get connectAdapterFirst;

  /// No description provided for @workshopSettings.
  ///
  /// In en, this message translates to:
  /// **'Workshop & Center Settings'**
  String get workshopSettings;

  /// No description provided for @workshopBrandingSaved.
  ///
  /// In en, this message translates to:
  /// **'Workshop branding and alarm settings saved successfully! ✅'**
  String get workshopBrandingSaved;

  /// No description provided for @suiteTagline.
  ///
  /// In en, this message translates to:
  /// **'Automotive Diagnostic & Fleet Telemetry Suite'**
  String get suiteTagline;

  /// No description provided for @copyNumber.
  ///
  /// In en, this message translates to:
  /// **'Copy Number'**
  String get copyNumber;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied to clipboard'**
  String get phoneCopied;

  /// No description provided for @workshopInfoPdf.
  ///
  /// In en, this message translates to:
  /// **'Workshop Information (PDF Reports):'**
  String get workshopInfoPdf;

  /// No description provided for @workshopCenterName.
  ///
  /// In en, this message translates to:
  /// **'Workshop Center Name'**
  String get workshopCenterName;

  /// No description provided for @workshopAddress.
  ///
  /// In en, this message translates to:
  /// **'Workshop Address'**
  String get workshopAddress;

  /// No description provided for @defaultInspectionEngineer.
  ///
  /// In en, this message translates to:
  /// **'Default Inspection Engineer'**
  String get defaultInspectionEngineer;

  /// No description provided for @standardInspectionFee.
  ///
  /// In en, this message translates to:
  /// **'Standard Inspection Fee'**
  String get standardInspectionFee;

  /// No description provided for @safetyThresholdsAlarms.
  ///
  /// In en, this message translates to:
  /// **'Safety Thresholds & Real-Time Alarms:'**
  String get safetyThresholdsAlarms;

  /// No description provided for @enableAlarmSounds.
  ///
  /// In en, this message translates to:
  /// **'Enable Alarm Sounds & Haptic Vibrate'**
  String get enableAlarmSounds;

  /// No description provided for @alarmSoundsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Triggers popup alert and haptic feedback when a sensor exceeds safe limits'**
  String get alarmSoundsSubtitle;

  /// No description provided for @engineOverheatLimit.
  ///
  /// In en, this message translates to:
  /// **'Engine Overheating Alarm Limit:'**
  String get engineOverheatLimit;

  /// No description provided for @alternatorLowVoltage.
  ///
  /// In en, this message translates to:
  /// **'Alternator Low Voltage Limit:'**
  String get alternatorLowVoltage;

  /// No description provided for @cloudBackupSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup & Fleet Webhook Sync'**
  String get cloudBackupSync;

  /// No description provided for @obdAdapterAutoReconnect.
  ///
  /// In en, this message translates to:
  /// **'OBD Adapter & Auto-Reconnect'**
  String get obdAdapterAutoReconnect;

  /// No description provided for @autoReconnectLaunch.
  ///
  /// In en, this message translates to:
  /// **'Auto-reconnect on app launch'**
  String get autoReconnectLaunch;

  /// No description provided for @autoReconnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically connects to the last paired adapter on startup'**
  String get autoReconnectSubtitle;

  /// No description provided for @pairedObdAdapter.
  ///
  /// In en, this message translates to:
  /// **'Paired OBD Adapter'**
  String get pairedObdAdapter;

  /// No description provided for @forget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forget;

  /// No description provided for @noSavedAdapterYet.
  ///
  /// In en, this message translates to:
  /// **'No saved adapter yet. Connect your adapter to save it for auto-reconnect.'**
  String get noSavedAdapterYet;

  /// No description provided for @saveWorkshopSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Workshop Settings'**
  String get saveWorkshopSettings;

  /// No description provided for @connectionTitle.
  ///
  /// In en, this message translates to:
  /// **'ELM327 Connection Manager'**
  String get connectionTitle;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @autoDetectConnect.
  ///
  /// In en, this message translates to:
  /// **'Auto Detect & Connect'**
  String get autoDetectConnect;

  /// No description provided for @pairedDevicesOs.
  ///
  /// In en, this message translates to:
  /// **'Paired Devices (OS Settings)'**
  String get pairedDevicesOs;

  /// No description provided for @noPairedDevices.
  ///
  /// In en, this message translates to:
  /// **'No paired Bluetooth devices found'**
  String get noPairedDevices;

  /// No description provided for @discoveredDevices.
  ///
  /// In en, this message translates to:
  /// **'Nearby Discovered Devices'**
  String get discoveredDevices;

  /// No description provided for @unknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Generic Device'**
  String get unknownDevice;

  /// No description provided for @wifiSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'ELM327 Wi-Fi Configuration:'**
  String get wifiSettingsTitle;

  /// No description provided for @wifiDescription.
  ///
  /// In en, this message translates to:
  /// **'Most Wi-Fi OBD adapters in Egypt broadcast an SSID named \'WiFi_OBDII\' and use default IP 192.168.0.10 on port 35000.'**
  String get wifiDescription;

  /// No description provided for @adapterAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Adapter Address (IP:Port)'**
  String get adapterAddressLabel;

  /// No description provided for @connectWifi.
  ///
  /// In en, this message translates to:
  /// **'Connect via Wi-Fi'**
  String get connectWifi;

  /// No description provided for @protocolPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'Protocol: '**
  String get protocolPickerLabel;

  /// No description provided for @checkAdapter20s.
  ///
  /// In en, this message translates to:
  /// **'Check adapter (about 20 s)'**
  String get checkAdapter20s;

  /// No description provided for @adapterCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Adapter check'**
  String get adapterCheckTitle;

  /// No description provided for @readModulesUds.
  ///
  /// In en, this message translates to:
  /// **'Read modules, UDS (read-only, CAN only)'**
  String get readModulesUds;

  /// No description provided for @modulesUdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Modules (UDS)'**
  String get modulesUdsTitle;

  /// No description provided for @lastAttempt.
  ///
  /// In en, this message translates to:
  /// **'Last attempt:'**
  String get lastAttempt;

  /// No description provided for @retryEcuHandshake.
  ///
  /// In en, this message translates to:
  /// **'Retry ECU Handshake (Key in ON/RUN)'**
  String get retryEcuHandshake;

  /// No description provided for @quickReconnect.
  ///
  /// In en, this message translates to:
  /// **'Quick Reconnect: {name} ({type})'**
  String quickReconnect(Object name, Object type);

  /// No description provided for @autoDetectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Probes USB-OTG / Paired Serial, BT Classic, BLE 5.0 & Wi-Fi automatically + auto-detects car VIN/Model'**
  String get autoDetectSubtitle;

  /// No description provided for @autoDetecting.
  ///
  /// In en, this message translates to:
  /// **'Auto-Detecting...'**
  String get autoDetecting;

  /// No description provided for @autoDetectAnyAdapter.
  ///
  /// In en, this message translates to:
  /// **'Auto-Detect & Connect Any OBD Adapter'**
  String get autoDetectAnyAdapter;

  /// No description provided for @connectedToAdapter.
  ///
  /// In en, this message translates to:
  /// **'Connected to {adapter}!'**
  String connectedToAdapter(Object adapter);

  /// No description provided for @scanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanning;

  /// No description provided for @scanNearby.
  ///
  /// In en, this message translates to:
  /// **'Scan Nearby'**
  String get scanNearby;

  /// No description provided for @refreshPaired.
  ///
  /// In en, this message translates to:
  /// **'Refresh Paired'**
  String get refreshPaired;

  /// No description provided for @pairedNonAndroidNote.
  ///
  /// In en, this message translates to:
  /// **'On laptop/desktop or non-Android devices, check USB / Serial tab for paired Bluetooth COM/cu ports or BLE 5.0 tab.'**
  String get pairedNonAndroidNote;

  /// No description provided for @listeningNearby.
  ///
  /// In en, this message translates to:
  /// **'Listening for nearby Bluetooth adapters...'**
  String get listeningNearby;

  /// No description provided for @pairedBadge.
  ///
  /// In en, this message translates to:
  /// **'Paired'**
  String get pairedBadge;

  /// No description provided for @nearbyBadge.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearbyBadge;

  /// No description provided for @chipLabel.
  ///
  /// In en, this message translates to:
  /// **'Chip: {chip}'**
  String chipLabel(Object chip);

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(Object score);

  /// No description provided for @autoProbeWifi.
  ///
  /// In en, this message translates to:
  /// **'Auto-Probe Active Wi-Fi OBD Gateway'**
  String get autoProbeWifi;

  /// No description provided for @noWifiGateway.
  ///
  /// In en, this message translates to:
  /// **'No Wi-Fi ELM327 gateway responded on standard ports.'**
  String get noWifiGateway;

  /// No description provided for @bleTitle.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Low Energy (BLE 4.0 / 5.0 GATT)'**
  String get bleTitle;

  /// No description provided for @bleDescription.
  ///
  /// In en, this message translates to:
  /// **'Scans live nearby BLE peripherals supporting Nordic UART (6E400001), 0xFFF0 (Veepeak/Vgate), 0x18F0 (OBDLink/vLinker), and 0xFFE0 GATT characteristics.'**
  String get bleDescription;

  /// No description provided for @scanningBle.
  ///
  /// In en, this message translates to:
  /// **'Scanning Nearby BLE Peripherals...'**
  String get scanningBle;

  /// No description provided for @scanBleAdapters.
  ///
  /// In en, this message translates to:
  /// **'Scan Nearby BLE OBD Adapters'**
  String get scanBleAdapters;

  /// No description provided for @bleScanResults.
  ///
  /// In en, this message translates to:
  /// **'Live BLE Scan Results ({count})'**
  String bleScanResults(Object count);

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @searchingBle.
  ///
  /// In en, this message translates to:
  /// **'Searching BLE advertisements...'**
  String get searchingBle;

  /// No description provided for @tapScanBle.
  ///
  /// In en, this message translates to:
  /// **'Tap \'Scan Nearby BLE OBD Adapters\' above to discover powered BLE dongles.'**
  String get tapScanBle;

  /// No description provided for @bleIdRssi.
  ///
  /// In en, this message translates to:
  /// **'ID: {id} • RSSI: {rssi} dBm'**
  String bleIdRssi(Object id, Object rssi);

  /// No description provided for @manualBleId.
  ///
  /// In en, this message translates to:
  /// **'Manual BLE Remote ID / Address:'**
  String get manualBleId;

  /// No description provided for @bleIdHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 00:1B:10:E2:33:44 or device UUID'**
  String get bleIdHint;

  /// No description provided for @usbSerialTitle.
  ///
  /// In en, this message translates to:
  /// **'USB OTG & Serial / Paired COM Ports'**
  String get usbSerialTitle;

  /// No description provided for @usbSerialDescription.
  ///
  /// In en, this message translates to:
  /// **'Real Android USB-OTG drivers (FTDI, CH340, CP2102, PL2303, CDC-ACM) plus macOS/Linux POSIX serial & paired Bluetooth serial ports (/dev/cu.*).'**
  String get usbSerialDescription;

  /// No description provided for @enumeratingPorts.
  ///
  /// In en, this message translates to:
  /// **'Enumerating Attached Ports...'**
  String get enumeratingPorts;

  /// No description provided for @refreshUsbDevices.
  ///
  /// In en, this message translates to:
  /// **'Refresh Attached USB / Serial Devices'**
  String get refreshUsbDevices;

  /// No description provided for @detectedSerialPorts.
  ///
  /// In en, this message translates to:
  /// **'Detected Hardware Serial Ports ({count}):'**
  String detectedSerialPorts(Object count);

  /// No description provided for @noUsbDetected.
  ///
  /// In en, this message translates to:
  /// **'No USB OTG cables or OBD serial ports detected right now. Plug in USB cable or pair Bluetooth adapter, then tap Refresh.'**
  String get noUsbDetected;

  /// No description provided for @portLine.
  ///
  /// In en, this message translates to:
  /// **'Port: {port} • {transport}'**
  String portLine(Object port, Object transport);

  /// No description provided for @manualSerialOverride.
  ///
  /// In en, this message translates to:
  /// **'Manual Serial Port / Baud Override'**
  String get manualSerialOverride;

  /// No description provided for @serialPortPathLabel.
  ///
  /// In en, this message translates to:
  /// **'USB / Serial Port Path or Device ID'**
  String get serialPortPathLabel;

  /// No description provided for @uartBaudRate.
  ///
  /// In en, this message translates to:
  /// **'UART Baud Rate: '**
  String get uartBaudRate;

  /// No description provided for @openSerialPort.
  ///
  /// In en, this message translates to:
  /// **'Open Specified Serial Port'**
  String get openSerialPort;

  /// No description provided for @noDtcsFound.
  ///
  /// In en, this message translates to:
  /// **'No trouble codes found. ECU reports healthy status!'**
  String get noDtcsFound;

  /// No description provided for @vinLabel.
  ///
  /// In en, this message translates to:
  /// **'Chassis Number (VIN):'**
  String get vinLabel;

  /// No description provided for @protocolLabel.
  ///
  /// In en, this message translates to:
  /// **'Active Protocol:'**
  String get protocolLabel;

  /// No description provided for @batteryVoltageLabel.
  ///
  /// In en, this message translates to:
  /// **'Battery Voltage:'**
  String get batteryVoltageLabel;

  /// No description provided for @milStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'MIL (Check Engine) Status:'**
  String get milStatusLabel;

  /// No description provided for @milOn.
  ///
  /// In en, this message translates to:
  /// **'ON (Active Trouble Codes)'**
  String get milOn;

  /// No description provided for @milOff.
  ///
  /// In en, this message translates to:
  /// **'OFF (No Active Faults)'**
  String get milOff;

  /// No description provided for @saveReport.
  ///
  /// In en, this message translates to:
  /// **'Save Inspection Report'**
  String get saveReport;

  /// No description provided for @rescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan'**
  String get rescan;

  /// No description provided for @scanningVinMil.
  ///
  /// In en, this message translates to:
  /// **'Scanning VIN, MIL status, DTCs, and system voltage...'**
  String get scanningVinMil;

  /// No description provided for @detectedDtcs.
  ///
  /// In en, this message translates to:
  /// **'Detected Trouble Codes ({count}):'**
  String detectedDtcs(Object count);

  /// No description provided for @activeFaults.
  ///
  /// In en, this message translates to:
  /// **'Active Faults'**
  String get activeFaults;

  /// No description provided for @optimalHealth.
  ///
  /// In en, this message translates to:
  /// **'Engine & Emissions in Optimal Health'**
  String get optimalHealth;

  /// No description provided for @codesDetectedCel.
  ///
  /// In en, this message translates to:
  /// **'Trouble Codes Detected & Check Engine Active!'**
  String get codesDetectedCel;

  /// No description provided for @noMisfires.
  ///
  /// In en, this message translates to:
  /// **'No misfires, catalyst, or emission-related trouble codes logged in ECU.'**
  String get noMisfires;

  /// No description provided for @saveJobCard.
  ///
  /// In en, this message translates to:
  /// **'Save Inspection Job Card:'**
  String get saveJobCard;

  /// No description provided for @licensePlateLabel.
  ///
  /// In en, this message translates to:
  /// **'License Plate (e.g. ABC 1234)'**
  String get licensePlateLabel;

  /// No description provided for @customerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customerName;

  /// No description provided for @phoneWhatsappNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone / WhatsApp Number'**
  String get phoneWhatsappNumber;

  /// No description provided for @enterPlate.
  ///
  /// In en, this message translates to:
  /// **'Please enter the license plate number'**
  String get enterPlate;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @jobCardSaved.
  ///
  /// In en, this message translates to:
  /// **'Job card saved successfully!'**
  String get jobCardSaved;

  /// No description provided for @readDtcs.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Codes (DTCs)'**
  String get readDtcs;

  /// No description provided for @storedDtcs.
  ///
  /// In en, this message translates to:
  /// **'Confirmed Trouble Codes (Mode 03)'**
  String get storedDtcs;

  /// No description provided for @pendingDtcs.
  ///
  /// In en, this message translates to:
  /// **'Pending Trouble Codes (Mode 07)'**
  String get pendingDtcs;

  /// No description provided for @permanentDtcs.
  ///
  /// In en, this message translates to:
  /// **'Permanent Trouble Codes (Mode 0A)'**
  String get permanentDtcs;

  /// No description provided for @searchDtcHint.
  ///
  /// In en, this message translates to:
  /// **'Search DTC code or keyword (e.g., P0300, Misfire)...'**
  String get searchDtcHint;

  /// No description provided for @clearDtcsButton.
  ///
  /// In en, this message translates to:
  /// **'Clear Trouble Codes & Reset MIL (Mode 04)'**
  String get clearDtcsButton;

  /// No description provided for @dtcsClearedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic trouble codes cleared and MIL light reset successfully!'**
  String get dtcsClearedSuccess;

  /// No description provided for @dtcsClearedFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear trouble codes. Ensure Key is ON and Engine is OFF.'**
  String get dtcsClearedFail;

  /// No description provided for @clearPartialRemaining.
  ///
  /// In en, this message translates to:
  /// **'The ECU accepted the clear but {count} code(s) are still stored: {codes}. The fault is probably still present.'**
  String clearPartialRemaining(Object codes, Object count);

  /// No description provided for @clearUnconfirmed.
  ///
  /// In en, this message translates to:
  /// **'The ECU accepted the clear but the read-back could not confirm it. Read the codes again.'**
  String get clearUnconfirmed;

  /// No description provided for @noStoredDtcs.
  ///
  /// In en, this message translates to:
  /// **'No confirmed trouble codes found.'**
  String get noStoredDtcs;

  /// No description provided for @noPendingDtcs.
  ///
  /// In en, this message translates to:
  /// **'No pending trouble codes found.'**
  String get noPendingDtcs;

  /// No description provided for @noPermanentDtcs.
  ///
  /// In en, this message translates to:
  /// **'No permanent trouble codes found.'**
  String get noPermanentDtcs;

  /// No description provided for @rescanDtcs.
  ///
  /// In en, this message translates to:
  /// **'Rescan DTCs'**
  String get rescanDtcs;

  /// No description provided for @noDtcsMatching.
  ///
  /// In en, this message translates to:
  /// **'No diagnostic trouble codes found matching \'{query}\''**
  String noDtcsMatching(Object query);

  /// No description provided for @liveSensorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Sensors'**
  String get liveSensorsTitle;

  /// No description provided for @liveGraphsTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Waveforms (Graphs)'**
  String get liveGraphsTitle;

  /// No description provided for @discoverPids.
  ///
  /// In en, this message translates to:
  /// **'Discover Supported PIDs'**
  String get discoverPids;

  /// No description provided for @pausePolling.
  ///
  /// In en, this message translates to:
  /// **'Pause Live Polling'**
  String get pausePolling;

  /// No description provided for @startPolling.
  ///
  /// In en, this message translates to:
  /// **'Start Live Polling'**
  String get startPolling;

  /// No description provided for @allSensors.
  ///
  /// In en, this message translates to:
  /// **'All Sensors'**
  String get allSensors;

  /// No description provided for @engineSensors.
  ///
  /// In en, this message translates to:
  /// **'Engine & Speed'**
  String get engineSensors;

  /// No description provided for @coolingSensors.
  ///
  /// In en, this message translates to:
  /// **'Cooling System'**
  String get coolingSensors;

  /// No description provided for @electricalSensors.
  ///
  /// In en, this message translates to:
  /// **'Electrical & Battery'**
  String get electricalSensors;

  /// No description provided for @fuelAir.
  ///
  /// In en, this message translates to:
  /// **'Fuel & Air'**
  String get fuelAir;

  /// No description provided for @railTurbo.
  ///
  /// In en, this message translates to:
  /// **'Rail & Turbo'**
  String get railTurbo;

  /// No description provided for @transmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmission;

  /// No description provided for @absSpeeds.
  ///
  /// In en, this message translates to:
  /// **'4-Wheel ABS'**
  String get absSpeeds;

  /// No description provided for @oemCustom.
  ///
  /// In en, this message translates to:
  /// **'OEM Custom'**
  String get oemCustom;

  /// No description provided for @noSensorsCategory.
  ///
  /// In en, this message translates to:
  /// **'No sensors found in this category'**
  String get noSensorsCategory;

  /// No description provided for @variance5.
  ///
  /// In en, this message translates to:
  /// **'Variance > 5 km/h'**
  String get variance5;

  /// No description provided for @disableDual.
  ///
  /// In en, this message translates to:
  /// **'Disable Dual Channel'**
  String get disableDual;

  /// No description provided for @enableDual.
  ///
  /// In en, this message translates to:
  /// **'Enable Dual Channel'**
  String get enableDual;

  /// No description provided for @channel1.
  ///
  /// In en, this message translates to:
  /// **'Channel 1 (Yellow):'**
  String get channel1;

  /// No description provided for @channel2.
  ///
  /// In en, this message translates to:
  /// **'Channel 2 Comparison (Cyan):'**
  String get channel2;

  /// No description provided for @freezeFrameTitle.
  ///
  /// In en, this message translates to:
  /// **'Freeze Frame Data'**
  String get freezeFrameTitle;

  /// No description provided for @refreshFreezeFrame.
  ///
  /// In en, this message translates to:
  /// **'Refresh Freeze Frame'**
  String get refreshFreezeFrame;

  /// No description provided for @queryingFreezeFrame.
  ///
  /// In en, this message translates to:
  /// **'Querying Freeze Frame data from ECU (Mode 02)...'**
  String get queryingFreezeFrame;

  /// No description provided for @noFreezeFrame.
  ///
  /// In en, this message translates to:
  /// **'No Freeze Frame logged in ECU memory'**
  String get noFreezeFrame;

  /// No description provided for @freezeFrameStoredWhen.
  ///
  /// In en, this message translates to:
  /// **'Freeze frame data is stored only when a confirmed DTC is first triggered'**
  String get freezeFrameStoredWhen;

  /// No description provided for @triggeringFaultCode.
  ///
  /// In en, this message translates to:
  /// **'Triggering Fault Code:'**
  String get triggeringFaultCode;

  /// No description provided for @sensorSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Sensor Snapshot at Event Occurrence:'**
  String get sensorSnapshot;

  /// No description provided for @engineSpeedRpm.
  ///
  /// In en, this message translates to:
  /// **'Engine Speed (RPM):'**
  String get engineSpeedRpm;

  /// No description provided for @vehicleSpeedLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Speed:'**
  String get vehicleSpeedLabel;

  /// No description provided for @coolantTempLabel.
  ///
  /// In en, this message translates to:
  /// **'Coolant Temperature:'**
  String get coolantTempLabel;

  /// No description provided for @engineLoadLabel.
  ///
  /// In en, this message translates to:
  /// **'Calculated Engine Load:'**
  String get engineLoadLabel;

  /// No description provided for @throttlePositionLabel.
  ///
  /// In en, this message translates to:
  /// **'Throttle Position (TPS):'**
  String get throttlePositionLabel;

  /// No description provided for @manifoldPressureLabel.
  ///
  /// In en, this message translates to:
  /// **'Manifold Absolute Pressure:'**
  String get manifoldPressureLabel;

  /// No description provided for @intakeAirTempLabel.
  ///
  /// In en, this message translates to:
  /// **'Intake Air Temp (IAT):'**
  String get intakeAirTempLabel;

  /// No description provided for @stftLabel.
  ///
  /// In en, this message translates to:
  /// **'Short Term Fuel Trim (STFT):'**
  String get stftLabel;

  /// No description provided for @ltftLabel.
  ///
  /// In en, this message translates to:
  /// **'Long Term Fuel Trim (LTFT):'**
  String get ltftLabel;

  /// No description provided for @workshopAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Workshop Analysis & Operating Context:'**
  String get workshopAnalysis;

  /// No description provided for @faultContextLine1.
  ///
  /// In en, this message translates to:
  /// **'This fault was triggered while driving at {speed} km/h with engine running at {rpm} RPM and coolant at {coolant}°C.'**
  String faultContextLine1(Object coolant, Object rpm, Object speed);

  /// No description provided for @faultContextLine2.
  ///
  /// In en, this message translates to:
  /// **'Long Term Fuel Trim was ({ltft}%), indicating the ECU was compensating for a {condition} at the moment the fault occurred.'**
  String faultContextLine2(Object condition, Object ltft);

  /// No description provided for @leanCondition.
  ///
  /// In en, this message translates to:
  /// **'lean condition (intake vacuum leak or low fuel pressure)'**
  String get leanCondition;

  /// No description provided for @richCondition.
  ///
  /// In en, this message translates to:
  /// **'rich condition (dripping injector or restricted air intake)'**
  String get richCondition;

  /// No description provided for @normalCondition.
  ///
  /// In en, this message translates to:
  /// **'normal air-fuel ratio'**
  String get normalCondition;

  /// No description provided for @codesNeedInspection.
  ///
  /// In en, this message translates to:
  /// **'{count} diagnostic trouble code(s) detected requiring technical inspection.'**
  String codesNeedInspection(Object count);

  /// No description provided for @absCompareTitle.
  ///
  /// In en, this message translates to:
  /// **'4-Wheel Independent ABS Speeds'**
  String get absCompareTitle;

  /// No description provided for @targetVsActual.
  ///
  /// In en, this message translates to:
  /// **'Target vs Actual OEM Tracking'**
  String get targetVsActual;

  /// No description provided for @railPressure.
  ///
  /// In en, this message translates to:
  /// **'Common Rail Fuel Pressure'**
  String get railPressure;

  /// No description provided for @turboBoost.
  ///
  /// In en, this message translates to:
  /// **'Turbo Boost Pressure'**
  String get turboBoost;

  /// No description provided for @actualValue.
  ///
  /// In en, this message translates to:
  /// **'Actual: {value}'**
  String actualValue(Object value);

  /// No description provided for @targetValue.
  ///
  /// In en, this message translates to:
  /// **'Target: {value}'**
  String targetValue(Object value);

  /// No description provided for @inspectionReports.
  ///
  /// In en, this message translates to:
  /// **'Inspection Reports'**
  String get inspectionReports;

  /// No description provided for @cloudBackupTooltip.
  ///
  /// In en, this message translates to:
  /// **'Cloud Backup & Fleet Sync'**
  String get cloudBackupTooltip;

  /// No description provided for @searchReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by plate number, VIN, or customer...'**
  String get searchReportsHint;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No saved inspection reports found'**
  String get noReportsFound;

  /// No description provided for @noReportsHint.
  ///
  /// In en, this message translates to:
  /// **'Run a \'Quick Scan\' to generate and save customer inspection reports'**
  String get noReportsHint;

  /// No description provided for @deleteReportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReportTooltip;

  /// No description provided for @reportCustomerLine.
  ///
  /// In en, this message translates to:
  /// **'Customer: {p0} | Phone: {p1}'**
  String reportCustomerLine(String p0, String p1);

  /// No description provided for @reportDateLine.
  ///
  /// In en, this message translates to:
  /// **'Date: {p0}'**
  String reportDateLine(String p0);

  /// No description provided for @allSystemsClear.
  ///
  /// In en, this message translates to:
  /// **'All Systems Clear'**
  String get allSystemsClear;

  /// No description provided for @troubleCodesCount.
  ///
  /// In en, this message translates to:
  /// **'{p0} Trouble Codes'**
  String troubleCodesCount(String p0);

  /// No description provided for @voltageLine.
  ///
  /// In en, this message translates to:
  /// **'Voltage: {p0}V'**
  String voltageLine(String p0);

  /// No description provided for @reportNotesLine.
  ///
  /// In en, this message translates to:
  /// **'Technician Notes: {p0}'**
  String reportNotesLine(String p0);

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get exportPdf;

  /// No description provided for @shareWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Share with Customer via WhatsApp'**
  String get shareWhatsapp;

  /// No description provided for @vehicleProfiles.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Vehicle Profiles'**
  String get vehicleProfiles;

  /// No description provided for @searchVehicles.
  ///
  /// In en, this message translates to:
  /// **'Search vehicles (Make, Model, Year, Engine)...'**
  String get searchVehicles;

  /// No description provided for @tabEgyptianPresets.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Presets'**
  String get tabEgyptianPresets;

  /// No description provided for @tabGlobalBrands.
  ///
  /// In en, this message translates to:
  /// **'250+ Global Brands'**
  String get tabGlobalBrands;

  /// No description provided for @noProfilesFound.
  ///
  /// In en, this message translates to:
  /// **'No vehicle profiles found in \'{p0}\' matching \'{p1}\''**
  String noProfilesFound(String p0, String p1);

  /// No description provided for @noBrandsFound.
  ///
  /// In en, this message translates to:
  /// **'No brands found for \'{p0}\' matching \'{p1}\''**
  String noBrandsFound(String p0, String p1);

  /// No description provided for @activeProfile.
  ///
  /// In en, this message translates to:
  /// **'Active Profile'**
  String get activeProfile;

  /// No description provided for @activateProfile.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateProfile;

  /// No description provided for @fullTest.
  ///
  /// In en, this message translates to:
  /// **'Full Test'**
  String get fullTest;

  /// No description provided for @engineLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engineLabel;

  /// No description provided for @transmissionLabel.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get transmissionLabel;

  /// No description provided for @workshopNote.
  ///
  /// In en, this message translates to:
  /// **'Workshop Note'**
  String get workshopNote;

  /// No description provided for @addCustomPid.
  ///
  /// In en, this message translates to:
  /// **'Add Custom PID'**
  String get addCustomPid;

  /// No description provided for @egyptianPresetsCount.
  ///
  /// In en, this message translates to:
  /// **'{p0} Egyptian Presets'**
  String egyptianPresetsCount(String p0);

  /// No description provided for @genericUdsObd2.
  ///
  /// In en, this message translates to:
  /// **'Generic UDS / OBD2'**
  String get genericUdsObd2;

  /// No description provided for @selectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get selectModel;

  /// No description provided for @activatedGenericProfile.
  ///
  /// In en, this message translates to:
  /// **'Activated generic diagnostic profile for {p0}'**
  String activatedGenericProfile(String p0);

  /// No description provided for @brandModelsTitle.
  ///
  /// In en, this message translates to:
  /// **'{p0} Models'**
  String brandModelsTitle(String p0);

  /// No description provided for @testShort.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get testShort;

  /// No description provided for @readinessMonitors.
  ///
  /// In en, this message translates to:
  /// **'Emissions Readiness Monitors'**
  String get readinessMonitors;

  /// No description provided for @refreshReadiness.
  ///
  /// In en, this message translates to:
  /// **'Refresh Readiness'**
  String get refreshReadiness;

  /// No description provided for @readinessQuerying.
  ///
  /// In en, this message translates to:
  /// **'Querying I/M Readiness drive cycle monitors (Mode 01 PID 01)...'**
  String get readinessQuerying;

  /// No description provided for @readinessNoData.
  ///
  /// In en, this message translates to:
  /// **'No readiness monitor data retrieved yet'**
  String get readinessNoData;

  /// No description provided for @readinessAllReady.
  ///
  /// In en, this message translates to:
  /// **'All Drive Cycle Monitors Ready'**
  String get readinessAllReady;

  /// No description provided for @readinessIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Monitors Detected ({p0})'**
  String readinessIncomplete(String p0);

  /// No description provided for @readinessSummary.
  ///
  /// In en, this message translates to:
  /// **'Ready: {p0} | Incomplete: {p1} | Check Engine: {p2}'**
  String readinessSummary(String p0, String p1, String p2);

  /// No description provided for @readinessTip.
  ///
  /// In en, this message translates to:
  /// **'Pre-purchase Inspection Tip: If the Check Engine Light is OFF but several monitors show \'Incomplete\', this indicates fault codes were cleared recently to temporarily hide the light without completing a full drive cycle!'**
  String get readinessTip;

  /// No description provided for @readinessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Subsystem Readiness Status:'**
  String get readinessSubtitle;

  /// No description provided for @badgeUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Unsupported'**
  String get badgeUnsupported;

  /// No description provided for @badgeReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get badgeReady;

  /// No description provided for @badgeIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get badgeIncomplete;

  /// No description provided for @refreshEcuDetails.
  ///
  /// In en, this message translates to:
  /// **'Refresh ECU Details'**
  String get refreshEcuDetails;

  /// No description provided for @ecuQuerying.
  ///
  /// In en, this message translates to:
  /// **'Querying VIN and calibration identification numbers (Mode 09)...'**
  String get ecuQuerying;

  /// No description provided for @ecuModuleLabel.
  ///
  /// In en, this message translates to:
  /// **'Electronic Control Module:'**
  String get ecuModuleLabel;

  /// No description provided for @ecuDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Engine Control Module (ECM/PCM)'**
  String get ecuDefaultName;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not Available'**
  String get notAvailable;

  /// No description provided for @notDetected.
  ///
  /// In en, this message translates to:
  /// **'Not Detected'**
  String get notDetected;

  /// No description provided for @calIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Calibration ID (CALID):'**
  String get calIdLabel;

  /// No description provided for @calIdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Software revision and firmware version installed on the engine control unit'**
  String get calIdSubtitle;

  /// No description provided for @cvnLabel.
  ///
  /// In en, this message translates to:
  /// **'Calibration Verification Number (CVN):'**
  String get cvnLabel;

  /// No description provided for @cvnSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cryptographic checksum ensuring software calibration integrity and authenticity'**
  String get cvnSubtitle;

  /// No description provided for @vinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Standard vehicle electronic identification number stored in ECU flash memory'**
  String get vinSubtitle;

  /// No description provided for @protocolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Active serial communications bus protocol over OBD-II DLC connector'**
  String get protocolSubtitle;

  /// No description provided for @ecuTechNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Technician Note (ECU Software & Remap Check):'**
  String get ecuTechNoteTitle;

  /// No description provided for @ecuTechNoteBody.
  ///
  /// In en, this message translates to:
  /// **'CALID and CVN codes are used by service centers to verify whether vehicle software has been altered with aftermarket ECU tunes/remaps, or if an official OEM factory reflash is needed to resolve technical service bulletins.'**
  String get ecuTechNoteBody;

  /// No description provided for @terminalTitle.
  ///
  /// In en, this message translates to:
  /// **'OBD Terminal'**
  String get terminalTitle;

  /// No description provided for @clearTerminalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear Terminal Logs'**
  String get clearTerminalTooltip;

  /// No description provided for @terminalReadyHint.
  ///
  /// In en, this message translates to:
  /// **'ELM327 Serial Terminal Ready.\nType an AT or OBD command below or tap a quick shortcut above.'**
  String get terminalReadyHint;

  /// No description provided for @terminalInputHint.
  ///
  /// In en, this message translates to:
  /// **'Enter AT or OBD command (e.g. AT RV or 01 0C)...'**
  String get terminalInputHint;

  /// No description provided for @sendCommandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Send Command'**
  String get sendCommandTooltip;

  /// No description provided for @connectFirstSnack.
  ///
  /// In en, this message translates to:
  /// **'Please connect to OBD adapter first'**
  String get connectFirstSnack;

  /// No description provided for @qcResetAdapter.
  ///
  /// In en, this message translates to:
  /// **'Reset Adapter'**
  String get qcResetAdapter;

  /// No description provided for @qcReadBattery.
  ///
  /// In en, this message translates to:
  /// **'Read Battery'**
  String get qcReadBattery;

  /// No description provided for @qcActiveProtocol.
  ///
  /// In en, this message translates to:
  /// **'Active Protocol'**
  String get qcActiveProtocol;

  /// No description provided for @qcSupportedPids.
  ///
  /// In en, this message translates to:
  /// **'Supported PIDs 1-20'**
  String get qcSupportedPids;

  /// No description provided for @qcEngineRpm.
  ///
  /// In en, this message translates to:
  /// **'Engine RPM'**
  String get qcEngineRpm;

  /// No description provided for @qcVehicleSpeed.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Speed'**
  String get qcVehicleSpeed;

  /// No description provided for @qcReadStoredDtcs.
  ///
  /// In en, this message translates to:
  /// **'Read Stored DTCs'**
  String get qcReadStoredDtcs;

  /// No description provided for @qcReadPendingDtcs.
  ///
  /// In en, this message translates to:
  /// **'Read Pending DTCs'**
  String get qcReadPendingDtcs;

  /// No description provided for @qcReadVin.
  ///
  /// In en, this message translates to:
  /// **'Read VIN'**
  String get qcReadVin;

  /// No description provided for @mode06Title.
  ///
  /// In en, this message translates to:
  /// **'Mode \$06 Misfire & Component Monitor'**
  String get mode06Title;

  /// No description provided for @mode06ScanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Scan Mode \$06'**
  String get mode06ScanTooltip;

  /// No description provided for @mode06Summary.
  ///
  /// In en, this message translates to:
  /// **'Mode \$06 Summary: {p0} Monitors ({p1} Out-of-Spec)'**
  String mode06Summary(String p0, String p1);

  /// No description provided for @mode06Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Reads early cylinder misfire counters, catalyst & O2 margins before a Check Engine light triggers.'**
  String get mode06Subtitle;

  /// No description provided for @mode06ConnectFirst.
  ///
  /// In en, this message translates to:
  /// **'Connect an OBD adapter to query real-time Mode \$06 component monitors.'**
  String get mode06ConnectFirst;

  /// No description provided for @mode06Scanning.
  ///
  /// In en, this message translates to:
  /// **'Interrogating ECU Mode \$06 Test IDs...'**
  String get mode06Scanning;

  /// No description provided for @mode06NoResults.
  ///
  /// In en, this message translates to:
  /// **'No Mode \$06 test records returned by this ECU for the current filter.'**
  String get mode06NoResults;

  /// No description provided for @mode06Rescan.
  ///
  /// In en, this message translates to:
  /// **'Re-Scan Mode \$06'**
  String get mode06Rescan;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterMisfires.
  ///
  /// In en, this message translates to:
  /// **'Misfires'**
  String get filterMisfires;

  /// No description provided for @filterO2Cat.
  ///
  /// In en, this message translates to:
  /// **'O2 & Catalyst'**
  String get filterO2Cat;

  /// No description provided for @filterFailedOnly.
  ///
  /// In en, this message translates to:
  /// **'Failed Only'**
  String get filterFailedOnly;

  /// No description provided for @statusNoResult.
  ///
  /// In en, this message translates to:
  /// **'NO RESULT YET'**
  String get statusNoResult;

  /// No description provided for @statusInfo.
  ///
  /// In en, this message translates to:
  /// **'INFO'**
  String get statusInfo;

  /// No description provided for @statusPass.
  ///
  /// In en, this message translates to:
  /// **'PASS'**
  String get statusPass;

  /// No description provided for @statusFail.
  ///
  /// In en, this message translates to:
  /// **'FAIL'**
  String get statusFail;

  /// No description provided for @minLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Min: {p0} {p1}'**
  String minLimitLabel(String p0, String p1);

  /// No description provided for @maxLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Max: {p0} {p1}'**
  String maxLimitLabel(String p0, String p1);

  /// No description provided for @neverCompleted.
  ///
  /// In en, this message translates to:
  /// **'Never completed since codes were erased'**
  String get neverCompleted;

  /// No description provided for @constantNoLimits.
  ///
  /// In en, this message translates to:
  /// **'Constant (no limits)'**
  String get constantNoLimits;

  /// No description provided for @rawUnit.
  ///
  /// In en, this message translates to:
  /// **'(raw)'**
  String get rawUnit;

  /// No description provided for @sensorWord.
  ///
  /// In en, this message translates to:
  /// **'sensor'**
  String get sensorWord;

  /// No description provided for @rawLogTitle.
  ///
  /// In en, this message translates to:
  /// **'Raw log ({p0})'**
  String rawLogTitle(String p0);

  /// No description provided for @exportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTooltip;

  /// No description provided for @exportEvidenceTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export log + feature status'**
  String get exportEvidenceTooltip;

  /// No description provided for @clearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearTooltip;

  /// No description provided for @noCommandsYet.
  ///
  /// In en, this message translates to:
  /// **'No commands sent yet'**
  String get noCommandsYet;

  /// No description provided for @waitingForData.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waitingForData;

  /// No description provided for @protocolAutoSearch.
  ///
  /// In en, this message translates to:
  /// **'Auto (adapter searches all protocols)'**
  String get protocolAutoSearch;

  /// No description provided for @hwChipUsb.
  ///
  /// In en, this message translates to:
  /// **'USB / Serial'**
  String get hwChipUsb;

  /// No description provided for @hwChipBtClassic.
  ///
  /// In en, this message translates to:
  /// **'BT Classic SPP'**
  String get hwChipBtClassic;

  /// No description provided for @hwChipBle.
  ///
  /// In en, this message translates to:
  /// **'BLE 4.0 / 5.0'**
  String get hwChipBle;

  /// No description provided for @hwChipWifi.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi TCP'**
  String get hwChipWifi;

  /// No description provided for @hwChipAutoVin.
  ///
  /// In en, this message translates to:
  /// **'Auto Car VIN'**
  String get hwChipAutoVin;

  /// No description provided for @statusDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from adapter'**
  String get statusDisconnected;

  /// No description provided for @statusDisconnectedShort.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get statusDisconnectedShort;

  /// No description provided for @regionAll.
  ///
  /// In en, this message translates to:
  /// **'All Regions'**
  String get regionAll;

  /// No description provided for @regionAsian.
  ///
  /// In en, this message translates to:
  /// **'Asian'**
  String get regionAsian;

  /// No description provided for @regionEuropean.
  ///
  /// In en, this message translates to:
  /// **'European'**
  String get regionEuropean;

  /// No description provided for @regionAmerican.
  ///
  /// In en, this message translates to:
  /// **'American'**
  String get regionAmerican;

  /// No description provided for @regionChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get regionChinese;

  /// No description provided for @regionCommercial.
  ///
  /// In en, this message translates to:
  /// **'Commercial'**
  String get regionCommercial;

  /// No description provided for @statusConnectionLost.
  ///
  /// In en, this message translates to:
  /// **'{p0} connection lost'**
  String statusConnectionLost(String p0);

  /// No description provided for @statusLaunchingSimulator.
  ///
  /// In en, this message translates to:
  /// **'Launching ECU simulator...'**
  String get statusLaunchingSimulator;

  /// No description provided for @statusSimulatorFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to start simulator'**
  String get statusSimulatorFailed;

  /// No description provided for @statusConnectingBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Bluetooth adapter ({p0})...'**
  String statusConnectingBluetooth(String p0);

  /// No description provided for @statusBluetoothFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to adapter. Please check Bluetooth pairing and power.'**
  String get statusBluetoothFailed;

  /// No description provided for @statusConnectingWifi.
  ///
  /// In en, this message translates to:
  /// **'Connecting to Wi-Fi adapter ({p0})...'**
  String statusConnectingWifi(String p0);

  /// No description provided for @statusWifiFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Wi-Fi adapter. Ensure you are connected to its Wi-Fi network.'**
  String get statusWifiFailed;

  /// No description provided for @statusConnectingBle.
  ///
  /// In en, this message translates to:
  /// **'Connecting to BLE adapter ({p0})...'**
  String statusConnectingBle(String p0);

  /// No description provided for @statusBleGattFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not establish GATT connection with BLE adapter. Ensure adapter is powered and nearby.'**
  String get statusBleGattFailed;

  /// No description provided for @statusOpeningSerial.
  ///
  /// In en, this message translates to:
  /// **'Opening USB/Serial port ({p0})...'**
  String statusOpeningSerial(String p0);

  /// No description provided for @statusSerialFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open USB/Serial connection. Check cable, Bluetooth power, or permissions.'**
  String get statusSerialFailed;

  /// No description provided for @statusAutoDetecting.
  ///
  /// In en, this message translates to:
  /// **'Auto-detecting OBD adapter across USB, Bluetooth, BLE & Wi-Fi...'**
  String get statusAutoDetecting;

  /// No description provided for @statusCheckingRecent.
  ///
  /// In en, this message translates to:
  /// **'Checking recent adapter ({p0})...'**
  String statusCheckingRecent(String p0);

  /// No description provided for @statusCheckingUsb.
  ///
  /// In en, this message translates to:
  /// **'Checking USB-OTG & system serial ports...'**
  String get statusCheckingUsb;

  /// No description provided for @statusProbingSerial.
  ///
  /// In en, this message translates to:
  /// **'Probing Serial {p0} @ {p1} bps...'**
  String statusProbingSerial(String p0, String p1);

  /// No description provided for @statusScanningBle.
  ///
  /// In en, this message translates to:
  /// **'Scanning nearby BLE 4.0/5.0 OBD adapters...'**
  String get statusScanningBle;

  /// No description provided for @statusConnectingBleNamed.
  ///
  /// In en, this message translates to:
  /// **'Connecting to BLE adapter: {p0}...'**
  String statusConnectingBleNamed(String p0);

  /// No description provided for @statusProbingWifi.
  ///
  /// In en, this message translates to:
  /// **'Probing Wi-Fi ELM327 endpoints...'**
  String get statusProbingWifi;

  /// No description provided for @statusFoundWifi.
  ///
  /// In en, this message translates to:
  /// **'Found Wi-Fi OBD at {p0}. Connecting...'**
  String statusFoundWifi(String p0);

  /// No description provided for @statusNoAdapterFound.
  ///
  /// In en, this message translates to:
  /// **'No active OBD adapter found across USB, Bluetooth, BLE, or Wi-Fi. Plug into vehicle OBD-II port and retry.'**
  String get statusNoAdapterFound;

  /// No description provided for @statusAutoConnectFailed.
  ///
  /// In en, this message translates to:
  /// **'Auto-connect failed: {p0}'**
  String statusAutoConnectFailed(String p0);

  /// No description provided for @statusAuditing.
  ///
  /// In en, this message translates to:
  /// **'Auditing genuine multi-ECU telemetry for pre-purchase evaluation...'**
  String get statusAuditing;

  /// No description provided for @statusAuditDone.
  ///
  /// In en, this message translates to:
  /// **'Vehicle audit completed. Overall score: {p0}/100'**
  String statusAuditDone(String p0);

  /// No description provided for @statusEvaluating.
  ///
  /// In en, this message translates to:
  /// **'Evaluating available OBD adapters for auto-connection...'**
  String get statusEvaluating;

  /// No description provided for @statusNoBtDevices.
  ///
  /// In en, this message translates to:
  /// **'No Bluetooth devices available to auto-connect.'**
  String get statusNoBtDevices;

  /// No description provided for @statusBestMatched.
  ///
  /// In en, this message translates to:
  /// **'Best adapter matched: {p0} ({p1}). Connecting...'**
  String statusBestMatched(String p0, String p1);

  /// No description provided for @statusHandshakeFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete ELM327 handshake with paired Bluetooth devices.'**
  String get statusHandshakeFailed;

  /// No description provided for @statusRequestingBtPerm.
  ///
  /// In en, this message translates to:
  /// **'Requesting Bluetooth permissions...'**
  String get statusRequestingBtPerm;

  /// No description provided for @statusScanningPaired.
  ///
  /// In en, this message translates to:
  /// **'Scanning for paired Bluetooth OBD adapters...'**
  String get statusScanningPaired;

  /// No description provided for @statusFoundAdapter.
  ///
  /// In en, this message translates to:
  /// **'Found OBD adapter: {p0}. Connecting...'**
  String statusFoundAdapter(String p0);

  /// No description provided for @statusProbingPaired.
  ///
  /// In en, this message translates to:
  /// **'Probing paired device: {p0}...'**
  String statusProbingPaired(String p0);

  /// No description provided for @statusDiscovering.
  ///
  /// In en, this message translates to:
  /// **'Discovering nearby Bluetooth OBD adapters...'**
  String get statusDiscovering;

  /// No description provided for @statusFoundNearby.
  ///
  /// In en, this message translates to:
  /// **'Found nearby OBD: {p0}. Connecting...'**
  String statusFoundNearby(String p0);

  /// No description provided for @statusNoBtAdapter.
  ///
  /// In en, this message translates to:
  /// **'No Bluetooth OBD adapter detected. Check adapter power or try BLE/USB/Wi-Fi.'**
  String get statusNoBtAdapter;

  /// No description provided for @statusBtError.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth detection error: {p0}'**
  String statusBtError(String p0);

  /// No description provided for @statusInitProtocol.
  ///
  /// In en, this message translates to:
  /// **'Initializing adapter & detecting vehicle protocol... Older cars (K-line) can take up to 40 seconds. Keep the key ON.'**
  String get statusInitProtocol;

  /// No description provided for @statusConnectedDetecting.
  ///
  /// In en, this message translates to:
  /// **'Connected to ECU | Detecting vehicle & supported PIDs...'**
  String get statusConnectedDetecting;

  /// No description provided for @statusConnectedDetected.
  ///
  /// In en, this message translates to:
  /// **'Connected: {p0} | {p1}'**
  String statusConnectedDetected(String p0, String p1);

  /// No description provided for @statusConnectedProtocol.
  ///
  /// In en, this message translates to:
  /// **'Connected to ECU | Protocol: {p0}'**
  String statusConnectedProtocol(String p0);

  /// No description provided for @statusAdapterReadyKeyOff.
  ///
  /// In en, this message translates to:
  /// **'Adapter Ready ({p0}V) - Ignition Key in OFF/ACC. Turn key to ON/RUN.'**
  String statusAdapterReadyKeyOff(String p0);

  /// No description provided for @statusInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize ELM327 adapter. {p0}'**
  String statusInitFailed(String p0);

  /// No description provided for @statusRetrying.
  ///
  /// In en, this message translates to:
  /// **'Retrying vehicle ECU handshake (Turn Key to ON)...'**
  String get statusRetrying;

  /// No description provided for @statusEcuNotResponding.
  ///
  /// In en, this message translates to:
  /// **'ECU not responding. Make sure ignition key is switched to ON/RUN.'**
  String get statusEcuNotResponding;

  /// No description provided for @statusReadingVin.
  ///
  /// In en, this message translates to:
  /// **'Reading VIN, auto-identifying car, and scanning trouble codes...'**
  String get statusReadingVin;

  /// No description provided for @statusQuickScanDone.
  ///
  /// In en, this message translates to:
  /// **'Quick scan completed successfully'**
  String get statusQuickScanDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
