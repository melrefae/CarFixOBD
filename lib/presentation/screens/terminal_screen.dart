import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../providers/obd_state.dart';

/// Advanced ELM327 OBD-II Command Terminal for technicians and engineers
class TerminalScreen extends StatefulWidget {
  const TerminalScreen({Key? key}) : super(key: key);

  @override
  State<TerminalScreen> createState() => _TerminalScreenState();
}

class _TerminalScreenState extends State<TerminalScreen> {
  final TextEditingController _cmdController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _logs = [];
  bool _isSending = false;

  void _sendCommand(String cmd, ObdState state) async {
    if (cmd.trim().isEmpty) return;
    if (!state.isConnected || state.driver == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).connectFirstSnack), backgroundColor: AppColors.warningOrange),
      );
      return;
    }

    final trimmed = cmd.trim();
    _cmdController.clear();

    setState(() {
      _logs.add({'type': 'tx', 'text': trimmed});
      _isSending = true;
    });

    _scrollToBottom();

    try {
      final reply = await state.driver!.executeCommand(trimmed);
      setState(() {
        _logs.add({'type': 'rx', 'text': reply});
      });
    } catch (e) {
      setState(() {
        _logs.add({'type': 'err', 'text': 'Error: $e'});
      });
    } finally {
      setState(() {
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).terminalTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: AppLocalizations.of(context).clearTerminalTooltip,
            onPressed: () {
              setState(() {
                _logs.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Command Shortcuts
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                _buildQuickCmdChip("AT Z", AppLocalizations.of(context).qcResetAdapter, state),
                _buildQuickCmdChip("AT RV", AppLocalizations.of(context).qcReadBattery, state),
                _buildQuickCmdChip("AT DP", AppLocalizations.of(context).qcActiveProtocol, state),
                _buildQuickCmdChip("0100", AppLocalizations.of(context).qcSupportedPids, state),
                _buildQuickCmdChip("01 0C", AppLocalizations.of(context).qcEngineRpm, state),
                _buildQuickCmdChip("01 0D", AppLocalizations.of(context).qcVehicleSpeed, state),
                _buildQuickCmdChip("03", AppLocalizations.of(context).qcReadStoredDtcs, state),
                _buildQuickCmdChip("07", AppLocalizations.of(context).qcReadPendingDtcs, state),
                _buildQuickCmdChip("09 02", AppLocalizations.of(context).qcReadVin, state),
              ],
            ),
          ),

          // Console Output Window
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF263238)),
              ),
              child: _logs.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).terminalReadyHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textDisabled, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        Color color = AppColors.textWhite;
                        String prefix = "";

                        if (log['type'] == 'tx') {
                          color = AppColors.primaryYellow;
                          prefix = "> ";
                        } else if (log['type'] == 'rx') {
                          color = AppColors.successGreen;
                          prefix = "< ";
                        } else {
                          color = AppColors.dangerRed;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            "$prefix${log['text']}",
                            style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: color),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // Input field and send button
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cmdController,
                    style: const TextStyle(fontFamily: 'monospace', color: AppColors.textWhite),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).terminalInputHint,
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.chevron_right, color: AppColors.primaryYellow),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onSubmitted: (val) => _sendCommand(val, state),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSending
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.primaryYellow, strokeWidth: 2))
                      : const Icon(Icons.send, color: AppColors.primaryYellow),
                  tooltip: AppLocalizations.of(context).sendCommandTooltip,
                  onPressed: _isSending ? null : () => _sendCommand(_cmdController.text, state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCmdChip(String cmd, String title, ObdState state) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        backgroundColor: AppColors.cardSurface,
        label: Text("$cmd ($title)", style: const TextStyle(fontSize: 11, color: AppColors.textWhite)),
        onPressed: () => _sendCommand(cmd, state),
      ),
    );
  }
}
