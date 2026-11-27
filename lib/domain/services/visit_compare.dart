import '../../data/models/used_car_audit_models.dart';
import '../../data/models/workshop_records.dart';

class CompareRow {
  final String label;
  final String a;
  final String b;
  const CompareRow(this.label, this.a, this.b);
  bool get changed => a != b;
}

/// Side-by-side comparison of two saved visits. Only stored values are compared;
/// a missing value shows as "not measured".
class VisitCompare {
  static const _st = ['not checked', 'OK', 'marginal', 'FAIL', 'LEAK'];
  static const _nm = 'not measured';

  static String _s(dynamic v, {String suffix = ''}) {
    final t = (v ?? '').toString().trim();
    return t.isEmpty ? _nm : '$t$suffix';
  }

  static String _status(dynamic i) {
    final n = i is int ? i : 0;
    return _st[n.clamp(0, _st.length - 1)];
  }

  static List<CompareRow> rows(InspectionRecord a, InspectionRecord b) {
    final out = <CompareRow>[];
    void add(String l, String x, String y) => out.add(CompareRow(l, x, y));
    String snap(InspectionRecord r, String k) => r.carRead ? (r.carSnapshot[k] ?? 'not read') : 'no car reading';
    for (final k in const [
      'ECM odometer', 'Cluster odometer', 'Odometer cross-check', 'Codes cleared recently',
      'Distance since codes cleared', 'Battery resting voltage', 'Misfires', 'VIN',
    ]) {
      add(k, snap(a, k), snap(b, k));
    }
    final ea = a.extra, eb = b.extra;
    add('Mileage entered', _s(ea['mileageKm'], suffix: ' km'), _s(eb['mileageKm'], suffix: ' km'));
    final pa = Map<String, dynamic>.from((ea['paintMicrons'] ?? {}) as Map);
    final pb = Map<String, dynamic>.from((eb['paintMicrons'] ?? {}) as Map);
    for (final k in {...pa.keys, ...pb.keys}) {
      add('Paint: $k', _s(pa[k], suffix: ' µm'), _s(pb[k], suffix: ' µm'));
    }
    final ta = Map<String, dynamic>.from((ea['tireTreadMm'] ?? {}) as Map);
    final tb = Map<String, dynamic>.from((eb['tireTreadMm'] ?? {}) as Map);
    for (final k in {...ta.keys, ...tb.keys}) {
      add('Tire tread $k', _s(ta[k], suffix: ' mm'), _s(tb[k], suffix: ' mm'));
    }
    add('Front pads', _s(ea['frontPadPercent'], suffix: '%'), _s(eb['frontPadPercent'], suffix: '%'));
    add('Rear pads', _s(ea['rearPadPercent'], suffix: '%'), _s(eb['rearPadPercent'], suffix: '%'));
    add('Front discs', _status(ea['frontDiscs']), _status(eb['frontDiscs']));
    add('Rear discs', _status(ea['rearDiscs']), _status(eb['rearDiscs']));
    for (final g in const ['fluids', 'testDrive']) {
      final ma = Map<String, dynamic>.from((ea[g] ?? {}) as Map);
      final mb = Map<String, dynamic>.from((eb[g] ?? {}) as Map);
      for (final k in {...ma.keys, ...mb.keys}) {
        add(k, _status(ma[k]), _status(mb[k]));
      }
    }
    int problems(InspectionRecord r) => r.checklist.values.where((v) => v == ManualCheckItemStatus.fail.index || v == ManualCheckItemStatus.leaking.index).length;
    int checked(InspectionRecord r) => r.checklist.values.where((v) => v != 0).length;
    add('Checklist items checked', '${checked(a)}', '${checked(b)}');
    add('Checklist problems', '${problems(a)}', '${problems(b)}');
    return out;
  }
}
