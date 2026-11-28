import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context).readDtcs),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).rescanDtcs,
            onPressed: state.isScanning ? null : () => state.scanTroubleCodes(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.primaryYellow,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: "${AppLocalizations.of(context).storedDtcs} (${state.storedDtcs.length})"),
            Tab(text: "${AppLocalizations.of(context).pendingDtcs} (${state.pendingDtcs.length})"),
            Tab(text: "${AppLocalizations.of(context).permanentDtcs} (${state.permanentDtcs.length})"),
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
                hintText: AppLocalizations.of(context).searchDtcHint,
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Clear DTCs button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerRed,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  minimumSize: const Size.fromHeight(52),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.delete_forever),
                label: Text(
                  AppLocalizations.of(context).clearDtcsButton,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
                                          ? AppLocalizations.of(context).dtcsClearedSuccess
                                          : (state.lastClearOutcome?.codesRemain ?? false)
                                              ? AppLocalizations.of(context).clearPartialRemaining(state.lastClearOutcome!.remainingCodes!.length, state.lastClearOutcome!.remainingCodes!.join(", "))
                                              : (state.lastClearOutcome != null && state.lastClearOutcome!.accepted)
                                                  ? AppLocalizations.of(context).clearUnconfirmed
                                                  : AppLocalizations.of(context).dtcsClearedFail,
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
                      _buildDtcList(state.storedDtcs, AppLocalizations.of(context).noStoredDtcs),
                      _buildDtcList(state.pendingDtcs, AppLocalizations.of(context).noPendingDtcs),
                      _buildDtcList(state.permanentDtcs, AppLocalizations.of(context).noPermanentDtcs),
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
          AppLocalizations.of(context).noDtcsMatching(_searchController.text),
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
