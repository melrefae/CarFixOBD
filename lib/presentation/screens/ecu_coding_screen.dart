import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/ecu_coding_feature.dart';
import '../../domain/services/ecu_coding_service.dart';
import '../providers/obd_state.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';

/// Screen for ECU Variant Coding and hidden features customization
class EcuCodingScreen extends StatefulWidget {
  const EcuCodingScreen({Key? key}) : super(key: key);

  @override
  State<EcuCodingScreen> createState() => _EcuCodingScreenState();
}

class _EcuCodingScreenState extends State<EcuCodingScreen> {
  final EcuCodingService _codingService = EcuCodingService();
  String _selectedCategory = "All";
  bool _filterByCurrentCar = false;
  String _busyFeatureId = "";

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final l10n = AppLocalizations.of(context);
    final vehicleMake = state.selectedVehicle?.make ?? l10n.codGeneric;

    final categories = [
      "All",
      "Dashboard & Cluster",
      "Lighting & Vision",
      "Comfort & Convenience",
      "Safety & Chimes"
    ];

    final filtered = _codingService.features.where((feat) {
      final matchesCat = _selectedCategory == "All" || feat.category == _selectedCategory;
      final matchesCar = !_filterByCurrentCar ||
          feat.applicableBrands.any((b) => b.toLowerCase() == vehicleMake.toLowerCase());
      return matchesCat && matchesCar;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.codTitle),
        actions: [
          if (_codingService.hasBackup)
            IconButton(
              icon: const Icon(Icons.restore, color: AppColors.primaryYellow),
              tooltip: l10n.codRestoreTip,
              onPressed: () => _confirmRestore(context, state, l10n),
            ),
        ],
      ),
      body: Column(
        children: [
          // Vehicle Profile Header Banner
          _buildVehicleHeader(state, l10n),

          // Category Chips & Car Filter
          _buildFilterBar(categories, vehicleMake, l10n),

          const SizedBox(height: 8),

          // Features List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.tune, size: 48, color: AppColors.textDisabled),
                          const SizedBox(height: 12),
                          Text(
                            _filterByCurrentCar
                                ? l10n.codEmptyMake(vehicleMake)
                                : l10n.codEmptyCat,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, index) {
                      final feat = filtered[index];
                      return _buildCodingTile(feat, state, l10n);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleHeader(ObdState state, AppLocalizations l10n) {
    final carName = state.selectedVehicle != null
        ? "${state.selectedVehicle!.make} ${state.selectedVehicle!.model} (${state.selectedVehicle!.years})"
        : l10n.codGenericVehicle;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_car, color: AppColors.primaryYellow, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                ),
                const SizedBox(height: 2),
                Text(
                  state.isConnected
                      ? l10n.codConnected
                      : l10n.codDisconnected,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
            ),
            child: const Text(
              "UDS Mode 2E",
              style: TextStyle(color: AppColors.electricBlue, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<String> categories, String vehicleMake, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              FilterChip(
                label: Text(l10n.codOnlyMake(vehicleMake)),
                selected: _filterByCurrentCar,
                onSelected: (val) => setState(() => _filterByCurrentCar = val),
                backgroundColor: AppColors.cardSurface,
                selectedColor: AppColors.primaryYellow.withOpacity(0.2),
                checkmarkColor: AppColors.primaryYellow,
                labelStyle: TextStyle(
                  color: _filterByCurrentCar ? AppColors.primaryYellow : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              ...categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(_codCatLabel(l10n, cat)),
                    selected: isSel,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    backgroundColor: AppColors.cardSurface,
                    selectedColor: AppColors.electricBlue,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : AppColors.textWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodingTile(EcuCodingFeature feature, ObdState state, AppLocalizations l10n) {
    final isBusy = _busyFeatureId == feature.id;

    return Card(
      color: AppColors.cardSurface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: feature.isEnabled ? AppColors.primaryYellow.withOpacity(0.5) : AppColors.cardBorder,
          width: feature.isEnabled ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (feature.isEnabled ? AppColors.primaryYellow : AppColors.electricBlue).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.isEnabled ? AppColors.primaryYellow : AppColors.electricBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isArabic ? feature.titleAr : feature.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite),
                      ),
                      if (state.isArabic) ...[
                        const SizedBox(height: 2),
                        Text(
                          feature.title,
                          style: const TextStyle(fontSize: 11, color: AppColors.primaryAmber),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isBusy)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryYellow),
                  )
                else
                  Switch(
                    value: feature.isEnabled,
                    activeColor: AppColors.primaryYellow,
                    onChanged: (newVal) => _toggleFeature(feature, newVal, state),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              state.isArabic ? feature.descriptionAr : feature.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.4),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceHighlight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "ECU: ${feature.ecuHeader}",
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.codCompatible(feature.applicableBrands.join(', ')),
                    style: const TextStyle(fontSize: 10, color: AppColors.textDisabled),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFeature(EcuCodingFeature feature, bool enable, ObdState state) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busyFeatureId = feature.id);

    try {
      final success = await _codingService.toggleFeature(
        feature: feature,
        enable: enable,
        driver: state.driver,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? (enable ? l10n.codEnabled(feature.title) : l10n.codDisabled(feature.title))
                  : l10n.codWriteFailed,
            ),
            backgroundColor: success ? AppColors.successGreen : AppColors.dangerRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busyFeatureId = "");
      }
    }
  }

  void _confirmRestore(BuildContext context, ObdState state, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text(l10n.codRestoreTitle, style: const TextStyle(color: Colors.white)),
        content: Text(
          l10n.codRestoreBody,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.codCancel, style: const TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow, foregroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await _codingService.restoreFactoryBackup(driver: state.driver);
              setState(() {});
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok ? l10n.codRestored : l10n.codRestoreFailed),
                    backgroundColor: ok ? AppColors.successGreen : AppColors.warningOrange,
                  ),
                );
              }
            },
            child: Text(l10n.codRestoreBtn),
          ),
        ],
      ),
    );
  }
}

String _codCatLabel(AppLocalizations l10n, String cat) {
  switch (cat) {
    case 'Dashboard & Cluster':
      return l10n.codCatDashboard;
    case 'Lighting & Vision':
      return l10n.codCatLighting;
    case 'Comfort & Convenience':
      return l10n.codCatComfort;
    case 'Safety & Chimes':
      return l10n.codCatSafety;
    default:
      return l10n.encCatAll;
  }
}
