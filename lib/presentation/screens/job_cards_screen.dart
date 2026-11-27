import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/search_match.dart';
import '../../data/models/workshop_records.dart';
import '../../data/repositories/workshop_store.dart';
import '../../domain/services/job_card_pdf_service.dart';
import '../providers/obd_state.dart';

const _statusEn = ['Quote', 'Approved', 'In progress', 'Done', 'Delivered'];
const _statusAr = ['عرض سعر', 'تمت الموافقة', 'قيد التنفيذ', 'تم', 'تم التسليم'];

class JobCardsScreen extends StatefulWidget {
  final List<JobCard>? testJobs;
  const JobCardsScreen({super.key, this.testJobs});
  @override
  State<JobCardsScreen> createState() => _JobCardsScreenState();
}

class _JobCardsScreenState extends State<JobCardsScreen> {
  List<JobCard> _jobs = [];
  bool _loading = true;
  String _q = '';
  bool get _isAr => Provider.of<ObdState>(context, listen: false).isArabic;
  String _t(String en, String ar) => _isAr ? ar : en;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final l = widget.testJobs ?? await WorkshopStore.jobs();
    if (mounted) setState(() { _jobs = l; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('Job Cards & Quotes', 'أوامر الشغل وعروض الأسعار'))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const JobCardEditScreen()));
          _load();
        },
        icon: const Icon(Icons.add),
        label: Text(_t('New job card', 'أمر شغل جديد')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _jobs.isEmpty
              ? Center(child: Text(_t('No job cards yet.', 'لا توجد أوامر شغل.')))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                  children: [
                    TextField(
                      decoration: InputDecoration(prefixIcon: const Icon(Icons.search), labelText: _t('Search plate, customer, phone', 'بحث: لوحة، عميل، هاتف')),
                      onChanged: (v) => setState(() => _q = v),
                    ),
                    const SizedBox(height: 10),
                    for (final j in _jobs.where((j) => SearchMatch.matches(_q, [j.plate, j.customer, j.phone, j.vehicle])))
                      Card(
                        child: ListTile(
                          title: Text('${j.plate.isEmpty ? "-" : j.plate}  ${j.customer}'),
                          subtitle: Text('${j.vehicle}\n${(_isAr ? _statusAr : _statusEn)[j.status.index]}  |  ${j.createdAt.toIso8601String().substring(0, 10)}'),
                          isThreeLine: true,
                          trailing: Text(JobCardPdfService.money(j.total), style: const TextStyle(fontWeight: FontWeight.bold)),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(builder: (_) => JobCardEditScreen(job: j)));
                            _load();
                          },
                        ),
                      ),
                  ],
                ),
    );
  }
}

class JobCardEditScreen extends StatefulWidget {
  final JobCard? job;
  final InspectionRecord? prefill;
  const JobCardEditScreen({super.key, this.job, this.prefill});
  @override
  State<JobCardEditScreen> createState() => _JobCardEditScreenState();
}

class _JobCardEditScreenState extends State<JobCardEditScreen> {
  late JobCard _j;
  bool get _isAr => Provider.of<ObdState>(context, listen: false).isArabic;
  String _t(String en, String ar) => _isAr ? ar : en;

  @override
  void initState() {
    super.initState();
    final p = widget.prefill;
    _j = widget.job ??
        JobCard(
          id: WorkshopStore.newId(),
          plate: p?.plate ?? '',
          customer: p?.customer ?? '',
          vehicle: p?.vehicleName ?? '',
          odometerKm: (p?.extra['mileageKm'] ?? '').toString(),
          inspectionId: p?.id,
        );
  }

