import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
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
        title: Text(_t('Continue saved draft?', 'متابعة المسودة المحفوظة؟')),
        content: Text(plate.isEmpty ? _t('An unfinished inspection was saved on this phone.', 'يوجد فحص غير مكتمل محفوظ على الهاتف.') : _t('Unfinished inspection for $plate.', 'فحص غير مكتمل للوحة $plate.')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_t('Start new', 'ابدأ جديد'))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(_t('Continue', 'متابعة'))),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('Visit saved', 'تم حفظ الزيارة'))));
    if (toJob) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => JobCardEditScreen(prefill: rec)));
    } else {
      setState(() {});
    }
  }

  bool get _isAr => Provider.of<ObdState>(context, listen: false).isArabic;
  String _t(String en, String ar) => _isAr ? ar : en;

  Future<void> _readFromCar() async {
    final st = Provider.of<ObdState>(context, listen: false);
    if (!st.isConnected) {
      setState(() => _error = _t('Connect the adapter to the car first.', 'وصّل الأداة بالسيارة أولاً.'));
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
    final titles = [_t('1. Read from car', '1. قراءة من السيارة'), _t('2. Inspection form', '2. نموذج الفحص'), _t('3. Report', '3. التقرير')];
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: Text(_t('Used-car inspection', 'فحص سيارة مستعملة'))),
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
                      OutlinedButton(onPressed: () => setState(() => _step--), child: Text(_t('Back', 'رجوع'))),
                    const Spacer(),
                    if (_step < 2)
                      ElevatedButton(
                        onPressed: !_canProceed ? null : () => setState(() => _step++),
                        child: Text(_t('Next', 'التالي')),
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
        _note(_t('This step reads only what the car reports: odometer in the ECUs, stored codes and clearing history, VIN, battery voltage, misfires. Everything else is entered by hand in step 2.',
            'هذه الخطوة تقرأ فقط ما تبلغ به السيارة: العداد في الوحدات والأعطال وتاريخ المسح والشاسيه وجهد البطارية والـ misfire. باقي الفحص يدوي في الخطوة 2.')),
        const SizedBox(height: 8),
        Row(children: [
          Icon(st.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled, color: st.isConnected ? AppColors.successGreen : AppColors.dangerRed),
          const SizedBox(width: 8),
          Expanded(child: Text(st.isConnected ? _t('Adapter connected', 'الأداة متصلة') : _t('Not connected', 'غير متصل'))),
          if (!st.isConnected)
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConnectionScreen())), child: Text(_t('Connect', 'اتصال'))),
        ]),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _busy ? null : _readFromCar,
          icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.download),
          label: Text(_busy ? _t('Reading...', 'جارٍ القراءة...') : (c == null ? _t('Read from car', 'اقرأ من السيارة') : _t('Read again', 'اقرأ مرة أخرى'))),
        ),
        if (_snapshotOnly)
          Padding(padding: const EdgeInsets.only(top: 8), child: _note(_t('Car readings restored from the saved draft. Read again to refresh them.', 'قراءات السيارة مستعادة من المسودة. اقرأ مرة أخرى لتحديثها.'))),
        TextButton.icon(
          onPressed: () => setState(() { _noCar = true; _step = 1; }),
          icon: const Icon(Icons.skip_next),
          label: Text(_t('Skip, no car (hand inspection only)', 'تخطي، بدون سيارة (فحص يدوي فقط)')),
        ),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: AppColors.dangerRed))),
        if (c != null) ...[
          const SizedBox(height: 12),
          _result(_t('Odometer (ECM / TCM / ABS / cluster)', 'العداد'), _isAr ? c.odometerAudit.verdictAr : c.odometerAudit.verdictEn, c.odometerAudit.isRollbackSuspected),
          _result(_t('Code clearing history', 'تاريخ مسح الأعطال'), _isAr ? c.codeClearingAudit.explanationAr : c.codeClearingAudit.explanationEn, c.codeClearingAudit.isRecentlyCleared),
          _result(_t('VIN', 'رقم الشاسيه'), 'VIN: ${c.vinAudit.registeredVin}', !c.vinAudit.isVinMatched),
          _result(_t('Battery', 'البطارية'), _isAr ? c.batteryCrankingAudit.verdictAr : c.batteryCrankingAudit.verdictEn, c.batteryCrankingAudit.isWeakBattery),
          _result(_t('Misfires', 'الـ Misfire'), _isAr ? c.drivetrainHealth.healthSummaryAr : c.drivetrainHealth.healthSummaryEn, c.drivetrainHealth.hasMisfireDetected),
          _note(_t('Values the car did not answer are shown as not read. Not a final verdict: finish step 2.', 'القيم التي لم ترد من السيارة تظهر كغير مقروءة. ليس حكماً نهائياً: أكمل الخطوة 2.')),
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
        _note(_t('Hand-entered. Anything left empty or "not checked" is printed as not checked, never as OK.', 'إدخال يدوي. أي حقل فارغ أو "لم يُفحص" يُطبع كما هو وليس كسليم.')),
        _sec(_t('Vehicle', 'السيارة'), [
          _field(_t('Customer', 'العميل'), _x.customerName, (v) => _x.customerName = v),
          _field(_t('Plate', 'اللوحة'), _x.plate, (v) => _x.plate = v),
          _field(_t('Odometer shown (km)', 'العداد المعروض (كم)'), _x.mileageKm, (v) => _x.mileageKm = v, num: true),
        ]),
        _sec(_t('Paint thickness (um), gauge needed', 'سماكة الدهان (ميكرون) بجهاز قياس'), [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in InspectionExtra.panels)
              SizedBox(width: 130, child: _field(_short(p), _x.paintMicrons[p]!, (v) => _x.paintMicrons[p] = v, num: true)),
          ]),
          _field(_t('Body notes (dents, panel gaps, rust, glass)', 'ملاحظات الهيكل (خبطات، فواصل، صدأ، زجاج)'), _x.bodyNote, (v) => _x.bodyNote = v, lines: 2),
        ]),
        _sec(_t('Tires: tread depth (mm)', 'الكاوتش: عمق الأخدود (مم)'), [
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final k in _x.tireTreadMm.keys) SizedBox(width: 100, child: _field(k, _x.tireTreadMm[k]!, (v) => _x.tireTreadMm[k] = v, num: true)),
          ]),
          _field(_t('Tire note (age, uneven wear)', 'ملاحظة الكاوتش'), _x.tireNote, (v) => _x.tireNote = v),
        ]),
        _sec(_t('Brakes', 'الفرامل'), [
          Row(children: [
            Expanded(child: _field(_t('Front pads %', 'تيل أمامي %'), _x.frontPadPercent, (v) => _x.frontPadPercent = v, num: true)),
            const SizedBox(width: 8),
            Expanded(child: _field(_t('Rear pads %', 'تيل خلفي %'), _x.rearPadPercent, (v) => _x.rearPadPercent = v, num: true)),
          ]),
          _status(_t('Front discs', 'طنابير/دوائر أمامية'), _x.frontDiscs, (s) => _x.frontDiscs = s),
          _status(_t('Rear discs', 'طنابير/دوائر خلفية'), _x.rearDiscs, (s) => _x.rearDiscs = s),
        ]),
        _sec(_t('Fluids', 'السوائل'), [for (final k in _x.fluids.keys) _status(k, _x.fluids[k]!, (s) => _x.fluids[k] = s)]),
        _sec(_t('Test drive', 'تجربة الطريق'), [for (final k in _x.testDrive.keys) _status(k, _x.testDrive[k]!, (s) => _x.testDrive[k] = s)]),
        _sec(_t('Mechanical checklist', 'قائمة الفحص الميكانيكي'), [
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
        _sec(_t('Photos', 'صور'), [
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
            TextButton.icon(onPressed: () => _pick(ImageSource.camera), icon: const Icon(Icons.photo_camera), label: Text(_t('Camera', 'كاميرا'))),
            TextButton.icon(onPressed: () => _pick(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: Text(_t('Gallery', 'المعرض'))),
          ]),
        ]),
        _sec(_t('Technician notes', 'ملاحظات الفني'), [_field(_t('Notes', 'ملاحظات'), _x.notes, (v) => _x.notes = v, lines: 3)]),
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('Could not open the camera or gallery', 'تعذر فتح الكاميرا أو المعرض'))));
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
      ManualCheckItemStatus.pass: _t('OK', 'سليم'),
      ManualCheckItemStatus.marginal: _t('Marginal', 'متوسط'),
      ManualCheckItemStatus.fail: _t('Fail', 'تالف'),
      ManualCheckItemStatus.leaking: _t('Leak', 'تسريب'),
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
        _note(_t('The report prints car readings and hand-entered data in separate sections. The score is a simple formula from the car readings, not a verdict.',
            'التقرير يطبع قراءات السيارة والبيانات اليدوية في أقسام منفصلة. الدرجة مجرد معادلة بسيطة من قراءات السيارة وليست حكماً.')),
        const SizedBox(height: 8),
        if (c != null)
          _result(_t('From the car', 'من السيارة'), 'Score ${c.overallScore}/100 (formula)', c.odometerAudit.isRollbackSuspected || c.codeClearingAudit.isRecentlyCleared)
        else if (_hasCar)
          _result(_t('From the car (saved readings)', 'من السيارة (قراءات محفوظة)'), '${_snapshot.length} readings saved', false)
        else
          _result(_t('From the car', 'من السيارة'), _t('No car reading, hand inspection only', 'بدون قراءة من السيارة، فحص يدوي فقط'), false),
        _result(_t('Paint', 'الدهان'), '$paintN / ${InspectionExtra.panels.length} panels measured', paintAudit.hasBondoDetected || paintAudit.hasStructuralDamageSuspected),
        _result(_t('Checklist', 'القائمة'), '${m.checkedCount} / ${m.totalItems} checked, ${m.failedCount + m.leakingCount} problems', m.failedCount + m.leakingCount > 0),
        _result(_t('Tires / fluids / test drive', 'كاوتش / سوائل / تجربة'), '$tires/4 tires, $fl/${_x.fluids.length} fluids, $td/${_x.testDrive.length} drive checks, ${_x.photoPaths.length} photos', false),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final b = await _pdfBytes();
                await Printing.sharePdf(bytes: b, filename: 'Inspection_${_x.plate.isEmpty ? _id : _x.plate.replaceAll(" ", "")}.pdf');
              },
              icon: const Icon(Icons.share),
              label: Text(_t('Share PDF', 'مشاركة PDF')),
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
              label: Text(_t('Print', 'طباعة')),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _saveVisit,
          icon: const Icon(Icons.save),
          label: Text(_saved ? _t('Saved. Save again', 'تم الحفظ. حفظ مرة أخرى') : _t('Save visit to car history', 'احفظ الزيارة في سجل السيارة')),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _saveVisit(toJob: true),
          icon: const Icon(Icons.request_quote),
          label: Text(_t('Save and create job card / quote', 'حفظ وإنشاء أمر شغل / عرض سعر')),
        ),
      ],
    );
  }
}
