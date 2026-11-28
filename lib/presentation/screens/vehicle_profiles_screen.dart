import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/vehicle_profile.dart';
import '../../data/models/worldwide_brand.dart';
import '../providers/obd_state.dart';
import '../widgets/custom_pid_dialog.dart';
import 'full_vehicle_test_screen.dart';

/// Vehicle profiles screen with hierarchical drill-down and 250+ brand catalog
class VehicleProfilesScreen extends StatefulWidget {
  const VehicleProfilesScreen({Key? key}) : super(key: key);

  @override
  State<VehicleProfilesScreen> createState() => _VehicleProfilesScreenState();
}

class _VehicleProfilesScreenState extends State<VehicleProfilesScreen> with SingleTickerProviderStateMixin {

String _localizedRegion(BuildContext context, String region) {
  final l10n = AppLocalizations.of(context);
  switch (region) {
    case 'All Regions': return l10n.regionAll;
    case 'Asian': return l10n.regionAsian;
    case 'European': return l10n.regionEuropean;
    case 'American': return l10n.regionAmerican;
    case 'Chinese': return l10n.regionChinese;
    case 'Commercial': return l10n.regionCommercial;
    default: return region;
  }
}

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRegion = 'All Regions';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final regions = state.vehicleRepo.getRegions();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).vehicleProfiles),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(icon: const Icon(Icons.directions_car), text: AppLocalizations.of(context).tabEgyptianPresets),
            Tab(icon: const Icon(Icons.public), text: AppLocalizations.of(context).tabGlobalBrands),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchVehicles,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Region filter chips
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final r = regions[i];
                final isSelected = _selectedRegion == r;
                return ChoiceChip(
                  label: Text(_localizedRegion(context, r)),
                  selected: isSelected,
                  selectedColor: AppColors.primaryYellow,
                  backgroundColor: AppColors.cardSurface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textWhite,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedRegion = r;
                      });
                    }
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 6),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEgyptianPresetsTab(state),
                _buildWorldwideBrandsTab(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEgyptianPresetsTab(ObdState state) {
    var list = state.vehicleRepo.searchProfiles(_searchQuery);
    if (_selectedRegion != 'All Regions') {
      list = list.where((p) => p.region.toLowerCase() == _selectedRegion.toLowerCase()).toList();
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).noProfilesFound(_localizedRegion(context, _selectedRegion), _searchQuery),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final profile = list[index];
        final isSelected = state.selectedVehicle?.id == profile.id;
        final isAr = state.isArabic;
        final displayName = profile.getDisplayName(isAr);
        final notes = profile.getDisplayNotes(isAr);

        return Card(
          color: isSelected ? AppColors.cardSurfaceHighlight : AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? AppColors.primaryYellow : const Color(0xFF263238),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.textWhite,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              profile.years,
                              style: const TextStyle(fontSize: 10, color: AppColors.primaryYellow),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              profile.region,
                              style: const TextStyle(fontSize: 9, color: AppColors.accentCyan),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isSelected)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context).activeProfile,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryYellow,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                            icon: const Icon(Icons.speed, size: 14),
                            label: Text(
                              AppLocalizations.of(context).fullTest,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FullVehicleTestScreen()),
                              );
                            },
                          ),
                        ],
                      )
                    else
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () {
                          state.selectProfile(profile);
                        },
                        child: Text(AppLocalizations.of(context).activateProfile, style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${AppLocalizations.of(context).engineLabel}: ${profile.engine} | ${AppLocalizations.of(context).transmissionLabel}: ${profile.transmission}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Text(
                  '${AppLocalizations.of(context).protocolLabel} ${profile.protocol} (${profile.atProtocolCmd})',
                  style: const TextStyle(fontSize: 11, color: AppColors.electricBlue),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${AppLocalizations.of(context).workshopNote}: $notes',
                      style: const TextStyle(fontSize: 11, color: AppColors.textWhite),
                    ),
                  ),
                ],
                if (profile.customPids.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: profile.customPids.map((cp) {
                      return Chip(
                        backgroundColor: AppColors.cardSurface,
                        label: Text(
                          "${cp.getDisplayName(state.isArabic)} (PID ${cp.pid})",
                          style: const TextStyle(fontSize: 10, color: AppColors.accentCyan),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primaryYellow),
                    label: Text(
                      AppLocalizations.of(context).addCustomPid,
                      style: TextStyle(fontSize: 11, color: AppColors.primaryYellow),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => CustomPidDialog(
                          onSaved: (newPid) {
                            profile.customPids.add(newPid);
                            state.notifyUpdate();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorldwideBrandsTab(ObdState state) {
    final brands = state.vehicleRepo.getWorldwideBrands(
      region: _selectedRegion,
      query: _searchQuery,
    );

    if (brands.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.public_off, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context).noBrandsFound(_localizedRegion(context, _selectedRegion), _searchQuery),
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: brands.length,
      itemBuilder: (context, index) {
        final brand = brands[index];
        final models = state.vehicleRepo.getModelsByBrand(brand.name);
        final hasPresets = models.isNotEmpty;
        final isBrandSelected = state.selectedVehicle?.make.toLowerCase() == brand.name.toLowerCase();

        return Card(
          color: isBrandSelected ? AppColors.cardSurfaceHighlight : AppColors.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isBrandSelected ? AppColors.primaryYellow : const Color(0xFF263238),
              width: isBrandSelected ? 1.5 : 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: isBrandSelected ? AppColors.primaryYellow : const Color(0xFF263238),
              foregroundColor: isBrandSelected ? Colors.black : AppColors.textWhite,
              child: Text(
                brand.name.isNotEmpty ? brand.name[0] : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Row(
              children: [
                Text(
                  brand.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textWhite,
                    fontSize: 15,
                  ),
                ),
                if (state.isArabic) ...[
                  const SizedBox(width: 8),
                  Text(
                    brand.nameAr,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Row(
              children: [
                Text(
                  "${_localizedRegion(context, brand.region)} • ${brand.country}",
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                if (hasPresets)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalizations.of(context).egyptianPresetsCount('${models.length}'),
                      style: const TextStyle(fontSize: 10, color: AppColors.successGreen),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppLocalizations.of(context).genericUdsObd2,
                      style: TextStyle(fontSize: 10, color: AppColors.electricBlue),
                    ),
                  ),
              ],
            ),
            trailing: hasPresets
                ? TextButton(
                    onPressed: () => _showBrandModelsModal(context, state, brand, models),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context).selectModel, style: const TextStyle(color: AppColors.primaryYellow, fontSize: 12)),
                        Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primaryYellow),
                      ],
                    ),
                  )
                : OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                    onPressed: () {
                      final genericProfile = state.vehicleRepo.createGenericProfile(brand);
                      state.selectProfile(genericProfile);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLocalizations.of(context).activatedGenericProfile(brand.name)),
                          backgroundColor: AppColors.cardSurface,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(AppLocalizations.of(context).activateProfile, style: const TextStyle(fontSize: 11)),
                  ),
          ),
        );
      },
    );
  }

  void _showBrandModelsModal(
    BuildContext context,
    ObdState state,
    WorldwideBrand brand,
    List<VehicleProfile> models,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).brandModelsTitle(state.isArabic ? "${brand.name} (${brand.nameAr})" : brand.name),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textWhite,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF263238)),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: models.length,
                  itemBuilder: (context, i) {
                    final p = models[i];
                    final isSel = state.selectedVehicle?.id == p.id;
                    return Card(
                      color: isSel ? AppColors.cardSurfaceHighlight : AppColors.cardSurface,
                      child: ListTile(
                        title: Text(p.model, style: const TextStyle(color: AppColors.textWhite)),
                        subtitle: Text("${p.years} • ${p.engine}", style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        trailing: isSel
                            ? const Icon(Icons.check_circle, color: AppColors.successGreen)
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () {
                                  state.selectProfile(p);
                                  Navigator.pop(ctx);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const FullVehicleTestScreen()),
                                  );
                                },
                                child: Text(AppLocalizations.of(context).testShort, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
