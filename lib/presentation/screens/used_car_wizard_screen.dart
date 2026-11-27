import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/inspection_extra.dart';
import '../../data/models/used_car_audit_models.dart';
import '../../data/models/workshop_records.dart';
import '../../data/repositories/workshop_store.dart';
import '../../domain/services/used_car_pdf_report_service.dart';
import 'job_cards_screen.dart';
import '../providers/obd_state.dart';
import 'connection_screen.dart';

/// Used-car inspection as 3 steps: 1) read from the car, 2) hand inspection form,
/// 3) report (PDF). Car readings and hand-entered data are kept separate and labeled.
class UsedCarWizardScreen extends StatefulWidget {
  /// Only for tests and screenshots.
  final PrePurchaseAuditScorecard? initialCard;
  final int initialStep;
  const UsedCarWizardScreen({Key? key, this.initialCard, this.initialStep = 0}) : super(key: key);
  @override
  State<UsedCarWizardScreen> createState() => _UsedCarWizardScreenState();
}

class _UsedCarWizardScreenState extends State<UsedCarWizardScreen> {
  int _step = 0;
  bool _busy = false;
  String? _error;
  PrePurchaseAuditScorecard? _card;
  final InspectionExtra _x = InspectionExtra();
  late ManualInspectionReport _checklist = ManualInspectionReport.defaultWorkshopChecklist();

  bool _noCar = false;
  Map<String, String> _snapshot = {}; // facts from the car as strings (saved with the visit)
  bool _snapshotOnly = false; // car read earlier (restored draft), no live scorecard now
  String _id = WorkshopStore.newId();
  Timer? _draftTimer;
  bool _saved = false;

  bool get _hasCar => _card != null || _snapshotOnly;
  bool get _canProceed => _hasCar || _noCar;

