import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/dtc_model.dart';
import '../../data/repositories/dtc_repository.dart';
import '../widgets/dtc_repair_guide_modal.dart';

/// Comprehensive Offline Diagnostic Trouble Code Encyclopedia & Multimeter Testing Manual
class DtcEncyclopediaScreen extends StatefulWidget {
  const DtcEncyclopediaScreen({Key? key}) : super(key: key);

  @override
  State<DtcEncyclopediaScreen> createState() => _DtcEncyclopediaScreenState();
}

class _DtcEncyclopediaScreenState extends State<DtcEncyclopediaScreen> {
  final DtcRepository _repo = DtcRepository();
  final TextEditingController _searchController = TextEditingController();

  List<DtcModel> _allCodes = [];
  List<DtcModel> _filteredCodes = [];
  String _selectedCategory = "All";
  bool _isLoading = true;

  final List<String> _categories = [
    "All",
    "Powertrain",
    "Transmission",
    "Chassis",
    "Network",
    "Body",
  ];

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCodes() async {
    await _repo.loadDatabase();
    _allCodes = await _repo.getAllDtcs();
    _applyFilter();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      _filteredCodes = _allCodes.where((dtc) {
        // Filter by category
        if (_selectedCategory != "All" && dtc.category != _selectedCategory) {
          return false;
        }

        // Filter by search query
        if (query.isEmpty) return true;

        final codeMatch = dtc.code.toLowerCase().contains(query);
        final titleMatch = dtc.title.toLowerCase().contains(query) || dtc.titleAr.toLowerCase().contains(query);
        final descMatch = dtc.description.toLowerCase().contains(query) || dtc.descriptionAr.toLowerCase().contains(query);
        final checkMatch = dtc.workshopCheck.toLowerCase().contains(query) || dtc.workshopCheckAr.toLowerCase().contains(query);
        final symptomsMatch = dtc.symptoms.any((s) => s.toLowerCase().contains(query)) ||
            dtc.symptomsAr.any((s) => s.toLowerCase().contains(query));
        final causesMatch = dtc.causes.any((c) => c.toLowerCase().contains(query)) ||
            dtc.causesAr.any((c) => c.toLowerCase().contains(query));

        return codeMatch || titleMatch || descMatch || checkMatch || symptomsMatch || causesMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dtcEncyclopedia),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: AppStrings.searchDtcHint,
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundDark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryYellow))
          : Column(
              children: [
                // Category Filter Chips
                _buildCategoryChips(),

                // Results Counter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Available Fault Codes: ${_filteredCodes.length}",
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "Egyptian Automotive Presets",
                        style: TextStyle(color: AppColors.primaryYellow, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                // DTC Cards List
                Expanded(
                  child: _filteredCodes.isEmpty
                      ? const Center(
                          child: Text(
                            "No matching trouble codes found.\nTry searching with a code like 'P0171' or 'misfire'.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredCodes.length,
                          itemBuilder: (context, index) {
                            return _buildDtcCard(_filteredCodes[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: AppColors.primaryYellow,
              backgroundColor: AppColors.cardSurface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                  _applyFilter();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDtcCard(DtcModel dtc) {
    Color severityColor = AppColors.electricBlue;
    String severityLabel = "Normal";
    final sev = dtc.severity.toLowerCase();
    if (sev == 'critical') {
      severityColor = AppColors.dangerRed;
      severityLabel = "Critical";
    } else if (sev == 'high') {
      severityColor = AppColors.warningOrange;
      severityLabel = "High";
    } else if (sev == 'medium') {
      severityColor = AppColors.primaryYellow;
      severityLabel = "Medium";
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: severityColor.withOpacity(0.5), width: 1.5),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: severityColor),
          ),
          child: Text(
            dtc.code,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: severityColor,
              fontFamily: 'monospace',
            ),
          ),
        ),
        title: Text(
          dtc.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textWhite),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: severityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                severityLabel,
                style: TextStyle(color: severityColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              dtc.category,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),

                // Technical Description
                if (dtc.description.isNotEmpty) ...[
                  const Text("Technical Description:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryYellow)),
                  const SizedBox(height: 4),
                  Text(dtc.description, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textWhite)),
                  const SizedBox(height: 10),
                ],

                // Symptoms
                if (dtc.symptoms.isNotEmpty) ...[
                  const Text("Common Symptoms:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.electricBlue)),
                  const SizedBox(height: 4),
                  ...dtc.symptoms.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.fiber_manual_record, size: 8, color: AppColors.electricBlue),
                            const SizedBox(width: 6),
                            Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.textWhite))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 10),
                ],

                // Causes
                if (dtc.causes.isNotEmpty) ...[
                  const Text("Common Workshop Causes:", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.warningOrange)),
                  const SizedBox(height: 4),
                  ...dtc.causes.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Row(
                          children: [
                            const Text("• ", style: TextStyle(color: AppColors.warningOrange, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(c, style: const TextStyle(fontSize: 13, color: AppColors.textWhite))),
                          ],
                        ),
                      )),
                  const SizedBox(height: 12),
                ],

                // Multimeter workshop inspection steps
                if (dtc.workshopCheck.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryYellow.withOpacity(0.6), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune, color: AppColors.primaryYellow, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Multimeter & Pinout Inspection Guide:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          dtc.workshopCheck,
                          style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.menu_book, size: 16),
                    label: const Text("View Full Interactive Repair Guide", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () => DtcRepairGuideModal.show(context, dtc.code),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
