import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import 'package:automotive_scanner/l10n/gen/app_localizations.dart';
import '../providers/obd_state.dart';
import '../widgets/sensor_gauge_card.dart';
import 'live_graph_screen.dart';

/// Live sensor data screen with enhanced OEM deep telemetry & comparison visualizers
class LiveDataScreen extends StatefulWidget {
  const LiveDataScreen({Key? key}) : super(key: key);

  @override
  State<LiveDataScreen> createState() => _LiveDataScreenState();
}

class _LiveDataScreenState extends State<LiveDataScreen> {
  String _selectedCategory = "All";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<ObdState>(context, listen: false);
      if (state.isConnected && !state.isPolling) {
        state.toggleLivePolling();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;

    final filteredSensors = _selectedCategory == "All"
        ? state.sensors
        : state.sensors.where((s) => s.category == _selectedCategory).toList();

    // Sort supported & active readings before unsupported ones in "All" view
    final sortedSensors = List.of(filteredSensors)
      ..sort((a, b) {
        if (a.hasValidReading != b.hasValidReading) return a.hasValidReading ? -1 : 1;
        if (a.isSupported != b.isSupported) return a.isSupported ? -1 : 1;
        return 0;
      });

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Flexible(
              child: Text(
                AppLocalizations.of(context).liveSensorsTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (state.isPolling && state.pollingRateHz > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.successGreen.withOpacity(0.6)),
                ),
                child: Text(
                  "${state.pollingRateHz.toStringAsFixed(1)} Hz",
                  style: const TextStyle(fontSize: 10, color: AppColors.successGreen, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.radar, color: AppColors.primaryYellow),
            tooltip: AppLocalizations.of(context).discoverPids,
            onPressed: state.isConnected ? () => state.refreshSupportedPidsAndPoll() : null,
          ),
          IconButton(
            icon: Icon(
              state.isPolling ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: state.isPolling ? AppColors.dangerRed : AppColors.successGreen,
              size: 28,
            ),
            tooltip: state.isPolling ? AppLocalizations.of(context).pausePolling : AppLocalizations.of(context).startPolling,
            onPressed: state.isConnected ? () => state.toggleLivePolling() : null,
          ),
          IconButton(
            icon: const Icon(Icons.show_chart, color: AppColors.accentCyan),
            tooltip: AppLocalizations.of(context).liveGraphsTitle,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveGraphScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip("All", AppLocalizations.of(context).allSensors),
                _buildFilterChip("Engine", AppLocalizations.of(context).engineSensors),
                _buildFilterChip("FuelAir", AppLocalizations.of(context).fuelAir),
                _buildFilterChip("Fuel & Turbo", AppLocalizations.of(context).railTurbo),
                _buildFilterChip("Cooling", AppLocalizations.of(context).coolingSensors),
                _buildFilterChip("Electrical", AppLocalizations.of(context).electricalSensors),
                _buildFilterChip("Transmission", AppLocalizations.of(context).transmission),
                _buildFilterChip("ABS Speeds", AppLocalizations.of(context).absSpeeds),
                if (state.sensors.any((s) => s.category == "Custom"))
                  _buildFilterChip("Custom", AppLocalizations.of(context).oemCustom),
              ],
            ),
          ),

          // 4-Wheel Speed Comparison Banner if viewing ABS or when ABS sensors have readings
          if (_selectedCategory == "ABS Speeds" ||
              (_selectedCategory == "All" && state.sensors.any((s) => s.category == "ABS Speeds" && s.hasValidReading)))
            _build4WheelSpeedCard(state, isAr),

          // Turbo & Rail Pressure Target vs Actual Comparison Banner
          if (_selectedCategory == "Fuel & Turbo")
            _buildTargetVsActualCard(state, isAr),

          // Responsive Sensors Grid
          Expanded(
            child: sortedSensors.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context).noSensorsCategory,
                      style: const TextStyle(color: AppColors.textMuted),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.25,
                    ),
                    itemCount: sortedSensors.length,
                    itemBuilder: (context, index) {
                      final sensor = sortedSensors[index];
                      return SensorGaugeCard(
                        sensor: sensor,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LiveGraphScreen(initialSensorPid: sensor.pid),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
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
              _selectedCategory = category;
            });
          }
        },
      ),
    );
  }

  double? _findSensorVal(ObdState state, String category, String match) {
    for (final s in state.sensors) {
      if (s.category == category && (s.name.contains(match) || s.pid == match)) {
        return s.hasValidReading ? s.currentValue : null;
      }
    }
    return null;
  }

  Widget _build4WheelSpeedCard(ObdState state, bool isAr) {
    final fl = _findSensorVal(state, "ABS Speeds", "Front-Left");
    final fr = _findSensorVal(state, "ABS Speeds", "Front-Right");
    final rl = _findSensorVal(state, "ABS Speeds", "Rear-Left");
    final rr = _findSensorVal(state, "ABS Speeds", "Rear-Right");

    final speeds = [fl, fr, rl, rr].whereType<double>().toList();
    final maxSpeed = speeds.isNotEmpty ? speeds.reduce((a, b) => a > b ? a : b) : 0.0;
    final minSpeed = speeds.isNotEmpty ? speeds.reduce((a, b) => a < b ? a : b) : 0.0;
    final variance = maxSpeed - minSpeed;
    final hasSpeedVariance = speeds.length >= 2 && variance > 5.0 && maxSpeed > 15.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasSpeedVariance ? AppColors.warningOrange : const Color(0xFF263238),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.speed, color: AppColors.accentCyan, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    AppLocalizations.of(context).absCompareTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                  ),
                ],
              ),
              if (hasSpeedVariance)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    AppLocalizations.of(context).variance5,
                    style: const TextStyle(fontSize: 10, color: AppColors.warningOrange, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWheelBadge("FL", fl),
              _buildWheelBadge("FR", fr),
              _buildWheelBadge("RL", rl),
              _buildWheelBadge("RR", rr),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWheelBadge(String label, double? val) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF37474F)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            val != null ? "${val.toStringAsFixed(1)} km/h" : "--",
            style: TextStyle(
              fontSize: 13,
              color: val != null ? AppColors.primaryYellow : AppColors.textDisabled,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetVsActualCard(ObdState state, bool isAr) {
    final railActual = _findSensorVal(state, "Fuel & Turbo", "23");
    final railTarget = _findSensorVal(state, "Fuel & Turbo", "24");
    final turboActual = _findSensorVal(state, "Fuel & Turbo", "70");
    final turboTarget = _findSensorVal(state, "Fuel & Turbo", "71");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF263238)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows, color: AppColors.primaryYellow, size: 18),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context).targetVsActual,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).railPressure, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(AppLocalizations.of(context).actualValue(railActual != null ? '${railActual.toStringAsFixed(1)} bar' : '--'), style: const TextStyle(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.bold)),
                      Text(AppLocalizations.of(context).targetValue(railTarget != null ? '${railTarget.toStringAsFixed(1)} bar' : '--'), style: const TextStyle(fontSize: 11, color: AppColors.textWhite)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppLocalizations.of(context).turboBoost, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text(AppLocalizations.of(context).actualValue(turboActual != null ? '${turboActual.toStringAsFixed(2)} bar' : '--'), style: const TextStyle(fontSize: 12, color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
                      Text(AppLocalizations.of(context).targetValue(turboTarget != null ? '${turboTarget.toStringAsFixed(2)} bar' : '--'), style: const TextStyle(fontSize: 11, color: AppColors.textWhite)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