  @override
  void initState() {
    super.initState();
    _card = widget.initialCard;
    if (_card != null) _snapshot = _snapFromCard(_card!);
    _step = widget.initialStep;
    if (widget.initialCard == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _offerDraft());
      _draftTimer = Timer.periodic(const Duration(seconds: 5), (_) => _saveDraft());
    }
  }

  @override
  void dispose() {
    _draftTimer?.cancel();
    _saveDraft();
    super.dispose();
  }

  Map<String, String> _snapFromCard(PrePurchaseAuditScorecard c) {
    String km(int v) => v > 0 ? '$v km' : 'not read';
    return {
      'ECM odometer': km(c.odometerAudit.ecmMileageKm),
      'TCM odometer': km(c.odometerAudit.tcmMileageKm),
      'ABS odometer (equivalent)': km(c.odometerAudit.absRevolutionsEquivalentKm),
      'Cluster odometer': km(c.odometerAudit.clusterMileageKm),
      'Odometer cross-check': c.odometerAudit.isRollbackSuspected ? 'MISMATCH: rollback suspected' : 'no mismatch found',
      'Codes cleared recently': c.codeClearingAudit.isRecentlyCleared ? 'YES' : 'no',
      'Distance since codes cleared': '${c.codeClearingAudit.distanceSinceDtcClearedKm} km',
      'VIN': c.vinAudit.registeredVin,
      'VIN match across modules': c.vinAudit.isVinMatched ? 'yes' : 'NO',
      'Battery resting voltage': c.batteryCrankingAudit.restVoltage.isNaN ? 'not read' : '${c.batteryCrankingAudit.restVoltage.toStringAsFixed(2)} V',
      'Misfires': c.drivetrainHealth.hasMisfireDetected ? '${c.drivetrainHealth.totalMisfireCount} detected' : 'none detected',
      'Score (formula)': '${c.overallScore}/100',
    };
  }

  Map<String, int> _checklistMap() => {
        for (final c in _checklist.categories) for (final i in c.items) i.id: i.status.index,
      };

  Map<String, dynamic> _draftJson() => {
        'id': _id,
        'noCar': _noCar,
        'hasCar': _hasCar,
        'snapshot': _snapshot,
        'extra': _x.toJson(),
        'checklist': _checklistMap(),
      };

  bool get _hasContent =>
      _hasCar || _noCar || _x.plate.isNotEmpty || _x.customerName.isNotEmpty || _x.notes.isNotEmpty ||
      _x.paintMicrons.values.any((v) => v.isNotEmpty) || _checklist.checkedCount > 0 || _x.photoPaths.isNotEmpty;

  Future<void> _saveDraft() async {
    if (_saved || !_hasContent) return;
    await WorkshopStore.saveDraft(_draftJson());
  }

  ManualInspectionReport _applyChecklist(ManualInspectionReport base, Map<String, int> m) {
    return ManualInspectionReport(
      categories: base.categories
          .map((c) => c.copyWith(
              items: c.items.map((i) {
                final n = m[i.id];
                if (n == null || n < 0 || n >= ManualCheckItemStatus.values.length) return i;
                return i.copyWith(status: ManualCheckItemStatus.values[n]);
              }).toList()))
          .toList(),
    );
  }

  Future<void> _offerDraft() async {
    final d = await WorkshopStore.loadDraft();
    if (d == null || !mounted) return;
    final plate = ((d['extra'] as Map?)?['plate'] ?? '').toString();
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).continueSavedDraft),
        content: Text(plate.isEmpty ? AppLocalizations.of(context).anUnfinishedInspectionWasSaved : AppLocalizations.of(context).unfinishedInspectionFor(plate)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context).startNew)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context).continueAction)),
        ],
      ),
    );
    if (go == true) {
      setState(() {
        _id = (d['id'] ?? _id).toString();
        _x.loadJson(Map<String, dynamic>.from(d['extra'] as Map));
        _checklist = _applyChecklist(ManualInspectionReport.defaultWorkshopChecklist(), Map<String, int>.from((d['checklist'] ?? {}) as Map));
        _snapshot = Map<String, String>.from((d['snapshot'] ?? {}) as Map);
        _noCar = (d['noCar'] ?? false) as bool;
        _snapshotOnly = ((d['hasCar'] ?? false) as bool) && _snapshot.isNotEmpty;
      });
    } else {
      await WorkshopStore.clearDraft();
    }
  }

  Future<Uint8List> _pdfBytes() async {
    if (_card != null) {
      return UsedCarPdfReportService.generatePdfReport(scorecard: _finalCard, vehicleName: _vehicleName, isArabic: _isAr, extra: _x);
    }
    return UsedCarPdfReportService.generateManualOnlyPdf(
      extra: _x,
      vehicleName: _vehicleName,
      carRead: _hasCar,
      carSnapshot: _snapshot,
      checklist: _checklist,
      // paint is hand-entered: included in the extra pages
    );
  }

  Future<void> _saveVisit({bool toJob = false}) async {
    final bytes = await _pdfBytes();
    final path = await WorkshopStore.savePdf(_id, bytes);
    final rec = InspectionRecord(
      id: _id,
      createdAt: DateTime.now(),
      plate: _x.plate.trim(),
      customer: _x.customerName.trim(),
      vehicleName: _vehicleName,
      vin: _snapshot['VIN'] ?? '',
      carRead: _hasCar,
      carSnapshot: _snapshot,
      extra: jsonDecode(jsonEncode(_x.toJson())) as Map<String, dynamic>,
      checklist: _checklistMap(),
      pdfPath: path,
    );
    await WorkshopStore.saveInspection(rec);
    await WorkshopStore.clearDraft();
    _saved = true;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).visitSaved)));
    if (toJob) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => JobCardEditScreen(prefill: rec)));
    } else {
      setState(() {});
    }
  }

  bool get _isAr => Provider.of<ObdState>(context, listen: false).isArabic;

  Future<void> _readFromCar() async {
    final st = Provider.of<ObdState>(context, listen: false);
    if (!st.isConnected) {
      setState(() => _error = AppLocalizations.of(context).connectTheAdapterToThe);
      return;
    }
    setState(() { _busy = true; _error = null; });
    try {
      final c = await st.runLiveUsedCarAudit();
      if (mounted) setState(() { _card = c; _snapshot = _snapFromCard(c); _snapshotOnly = false; _noCar = false; });
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  PrePurchaseAuditScorecard get _finalCard =>
      _card!.copyWith(manualChecklist: _checklist, paintAudit: _x.buildPaintAudit());

  String get _vehicleName {
    final st = Provider.of<ObdState>(context, listen: false);
    final v = st.selectedVehicle;
    final base = v != null ? '${v.make} ${v.model}' : 'Vehicle';
    return _x.plate.trim().isEmpty ? base : '$base ${_x.plate.trim()}';
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Provider.of<ObdState>(context).isArabic;
    final titles = [AppLocalizations.of(context).s1ReadFromCar, AppLocalizations.of(context).s2InspectionForm, AppLocalizations.of(context).s3Report];
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context).usedCarInspection)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  for (int i = 0; i < 3; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (i > 0 && !_canProceed) return;
                          setState(() => _step = i);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: i == _step ? AppColors.primaryYellow : AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(titles[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: i == _step ? Colors.black : AppColors.textMuted)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: [_stepRead, _stepForm, _stepReport][_step]()),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    if (_step > 0)
                      OutlinedButton(onPressed: () => setState(() => _step--), child: Text(AppLocalizations.of(context).back)),
                    const Spacer(),
                    if (_step < 2)
                      ElevatedButton(
                        onPressed: !_canProceed ? null : () => setState(() => _step++),
                        child: Text(AppLocalizations.of(context).next),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Step 1 ----------
  Widget _stepRead() {
    final st = Provider.of<ObdState>(context);
    final c = _card;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _note(AppLocalizations.of(context).thisStepReadsOnlyWhat),
        const SizedBox(height: 8),
        Row(children: [
          Icon(st.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled, color: st.isConnected ? AppColors.successGreen : AppColors.dangerRed),
          const SizedBox(width: 8),
          Expanded(child: Text(st.isConnected ? AppLocalizations.of(context).adapterConnected : AppLocalizations.of(context).notConnected)),
          if (!st.isConnected)
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionScreen())), child: Text(AppLocalizations.of(context).connect)),
        ]),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _busy ? null : _readFromCar,
          icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
          label: Text(_busy ? AppLocalizations.of(context).reading : (c == null ? AppLocalizations.of(context).readFromCar : AppLocalizations.of(context).readAgain)),
        ),
        if (_snapshotOnly)
          Padding(padding: const EdgeInsets.only(top: 8), child: _note(AppLocalizations.of(context).carReadingsRestoredFromThe)),
        TextButton.icon(
          onPressed: () => setState(() { _noCar = true; _step = 1; }),
          icon: const Icon(Icons.skip_next),
          label: Text(AppLocalizations.of(context).skipNoCarHandInspection),
        ),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: AppColors.dangerRed))),
        if (c != null) ...[
          const SizedBox(height: 12),
          _result(AppLocalizations.of(context).odometerEcmTcmAbsCluster, _isAr ? c.odometerAudit.verdictAr : c.odometerAudit.verdictEn, c.odometerAudit.isRollbackSuspected),
          _result(AppLocalizations.of(context).codeClearingHistory, _isAr ? c.codeClearingAudit.explanationAr : c.codeClearingAudit.explanationEn, c.codeClearingAudit.isRecentlyCleared),
          _result(AppLocalizations.of(context).vin, 'VIN: ${c.vinAudit.registeredVin}', !c.vinAudit.isVinMatched),
          _result(AppLocalizations.of(context).battery, _isAr ? c.batteryCrankingAudit.verdictAr : c.batteryCrankingAudit.verdictEn, c.batteryCrankingAudit.isWeakBattery),
          _result(AppLocalizations.of(context).misfires, _isAr ? c.drivetrainHealth.healthSummaryAr : c.drivetrainHealth.healthSummaryEn, c.drivetrainHealth.hasMisfireDetected),
          _note(AppLocalizations.of(context).valuesTheCarDidNot),
        ],
      ],
    );
  }

  Widget _result(String title, String body, bool warn) => Card(
        child: ListTile(
          leading: Icon(warn ? Icons.warning_amber : Icons.check_circle_outline, color: warn ? AppColors.warningOrange : AppColors.successGreen),
          title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: Text(body, style: const TextStyle(fontSize: 12)),
        ),
      );

  Widget _note(String text) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: AppColors.cardSurface, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      );

  // ---------- Step 2 ----------
  Widget _stepForm() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _note(AppLocalizations.of(context).handEnteredAnythingLeftEmpty),
        _sec(AppLocalizations.of(context).vehicle, [
          _field(AppLocalizations.of(context).customer, _x.customerName, (v) => _x.customerName = v),
          _field(AppLocalizations.of(context).plate, _x.plate, (v) => _x.plate = v),
          _field(AppLocalizations.of(context).odometerShownKm, _x.mileageKm, (v) => _x.mileageKm = v, num: true),
        ]),
        _sec(AppLocalizations.of(context).paintThicknessUmGaugeNeeded, [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in InspectionExtra.panels)
              SizedBox(width: 130, child: _field(_short(p), _x.paintMicrons[p]!, (v) => _x.paintMicrons[p] = v, num: true)),
          ]),
          _field(AppLocalizations.of(context).bodyNotesDentsPanelGaps, _x.bodyNote, (v) => _x.bodyNote = v, lines: 2),
        ]),
        _sec(AppLocalizations.of(context).tiresTreadDepthMm, [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in _x.tireTreadMm.keys) SizedBox(width: 100, child: _field(k, _x.tireTreadMm[k]!, (v) => _x.tireTreadMm[k] = v, num: true)),
          ]),
          _field(AppLocalizations.of(context).tireNoteAgeUnevenWear, _x.tireNote, (v) => _x.tireNote = v),
        ]),
        _sec(AppLocalizations.of(context).brakes, [
          Row(children: [
            Expanded(child: _field(AppLocalizations.of(context).frontPads, _x.frontPadPercent, (v) => _x.frontPadPercent = v, num: true)),
            const SizedBox(width: 8),
            Expanded(child: _field(AppLocalizations.of(context).rearPads, _x.rearPadPercent, (v) => _x.rearPadPercent = v, num: true)),
          ]),
          _status(AppLocalizations.of(context).frontDiscs, _x.frontDiscs, (s) => _x.frontDiscs = s),
          _status(AppLocalizations.of(context).rearDiscs, _x.rearDiscs, (s) => _x.rearDiscs = s),
        ]),
        _sec(AppLocalizations.of(context).fluids, [for (final k in _x.fluids.keys) _status(k, _x.fluids[k]!, (s) => _x.fluids[k] = s)]),
        _sec(AppLocalizations.of(context).testDrive, [for (final k in _x.testDrive.keys) _status(k, _x.testDrive[k]!, (s) => _x.testDrive[k] = s)]),
        _sec(AppLocalizations.of(context).mechanicalChecklist, [
          for (final cat in _checklist.categories)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(_isAr ? cat.titleAr : cat.titleEn, style: const TextStyle(fontSize: 13)),
              children: [
                for (final it in cat.items)
                  _status(_isAr ? it.titleAr : it.titleEn, it.status, (s) => _setItem(cat.id, it.id, s)),
              ],
            ),
        ]),
        _sec(AppLocalizations.of(context).photos, [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in _x.photoPaths)
              Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(p), width: 90, height: 90, fit: BoxFit.cover)),
                Positioned(
                  top: 0, right: 0,
                  child: InkWell(onTap: () => setState(() => _x.photoPaths.remove(p)), child: const Icon(Icons.cancel, size: 20, color: AppColors.dangerRed)),
                ),
              ]),
          ]),
          Row(children: [
            TextButton.icon(onPressed: () => _pick(ImageSource.camera), icon: const Icon(Icons.photo_camera), label: Text(AppLocalizations.of(context).camera)),
            TextButton.icon(onPressed: () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: Text(AppLocalizations.of(context).gallery)),
          ]),
        ]),
        _sec(AppLocalizations.of(context).technicianNotes, [_field(AppLocalizations.of(context).notes, _x.notes, (v) => _x.notes = v, lines: 3)]),
      ],
    );
  }

  String _short(String p) => p
      .replaceAll('Front Left', 'FL').replaceAll('Front Right', 'FR')
      .replaceAll('Rear Left', 'RL').replaceAll('Rear Right', 'RR')
      .replaceAll('Passenger', 'Pass.').replaceAll('Fender', 'fender').replaceAll('Quarter', 'qtr');

  void _setItem(String catId, String itemId, ManualCheckItemStatus s) {
    final cats = _checklist.categories.map((c) {
      if (c.id != catId) return c;
      return c.copyWith(items: c.items.map((i) => i.id == itemId ? i.copyWith(status: s) : i).toList());
    }).toList();
    setState(() => _checklist = ManualInspectionReport(categories: cats));
  }

  Future<void> _pick(ImageSource src) async {
    try {
      final f = await ImagePicker().pickImage(source: src, maxWidth: 1600, imageQuality: 80);
      if (f != null) setState(() => _x.photoPaths.add(f.path));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).couldNotOpenTheCamera)));
    }
  }

  Widget _sec(String title, List<Widget> kids) => Card(
        margin: const EdgeInsets.only(top: 10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow)),
            const SizedBox(height: 8),
            ...kids,
          ]),
        ),
      );

  Widget _field(String label, String init, void Function(String) on, {bool num = false, int lines = 1}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextFormField(
          initialValue: init,
          maxLines: lines,
          keyboardType: num ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(labelText: label, isDense: true),
          onChanged: on,
        ),
      );

  Widget _status(String label, ManualCheckItemStatus cur, void Function(ManualCheckItemStatus) set) {
    final opts = <ManualCheckItemStatus, String>{
      ManualCheckItemStatus.pass: AppLocalizations.of(context).ok,
      ManualCheckItemStatus.marginal: AppLocalizations.of(context).marginal,
      ManualCheckItemStatus.fail: AppLocalizations.of(context).fail,
      ManualCheckItemStatus.leaking: AppLocalizations.of(context).leak,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(spacing: 6, children: [
          for (final e in opts.entries)
            ChoiceChip(
              label: Text(e.value, style: const TextStyle(fontSize: 11)),
              selected: cur == e.key,
              onSelected: (sel) => setState(() => set(sel ? e.key : ManualCheckItemStatus.notChecked)),
            ),
        ]),
      ]),
    );
  }

  // ---------- Step 3 ----------
  Widget _stepReport() {
    final c = _card != null ? _finalCard : null;
    final m = _checklist;
    final paintAudit = _x.buildPaintAudit();
    final paintN = paintAudit.panelMicrons.length;
    final tires = _x.tireTreadMm.values.where((v) => v.trim().isNotEmpty).length;
    final fl = _x.fluids.values.where((v) => v != ManualCheckItemStatus.notChecked).length;
    final td = _x.testDrive.values.where((v) => v != ManualCheckItemStatus.notChecked).length;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        _note(AppLocalizations.of(context).theReportPrintsCarReadings),
        const SizedBox(height: 8),
        if (c != null)
          _result(AppLocalizations.of(context).fromTheCar, 'Score ${c.overallScore}/100 (formula)', c.odometerAudit.isRollbackSuspected || c.codeClearingAudit.isRecentlyCleared)
        else if (_hasCar)
          _result(AppLocalizations.of(context).fromTheCarSavedReadings, '${_snapshot.length} readings saved', false)
        else
          _result(AppLocalizations.of(context).fromTheCar, AppLocalizations.of(context).noCarReadingHandInspection, false),
        _result(AppLocalizations.of(context).paint, '$paintN / ${InspectionExtra.panels.length} panels measured', paintAudit.hasBondoDetected || paintAudit.hasStructuralDamageSuspected),
        _result(AppLocalizations.of(context).checklist, '${m.checkedCount} / ${m.totalItems} checked, ${m.failedCount + m.leakingCount} problems', m.failedCount + m.leakingCount > 0),
        _result(AppLocalizations.of(context).tiresFluidsTestDrive, '$tires/4 tires, $fl/${_x.fluids.length} fluids, $td/${_x.testDrive.length} drive checks, ${_x.photoPaths.length} photos', false),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final b = await _pdfBytes();
                await Printing.sharePdf(bytes: b, filename: 'Inspection_${_x.plate.isEmpty ? _id : _x.plate.replaceAll(" ", "")}.pdf');
              },
              icon: const Icon(Icons.share),
              label: Text(AppLocalizations.of(context).sharePdf),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final b = await _pdfBytes();
                await Printing.layoutPdf(onLayout: (_) async => b, name: 'AutoSpect_Inspection_$_id');
              },
              icon: const Icon(Icons.print),
              label: Text(AppLocalizations.of(context).print),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _saveVisit,
          icon: const Icon(Icons.save),
          label: Text(_saved ? AppLocalizations.of(context).savedSaveAgain : AppLocalizations.of(context).saveVisitToCarHistory),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _saveVisit(toJob: true),
          icon: const Icon(Icons.request_quote),
          label: Text(AppLocalizations.of(context).saveAndCreateJobCard),
        ),
      ],
    );
  }
}
