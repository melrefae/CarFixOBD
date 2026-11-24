import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../data/models/dtc_model.dart';
import '../providers/obd_state.dart';
import '../widgets/dtc_card_item.dart';
import '../widgets/safety_confirmation_dialog.dart';

/// Screen to read, search, and clear Diagnostic Trouble Codes (DTCs)
class DtcScannerScreen extends StatefulWidget {
  const DtcScannerScreen({Key? key}) : super(key: key);

  @override
  State<DtcScannerScreen> createState() => _DtcScannerScreenState();
}

class _DtcScannerScreenState extends State<DtcScannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<DtcModel> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _onSearchChanged(String query, ObdState state) async {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await state.dtcRepo.searchByKeyword(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.readDtcs),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Rescan DTCs",
            onPressed: state.isScanning ? null : () => state.scanTroubleCodes(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: "${AppStrings.storedDtcs} (${state.storedDtcs.length})"),
            Tab(text: "${AppStrings.pendingDtcs} (${state.pendingDtcs.length})"),
            Tab(text: "${AppStrings.permanentDtcs} (${state.permanentDtcs.length})"),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => _onSearchChanged(val, state),
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
                          _onSearchChanged('', state);
                        },
                      )
                    : null,
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

          // Clear DTCs button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerRed,
                  foregroundColor: Colors.white,
                  elevation: 3,
                ),
                icon: const Icon(Icons.delete_forever),
                label: const Text(
                  AppStrings.clearDtcsButton,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: state.isScanning || !state.isConnected
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (_) => SafetyConfirmationDialog(
                            onConfirmed: () async {
                              final success = await state.clearAllTroubleCodes();
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? AppStrings.dtcsClearedSuccess
                                          : AppStrings.dtcsClearedFail,
                                    ),
                                    backgroundColor: success ? AppColors.successGreen : AppColors.dangerRed,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // DTC list display
          Expanded(
            child: _isSearching
                ? _buildSearchResults()
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDtcList(state.storedDtcs, AppStrings.noStoredDtcs),
                      _buildDtcList(state.pendingDtcs, AppStrings.noPendingDtcs),
                      _buildDtcList(state.permanentDtcs, AppStrings.noPermanentDtcs),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDtcList(List<DtcModel> dtcs, String emptyMessage) {
    if (dtcs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 56, color: AppColors.successGreen),
            const SizedBox(height: 12),
            Text(emptyMessage, style: const TextStyle(color: AppColors.textWhite, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      itemCount: dtcs.length,
      itemBuilder: (context, index) {
        return DtcCardItem(dtc: dtcs[index]);
      },
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          "No diagnostic trouble codes found matching '${_searchController.text}'",
          style: const TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return DtcCardItem(dtc: _searchResults[index]);
      },
    );
  }
}
