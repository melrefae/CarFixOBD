import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        const SnackBar(content: Text("Please connect to OBD adapter first"), backgroundColor: AppColors.warningOrange),
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
        title: const Text(AppStrings.terminal),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Clear Terminal Logs",
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
                _buildQuickCmdChip("AT Z", "Reset Adapter", state),
                _buildQuickCmdChip("AT RV", "Read Battery", state),
                _buildQuickCmdChip("AT DP", "Active Protocol", state),
                _buildQuickCmdChip("0100", "Supported PIDs 1-20", state),
                _buildQuickCmdChip("01 0C", "Engine RPM", state),
                _buildQuickCmdChip("01 0D", "Vehicle Speed", state),
                _buildQuickCmdChip("03", "Read Stored DTCs", state),
                _buildQuickCmdChip("07", "Read Pending DTCs", state),
                _buildQuickCmdChip("09 02", "Read VIN", state),
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
                  ? const Center(
                      child: Text(
                        "ELM327 Serial Terminal Ready.\nType an AT or OBD command below or tap a quick shortcut above.",
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
                      hintText: "Enter AT or OBD command (e.g. AT RV or 01 0C)...",
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.chevron_right, color: AppColors.primaryYellow),
                      filled: true,
                      fillColor: AppColors.cardSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
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
                  tooltip: "Send Command",
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