  Future<void> _save() async {
    await WorkshopStore.saveJob(_j);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('Saved', 'تم الحفظ'))));
  }

  /// Digits only; Egyptian local numbers (01xxxxxxxxx) become 20 + number without the leading 0.
  static String waNumber(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('00')) d = d.substring(2);
    if (d.startsWith('01') && d.length == 11) d = '20${d.substring(1)}';
    return d;
  }

  static String waText(JobCard j, bool invoice) {
    final b = StringBuffer()
      ..writeln(invoice ? 'Invoice' : 'Quote')
      ..writeln('${j.vehicle} ${j.plate}'.trim())
      ..writeln('Total: ${JobCardPdfService.money(j.total)}')
      ..writeln('PDF attached.');
    return b.toString();
  }

  Future<void> _whatsapp(bool invoice) async {
    await _save();
    final num = waNumber(_j.phone);
    if (num.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('Enter the customer phone first', 'أدخل رقم العميل أولاً'))));
      return;
    }
    // WhatsApp links cannot attach files, so open the chat with the text, then the share sheet carries the PDF.
    final uri = Uri.parse('https://wa.me/$num?text=${Uri.encodeComponent(waText(_j, invoice))}');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_t('Could not open WhatsApp', 'تعذر فتح واتساب'))));
      return;
    }
    await Future<void>.delayed(const Duration(seconds: 1));
    await JobCardPdfService.share(_j, invoice: invoice);
  }

  Widget _f(String label, String init, void Function(String) on, {bool num = false, int lines = 1, TextInputType? type}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextFormField(
          initialValue: init,
          maxLines: lines,
          keyboardType: type ?? (num ? const TextInputType.numberWithOptions(decimal: true) : null),
          decoration: InputDecoration(labelText: label, isDense: true),
          onChanged: (v) => setState(() => on(v)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final names = _isAr ? _statusAr : _statusEn;
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('Job card', 'أمر شغل')),
        actions: [
          if (widget.job != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await WorkshopStore.deleteJob(_j.id);
                if (mounted) Navigator.pop(context);
              },
            ),
          IconButton(icon: const Icon(Icons.save), onPressed: _save),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _f(_t('Customer', 'العميل'), _j.customer, (v) => _j.customer = v),
          _f(_t('Phone (WhatsApp)', 'الهاتف (واتساب)'), _j.phone, (v) => _j.phone = v, type: TextInputType.phone),
          Row(children: [
            Expanded(child: _f(_t('Plate', 'اللوحة'), _j.plate, (v) => _j.plate = v)),
            const SizedBox(width: 8),
            Expanded(child: _f(_t('Odometer km', 'العداد كم'), _j.odometerKm, (v) => _j.odometerKm = v, num: true)),
          ]),
          _f(_t('Vehicle', 'السيارة'), _j.vehicle, (v) => _j.vehicle = v),
          _f(_t('Complaint', 'شكوى العميل'), _j.complaint, (v) => _j.complaint = v, lines: 2),
          _f(_t('Findings / work done', 'النتائج / الشغل'), _j.findings, (v) => _j.findings = v, lines: 2),
          DropdownButtonFormField<JobStatus>(
            value: _j.status,
            decoration: InputDecoration(labelText: _t('Status', 'الحالة'), isDense: true),
            items: [for (final s in JobStatus.values) DropdownMenuItem(value: s, child: Text(names[s.index]))],
            onChanged: (v) => setState(() => _j.status = v ?? _j.status),
          ),
          const SizedBox(height: 12),
          Text(_t('Parts and labour (EGP)', 'قطع وأجرة (جنيه)'), style: const TextStyle(fontWeight: FontWeight.bold)),
          for (int i = 0; i < _j.items.length; i++) _line(i),
          Row(children: [
            TextButton.icon(onPressed: () => setState(() => _j.items.add(JobLineItem())), icon: const Icon(Icons.add), label: Text(_t('Part', 'قطعة'))),
            TextButton.icon(onPressed: () => setState(() => _j.items.add(JobLineItem(isLabour: true))), icon: const Icon(Icons.build), label: Text(_t('Labour', 'أجرة'))),
          ]),
          Row(children: [
            Expanded(child: _f(_t('Discount EGP', 'خصم'), _j.discount == 0 ? '' : _j.discount.toString(), (v) => _j.discount = double.tryParse(v) ?? 0, num: true)),
            const SizedBox(width: 8),
            Expanded(child: _f(_t('VAT % (if any)', 'ضريبة % (إن وجدت)'), _j.vatPercent == 0 ? '' : _j.vatPercent.toString(), (v) => _j.vatPercent = double.tryParse(v) ?? 0, num: true)),
          ]),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${_t("Parts", "قطع")}: ${JobCardPdfService.money(_j.partsTotal)}'),
                Text('${_t("Labour", "أجرة")}: ${JobCardPdfService.money(_j.labourTotal)}'),
                if (_j.discount > 0) Text('${_t("Discount", "خصم")}: -${JobCardPdfService.money(_j.discount)}'),
                if (_j.vatPercent > 0) Text('VAT: ${JobCardPdfService.money(_j.vat)}'),
                Text('${_t("TOTAL", "الإجمالي")}: ${JobCardPdfService.money(_j.total)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: () async { await _save(); await JobCardPdfService.share(_j, invoice: false); }, icon: const Icon(Icons.description), label: Text(_t('Quote PDF', 'عرض سعر PDF')))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(onPressed: () async { await _save(); await JobCardPdfService.share(_j, invoice: true); }, icon: const Icon(Icons.receipt_long), label: Text(_t('Invoice PDF', 'فاتورة PDF')))),
          ]),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _whatsapp(false), icon: const Icon(Icons.chat), label: Text(_t('WhatsApp quote', 'واتساب عرض سعر')))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: () => _whatsapp(true), icon: const Icon(Icons.chat), label: Text(_t('WhatsApp invoice', 'واتساب فاتورة')))),
          ]),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _line(int i) {
    final it = _j.items[i];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(children: [
          Row(children: [
            Icon(it.isLabour ? Icons.build : Icons.settings, size: 18),
            const SizedBox(width: 6),
            Expanded(child: TextFormField(initialValue: it.description, decoration: InputDecoration(hintText: it.isLabour ? _t('Labour description', 'وصف الأجرة') : _t('Part name', 'اسم القطعة'), isDense: true), onChanged: (v) => setState(() => it.description = v))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _j.items.removeAt(i))),
          ]),
          Row(children: [
            Expanded(child: TextFormField(initialValue: it.qty.toString(), keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: _t('Qty', 'الكمية'), isDense: true), onChanged: (v) => setState(() => it.qty = double.tryParse(v) ?? 0))),
            const SizedBox(width: 8),
            Expanded(child: TextFormField(initialValue: it.unitPrice == 0 ? '' : it.unitPrice.toString(), keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: _t('Unit price', 'سعر الوحدة'), isDense: true), onChanged: (v) => setState(() => it.unitPrice = double.tryParse(v) ?? 0))),
            const SizedBox(width: 8),
            Text(it.total.toStringAsFixed(2)),
          ]),
        ]),
      ),
    );
  }
}
