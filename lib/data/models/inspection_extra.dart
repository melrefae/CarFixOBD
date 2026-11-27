import 'used_car_audit_models.dart';

/// Hand-entered inspection data for the used-car wizard. Nothing here is measured by the
/// car. Empty or notChecked means "not inspected" and is printed that way, never as OK.
class InspectionExtra {
  String customerName = '';
  String plate = '';
  String mileageKm = '';
  String notes = '';

  /// Tread depth in mm per tire (empty = not measured).
  final Map<String, String> tireTreadMm = {'FL': '', 'FR': '', 'RL': '', 'RR': ''};
  String tireNote = '';

  /// Brake pad remaining % and disc condition.
  String frontPadPercent = '';
  String rearPadPercent = '';
  ManualCheckItemStatus frontDiscs = ManualCheckItemStatus.notChecked;
  ManualCheckItemStatus rearDiscs = ManualCheckItemStatus.notChecked;

  /// Fluids and test drive use the same 5-state status as the checklist.
  final Map<String, ManualCheckItemStatus> fluids = {
    'Engine oil': ManualCheckItemStatus.notChecked,
    'Coolant': ManualCheckItemStatus.notChecked,
    'Brake fluid': ManualCheckItemStatus.notChecked,
    'Transmission fluid': ManualCheckItemStatus.notChecked,
    'Power steering fluid': ManualCheckItemStatus.notChecked,
  };
  final Map<String, ManualCheckItemStatus> testDrive = {
    'Cold start': ManualCheckItemStatus.notChecked,
    'Idle quality': ManualCheckItemStatus.notChecked,
    'Acceleration': ManualCheckItemStatus.notChecked,
    'Gear shifting': ManualCheckItemStatus.notChecked,
    'Steering pull / alignment': ManualCheckItemStatus.notChecked,
    'Brake feel': ManualCheckItemStatus.notChecked,
    'Noises / vibration': ManualCheckItemStatus.notChecked,
    'A/C cooling': ManualCheckItemStatus.notChecked,
  };

  /// Local file paths of photos taken during the inspection.
  final List<String> photoPaths = [];

  /// Paint thickness in microns per panel, text so empty = not measured.
  static const List<String> panels = [
    'Hood', 'Roof', 'Trunk Lid', 'Front Left Fender', 'Front Right Fender',
    'Rear Left Quarter', 'Rear Right Quarter', 'Driver Door', 'Passenger Door',
    'A-Pillars', 'B-Pillars',
  ];
  final Map<String, String> paintMicrons = {for (final p in panels) p: ''};
  String bodyNote = '';

  /// Builds the paint audit only from panels that were actually entered.
  BodyPaintThicknessAudit buildPaintAudit() {
    final m = <String, int>{};
    paintMicrons.forEach((k, v) {
      final n = int.tryParse(v.trim());
      if (n != null && n > 0) m[k] = n;
    });
    if (m.isEmpty) return const BodyPaintThicknessAudit.notAssessed();
    final bondo = m.values.any((v) => v > 250);
    final structural = (m['A-Pillars'] ?? 0) > 160 || (m['B-Pillars'] ?? 0) > 160;
    final top = m.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final en = 'Measured ${m.length} of ${panels.length} panels. Highest: ${top.value} um (${top.key}).'
        '${bondo ? " Reading above 250 um suggests body filler." : ""}'
        '${structural ? " Pillar reading above 160 um suggests repaint or repair." : ""}'
        ' Thresholds are rules of thumb. Compare panels against each other, not only to a number.';
    final ar = 'تم قياس ${m.length} من ${panels.length} أجزاء. أعلى قراءة: ${top.value} ميكرون (${top.key}).'
        '${bondo ? " قراءة فوق 250 ميكرون تدل على معجون." : ""}'
        '${structural ? " قراءة القوائم فوق 160 ميكرون تدل على دهان أو إصلاح." : ""}';
    return BodyPaintThicknessAudit(
      panelMicrons: m,
      hasBondoDetected: bondo,
      hasStructuralDamageSuspected: structural,
      verdictEn: en,
      verdictAr: ar,
    );
  }
}

extension InspectionExtraJson on InspectionExtra {
  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'plate': plate,
        'mileageKm': mileageKm,
        'notes': notes,
        'tireTreadMm': tireTreadMm,
        'tireNote': tireNote,
        'frontPadPercent': frontPadPercent,
        'rearPadPercent': rearPadPercent,
        'frontDiscs': frontDiscs.index,
        'rearDiscs': rearDiscs.index,
        'fluids': fluids.map((k, v) => MapEntry(k, v.index)),
        'testDrive': testDrive.map((k, v) => MapEntry(k, v.index)),
        'photoPaths': photoPaths,
        'paintMicrons': paintMicrons,
        'bodyNote': bodyNote,
      };

  void loadJson(Map<String, dynamic> j) {
    customerName = (j['customerName'] ?? '') as String;
    plate = (j['plate'] ?? '') as String;
    mileageKm = (j['mileageKm'] ?? '') as String;
    notes = (j['notes'] ?? '') as String;
    tireNote = (j['tireNote'] ?? '') as String;
    frontPadPercent = (j['frontPadPercent'] ?? '') as String;
    rearPadPercent = (j['rearPadPercent'] ?? '') as String;
    bodyNote = (j['bodyNote'] ?? '') as String;
    ManualCheckItemStatus st(dynamic i) {
      final n = i is int ? i : 0;
      return n >= 0 && n < ManualCheckItemStatus.values.length ? ManualCheckItemStatus.values[n] : ManualCheckItemStatus.notChecked;
    }
    frontDiscs = st(j['frontDiscs']);
    rearDiscs = st(j['rearDiscs']);
    void strMap(String key, Map<String, String> target) {
      final m = j[key];
      if (m is Map) m.forEach((k, v) { if (target.containsKey(k)) target[k as String] = v.toString(); });
    }
    void stMap(String key, Map<String, ManualCheckItemStatus> target) {
      final m = j[key];
      if (m is Map) m.forEach((k, v) { if (target.containsKey(k)) target[k as String] = st(v); });
    }
    strMap('tireTreadMm', tireTreadMm);
    strMap('paintMicrons', paintMicrons);
    stMap('fluids', fluids);
    stMap('testDrive', testDrive);
    photoPaths
      ..clear()
      ..addAll(((j['photoPaths'] ?? const []) as List).map((e) => e.toString()));
  }
}
