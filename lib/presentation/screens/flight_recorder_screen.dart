import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../../data/models/flight_record_model.dart';
import '../../domain/services/flight_recorder_service.dart';
import '../providers/obd_state.dart';

/// Screen for black box telemetry flight logging, timeline scrubber playback, and CSV export
class FlightRecorderScreen extends StatefulWidget {
  const FlightRecorderScreen({Key? key}) : super(key: key);

  @override
  State<FlightRecorderScreen> createState() => _FlightRecorderScreenState();
}

class _FlightRecorderScreenState extends State<FlightRecorderScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = Provider.of<ObdState>(context);
    final recorder = state.flightRecorder;
    final sessions = recorder.savedSessions;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.frTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Recording Controls Hero Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: recorder.isRecording ? AppColors.dangerRed : AppColors.cardBorder,
                  width: recorder.isRecording ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recorder.isRecording ? l10n.frActive : l10n.frBlackBox,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            recorder.isRecording
                                ? l10n.frFramesLogged(recorder.currentSession?.frameCount ?? 0, ((recorder.currentSession?.durationMs ?? 0) / 1000).toStringAsFixed(1))
                                : l10n.frRecordsDesc,
                            style: TextStyle(
                              fontSize: 12,
                              color: recorder.isRecording ? AppColors.dangerRed : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (recorder.isRecording ? AppColors.dangerRed : AppColors.primaryYellow).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          recorder.isRecording ? Icons.fiber_manual_record : Icons.flight_takeoff,
                          color: recorder.isRecording ? AppColors.dangerRed : AppColors.primaryYellow,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: recorder.isRecording ? AppColors.dangerRed : AppColors.primaryYellow,
                        foregroundColor: recorder.isRecording ? Colors.white : Colors.black,
                        elevation: 2,
                        minimumSize: const Size(double.infinity, 52),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(recorder.isRecording ? Icons.stop : Icons.fiber_manual_record),
                      label: Text(
                        recorder.isRecording ? l10n.frStop : l10n.frStart,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      onPressed: () {
                        setState(() {
                          if (recorder.isRecording) {
                            recorder.stopRecording();
                          } else {
                            final vehicleName = state.selectedVehicle?.model ?? l10n.frVehicleFallback;
                            recorder.startRecording(vehicleTitle: vehicleName);
                            if (!state.isPolling) {
                              state.toggleLivePolling();
                            }
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              l10n.frSavedLogs,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
            ),
            const SizedBox(height: 10),

            if (sessions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Text(
                  l10n.frNoLogs,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              )
            else
              ...sessions.map((session) => _buildSessionCard(session, recorder)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(FlightRecordingSession session, FlightRecorderService recorder) {
    final l10n = AppLocalizations.of(context);
    final durationSec = (session.durationMs / 1000).toStringAsFixed(1);
    final dateStr = "${session.recordedAt.hour.toString().padLeft(2, '0')}:${session.recordedAt.minute.toString().padLeft(2, '0')} • ${session.recordedAt.day}/${session.recordedAt.month}/${session.recordedAt.year}";

    return Card(
      color: AppColors.cardSurface,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.vehicleTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textWhite)),
                      const SizedBox(height: 2),
                      Text(l10n.frFramesEntry(dateStr, session.frameCount), style: const TextStyle(fontSize: 11, color: AppColors.textDisabled)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share, size: 20, color: AppColors.accentCyan),
                  tooltip: l10n.frExportCsv,
                  onPressed: () {
                    final csv = session.toCsv();
                    Share.share(csv, subject: "${session.vehicleTitle}_FlightLog.csv");
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.textDisabled),
                  tooltip: l10n.frDeleteLog,
                  onPressed: () {
                    setState(() {
                      recorder.deleteSession(session.id);
                    });
                  },
                ),
              ],
            ),
            const Divider(color: AppColors.cardBorder),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricSmall(l10n.frDuration, "$durationSec${l10n.unitSec}", AppColors.electricBlue),
                _buildMetricSmall(l10n.frMaxSpeed, "${session.maxSpeed.toInt()} ${l10n.unitKmh}", AppColors.primaryYellow),
                _buildMetricSmall(l10n.frMaxRpm, "${session.maxRpm.toInt()}", AppColors.accentCyan),
                _buildMetricSmall(l10n.frMaxTemp, "${session.maxCoolant.toInt()}${l10n.unitDegC}", AppColors.dangerRed),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryYellow,
                  side: const BorderSide(color: AppColors.primaryYellow),
                ),
                icon: const Icon(Icons.tune, size: 16),
                label: Text(l10n.frScrub, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () => _openScrubberModal(session, recorder),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSmall(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
      ],
    );
  }

  void _openScrubberModal(FlightRecordingSession session, FlightRecorderService recorder) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        double currentPositionMs = 0.0;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final frame = recorder.getFrameAtTimestamp(session, currentPositionMs.toInt()) ??
                (session.frames.isNotEmpty ? session.frames.first : null);

            return Container(
              padding: const EdgeInsets.all(20),
              height: 480,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(session.vehicleTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textWhite)),
                          Text(
                            l10n.frTimestamp((currentPositionMs / 1000).toStringAsFixed(2), (session.durationMs / 1000).toStringAsFixed(2)),
                            style: const TextStyle(fontSize: 12, color: AppColors.accentCyan),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textMuted),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Slider(
                    value: currentPositionMs.clamp(0.0, session.durationMs.toDouble()),
                    min: 0.0,
                    max: session.durationMs > 0 ? session.durationMs.toDouble() : 1.0,
                    activeColor: AppColors.primaryYellow,
                    inactiveColor: Colors.black38,
                    onChanged: (val) {
                      setModalState(() => currentPositionMs = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  if (frame != null) ...[
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.4,
                        children: [
                          _buildScrubStat(l10n.frSpeed, "${frame.speed.toInt()} ${l10n.unitKmh}", AppColors.primaryYellow),
                          _buildScrubStat("RPM", "${frame.rpm.toInt()}", AppColors.accentCyan),
                          _buildScrubStat(l10n.frCoolant, "${frame.coolantTemp.toInt()}${l10n.unitDegC}", AppColors.dangerRed),
                          _buildScrubStat(l10n.frThrottle, "${frame.throttlePercent.toInt()}%", AppColors.electricBlue),
                          _buildScrubStat("MAP", "${frame.mapKpa.toInt()} kPa", AppColors.textWhite),
                          _buildScrubStat(l10n.frBattery, "${frame.batteryVoltage.toStringAsFixed(1)}${l10n.unitVolt}", AppColors.successGreen),
                          _buildScrubStat("STFT", "${frame.stft.toStringAsFixed(1)}%", AppColors.primaryYellow),
                          _buildScrubStat("LTFT", "${frame.ltft.toStringAsFixed(1)}%", AppColors.electricBlue),
                          _buildScrubStat("O2 B1S1", "${frame.o2B1S1.toStringAsFixed(2)}${l10n.unitVolt}", AppColors.accentCyan),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScrubStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
