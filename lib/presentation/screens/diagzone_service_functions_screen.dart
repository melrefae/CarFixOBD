import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/special_function_model.dart';
import '../providers/obd_state.dart';

/// Screen displaying the 16 core Diagzone Pro special service functions & resets
class DiagzoneServiceFunctionsScreen extends StatefulWidget {
  const DiagzoneServiceFunctionsScreen({Key? key}) : super(key: key);

  @override
  State<DiagzoneServiceFunctionsScreen> createState() => _DiagzoneServiceFunctionsScreenState();
}

class _DiagzoneServiceFunctionsScreenState extends State<DiagzoneServiceFunctionsScreen> {
  final List<SpecialFunctionModel> _allFunctions = SpecialFunctionModel.getAllFunctions();
  String _selectedCategory = "All";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    final categories = ["All", ..._allFunctions.map((fn) => fn.category).toSet().toList()..sort()];

    final filtered = _allFunctions.where((fn) {
      final matchesCat = _selectedCategory == "All" || fn.category == _selectedCategory;
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          fn.title.toLowerCase().contains(q) ||
          fn.shortCode.toLowerCase().contains(q) ||
          fn.description.toLowerCase().contains(q);
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.diagzoneSpecialFunctions),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: "Search service reset (e.g. Oil, EPB, SAS, BMS, Throttle)...",
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                filled: true,
                fillColor: AppColors.cardSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    selectedColor: AppColors.primaryYellow,
                    backgroundColor: AppColors.cardSurface,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.black : AppColors.textWhite,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Reset Functions Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.15,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final fn = filtered[idx];
                return _buildFunctionCard(fn, state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionCard(SpecialFunctionModel fn, ObdState state) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showResetModal(fn, state),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(fn.icon, color: AppColors.primaryYellow, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    fn.shortCode,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              fn.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
            ),
            const SizedBox(height: 4),
            Text(
              fn.category,
              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetModal(SpecialFunctionModel fn, ObdState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool isExecuting = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(fn.icon, color: AppColors.primaryYellow, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fn.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                                Text("Target ECU: ${fn.targetEcu}", style: const TextStyle(fontSize: 12, color: AppColors.electricBlue)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(fn.description, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),

                      const Divider(height: 28, color: AppColors.cardBorder),

                      // Safety Prerequisites Checklist
                      const Text("Safety Prerequisites:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow)),
                      const SizedBox(height: 8),
                      ...fn.prerequisites.map((req) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.successGreen),
                                const SizedBox(width: 8),
                                Expanded(child: Text(req, style: const TextStyle(fontSize: 12, color: AppColors.textWhite))),
                              ],
                            ),
                          )),

                      const SizedBox(height: 16),

                      // Automated OBD Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryYellow,
                            foregroundColor: Colors.black,
                            elevation: 2,
                          ),
                          icon: isExecuting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Icon(Icons.bolt),
                          label: Text(
                            isExecuting ? "Executing OBD Reset..." : "Execute Automated OBD Reset",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          onPressed: isExecuting || !state.isConnected
                              ? null
                              : () async {
                                  setModalState(() => isExecuting = true);
                                  final ok = await state.executeSpecialFunction(fn);
                                  setModalState(() => isExecuting = false);

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          ok
                                              ? "${fn.title} completed successfully!"
                                              : "OBD automated reset command rejected by ECU. Use manual procedure below.",
                                        ),
                                        backgroundColor: ok ? AppColors.successGreen : AppColors.dangerRed,
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Egyptian Market Manual Procedure Section
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.menu_book, size: 18, color: AppColors.accentCyan),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    fn.manualProcedureTitle,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.accentCyan),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ...fn.manualSteps.map((step) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("• ", style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: Text(step, style: const TextStyle(fontSize: 12, color: AppColors.textWhite, height: 1.3)),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
