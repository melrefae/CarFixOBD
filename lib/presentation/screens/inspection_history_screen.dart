import 'dart:io';
import 'package:flutter/material.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../../core/utils/search_match.dart';
import '../../data/models/workshop_records.dart';
import '../../data/repositories/workshop_store.dart';
import '../../domain/services/visit_compare.dart';
import '../providers/obd_state.dart';
import 'job_cards_screen.dart';

/// Saved inspections grouped per car (plate or VIN), with PDF reopen and visit comparison.
class InspectionHistoryScreen extends StatefulWidget {
  final List<InspectionRecord>? testRecords; // layout tests only
  const InspectionHistoryScreen({super.key, this.testRecords});
  @override
  State<InspectionHistoryScreen> createState() => _InspectionHistoryScreenState();
}

class _InspectionHistoryScreenState extends State<InspectionHistoryScreen> {
  List<InspectionRecord> _all = [];
  bool _loading = true;
  final Set<String> _sel = {};
  String _q = '';


  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = widget.testRecords ?? await WorkshopStore.inspections();
    if (mounted) setState(() { _all = l; _loading = false; _sel.clear(); });
  }

  Future<void> _open(InspectionRecord r) async {
    final p = r.pdfPath;
    if (p == null || !File(p).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).pdfFileNotFound)));
      return;
    }
    final bytes = await File(p).readAsBytes();
    await Printing.sharePdf(bytes: bytes, filename: 'Inspection_${r.plate.isEmpty ? r.id : r.plate.replaceAll(" ", "")}_${r.createdAt.toIso8601String().substring(0, 10)}.pdf');
  }

  Future<void> _delete(InspectionRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteThisVisit),
        content: Text(AppLocalizations.of(context).theSavedRecordAndIts),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: Text(AppLocalizations.of(context).cancel)),
          TextButton(onPressed: () => Navigator.pop(c, true), child: Text(AppLocalizations.of(context).delete)),
        ],
      ),
    );
    if (ok == true) {
      await WorkshopStore.deleteInspection(r.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<InspectionRecord>>{};
    for (final r in _all.where((r) => SearchMatch.matches(_q, [r.plate, r.customer, r.vehicleName, r.vin]))) {
      groups.putIfAbsent(r.carKey, () => []).add(r);
    }
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).carHistory)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _all.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(AppLocalizations.of(context).noSavedVisitsYetFinish, textAlign: TextAlign.center)))
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    TextField(
                      decoration: InputDecoration(prefixIcon: const Icon(Icons.search), labelText: AppLocalizations.of(context).searchPlateCustomerVin),
                      onChanged: (v) => setState(() => _q = v),
                    ),
                    const SizedBox(height: 10),
                    if (groups.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text(AppLocalizations.of(context).noMatch))),
                    for (final e in groups.entries) _group(e.key, e.value),
                  ],
                ),
    );
  }

  Widget _group(String key, List<InspectionRecord> list) {
    final first = list.first;
    final title = first.plate.isNotEmpty ? first.plate : (first.vin.isNotEmpty ? first.vin : AppLocalizations.of(context).unknownCar);
    final selHere = list.where((r) => _sel.contains(r.id)).toList();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListTile(
            dense: true,
            leading: const Icon(Icons.directions_car),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${first.vehicleName}  |  ${list.length} ${AppLocalizations.of(context).visits}'),
          ),
          for (final r in list)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CheckboxListTile(
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: _sel.contains(r.id),
                onChanged: (v) => setState(() { v == true ? _sel.add(r.id) : _sel.remove(r.id); }),
                title: Text(r.createdAt.toIso8601String().substring(0, 16).replaceFirst('T', ' ')),
                subtitle: Text([
                  r.customer.isEmpty ? null : r.customer,
                  r.carRead ? AppLocalizations.of(context).carRead : AppLocalizations.of(context).handInspectionOnly,
                  if ((r.extra['mileageKm'] ?? '').toString().isNotEmpty) '${r.extra['mileageKm']} km',
                ].whereType<String>().join('  |  ')),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Row(children: [
                  IconButton(icon: const Icon(Icons.picture_as_pdf), tooltip: 'PDF', onPressed: () => _open(r)),
                  IconButton(icon: const Icon(Icons.request_quote), tooltip: 'Job card', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => JobCardEditScreen(prefill: r)))),
                  IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Delete', onPressed: () => _delete(r)),
                ]),
              ),
            ]),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: selHere.length == 2
                  ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => VisitCompareScreen(a: selHere[1], b: selHere[0])))
                  : null,
              icon: const Icon(Icons.compare_arrows),
              label: Text(AppLocalizations.of(context).compare2SelectedVisits),
            ),
          ),
        ]),
      ),
    );
  }
}

class VisitCompareScreen extends StatelessWidget {
  final InspectionRecord a; // older
  final InspectionRecord b; // newer
  const VisitCompareScreen({super.key, required this.a, required this.b});

  @override
  Widget build(BuildContext context) {
    final rows = VisitCompare.rows(a, b);
    String d(InspectionRecord r) => r.createdAt.toIso8601String().substring(0, 10);
    final changed = rows.where((r) => r.changed).length;
    return Scaffold(
      appBar: AppBar(title: Text('${a.plate.isEmpty ? a.vehicleName : a.plate}: ${d(a)} vs ${d(b)}')),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('$changed of ${rows.length} items differ. Values are what was saved at each visit; "not measured" means nothing was entered.',
                style: const TextStyle(fontSize: 12)),
          ),
          Table(
            columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1.5), 2: FlexColumnWidth(1.5)},
            border: TableBorder(horizontalInside: BorderSide(color: Colors.grey.withOpacity(0.3))),
            children: [
              TableRow(children: [const SizedBox(), _c(d(a), bold: true), _c(d(b), bold: true)]),
              for (final r in rows)
                TableRow(
                  decoration: BoxDecoration(color: r.changed ? Colors.orange.withOpacity(0.18) : null),
                  children: [_c(r.label), _c(r.a), _c(r.b, bold: r.changed)],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _c(String t, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Text(t, style: TextStyle(fontSize: 11, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      );
}
