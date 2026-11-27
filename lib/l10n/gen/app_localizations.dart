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
