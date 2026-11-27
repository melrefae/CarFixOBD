import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/repositories/workshop_backup.dart';
import '../../data/repositories/workshop_profile.dart';
import '../providers/obd_state.dart';

/// Logo for PDFs, plus export / import of the workshop's saved inspections and job cards.
class IdentityBackupCard extends StatefulWidget {
  const IdentityBackupCard({super.key});
  @override
  State<IdentityBackupCard> createState() => _IdentityBackupCardState();
}

class _IdentityBackupCardState extends State<IdentityBackupCard> {
  String? _logo;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final p = await WorkshopProfile.logoPath();
    if (mounted) setState(() => _logo = (p != null && File(p).existsSync()) ? p : null);
  }

  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));

  Future<void> _pickLogo() async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600, imageQuality: 90);
    if (f == null) return;
    await WorkshopProfile.setLogo(f.path);
    await _refresh();
    _msg(AppLocalizations.of(context).logoSavedItPrintsOn);
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final path = await WorkshopBackup.exportToFile();
      await Share.shareXFiles([XFile(path)], subject: 'AutoSpect backup');
    } catch (e) {
      _msg(AppLocalizations.of(context).backupFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.any, withData: true);
    if (r == null || r.files.isEmpty) return;
    final bytes = r.files.first.bytes;
    if (bytes == null) {
      _msg(AppLocalizations.of(context).couldNotReadTheFile);
      return;
    }
    setState(() => _busy = true);
    try {
      final res = await WorkshopBackup.importJson(_utf8(bytes));
      await _refresh();
      _msg(AppLocalizations.of(context).importedVisitsAndJobCards(res.inspections, res.jobs, res.skipped));
    } on FormatException catch (e) {
      _msg(e.message);
    } catch (e) {
      _msg(AppLocalizations.of(context).importFailed(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _utf8(List<int> b) => const Utf8Decoder().convert(b);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppLocalizations.of(context).logoOnPdfsOptional, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
              child: _logo == null ? const Icon(Icons.image_outlined) : ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_logo!), fit: BoxFit.contain)),
            ),
            const SizedBox(width: 12),
            OutlinedButton(onPressed: _pickLogo, child: Text(AppLocalizations.of(context).choose)),
            const SizedBox(width: 8),
            if (_logo != null)
              TextButton(onPressed: () async { await WorkshopProfile.removeLogo(); _refresh(); }, child: Text(AppLocalizations.of(context).remove)),
          ]),
          const Divider(height: 24),
          Text(AppLocalizations.of(context).backupOfSavedVisitsAnd, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).savedDataLivesOnlyOn,
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: _busy ? null : _export, icon: const Icon(Icons.upload_file), label: Text(AppLocalizations.of(context).exportBackup))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: _busy ? null : _import, icon: const Icon(Icons.download), label: Text(AppLocalizations.of(context).importBackup))),
          ]),
        ]),
      ),
    );
  }
}
