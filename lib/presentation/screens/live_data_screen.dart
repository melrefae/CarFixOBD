import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "البيانات الحية والحساسات" : AppStrings.liveSensors),
        actions: [
          IconButton(
            icon: Icon(
              state.isPolling ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: state.isPolling ? AppColors.dangerRed : AppColors.successGreen,
              size: 28,
            ),
            tooltip: state.isPolling ? "Pause Live Polling" : "Start Live Polling",
            onPressed: state.isConnected ? () => state.toggleLivePolling() : null,
          ),
          IconButton(
            icon: const Icon(Icons.show_chart, color: AppColors.accentCyan),
            tooltip: AppStrings.liveGraphs,
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
                _buildFilterChip("All", isAr ? "جميع الحساسات" : AppStrings.allSensors),
                _buildFilterChip("Engine", isAr ? "المحرك" : AppStrings.engineSensors),
                _buildFilterChip("Fuel & Turbo", isAr ? "الوقود والتوربو" : "Fuel & Turbo OEM"),
                _buildFilterChip("ABS Speeds", isAr ? "سرعات العجلات (ABS)" : "4-Wheel Speeds"),
                _buildFilterChip("Transmission", isAr ? "الفتيس والحرارة" : "Transmission"),
                _buildFilterChip("Cooling", isAr ? "دورة التبريد" : AppStrings.coolingSensors),
                _buildFilterChip("Electrical", isAr ? "الكهرباء والشحن" : AppStrings.electricalSensors),
              ],
            ),
          ),

          // 4-Wheel Speed Comparison Banner if viewing ABS or All
          if (_selectedCategory == "ABS Speeds" || _selectedCategory == "All")
            _build4WheelSpeedCard(state, isAr),

          // Turbo & Rail Pressure Target vs Actual Comparison Banner
          if (_selectedCategory == "Fuel & Turbo")
            _buildTargetVsActualCard(state, isAr),

          // Responsive Sensors Grid
          Expanded(
            child: filteredSensors.isEmpty
                ? Center(
                    child: Text(
                      isAr ? "لا توجد حساسات في هذا التصنيف" : "No sensors found in this category",
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
                    itemCount: filteredSensors.length,
                    itemBuilder: (context, index) {
                      final sensor = filteredSensors[index];
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

  Widget _build4WheelSpeedCard(ObdState state, bool isAr) {
    final fl = state.sensors.firstWhere(
      (s) => s.category == "ABS Speeds" && s.name.contains("Front-Left"),
      orElse: () => state.sensors.first,
    ).currentValue;
    final fr = state.sensors.firstWhere(
      (s) => s.category == "ABS Speeds" && s.name.contains("Front-Right"),
      orElse: () => state.sensors.first,
    ).currentValue;
    final rl = state.sensors.firstWhere(
      (s) => s.category == "ABS Speeds" && s.name.contains("Rear-Left"),
      orElse: () => state.sensors.first,
    ).currentValue;
    final rr = state.sensors.firstWhere(
      (s) => s.category == "ABS Speeds" && s.name.contains("Rear-Right"),
      orElse: () => state.sensors.first,
    ).currentValue;

    final speeds = [fl, fr, rl, rr];
    final maxSpeed = speeds.reduce((a, b) => a > b ? a : b);
    final minSpeed = speeds.reduce((a, b) => a < b ? a : b);
    final variance = maxSpeed - minSpeed;
    final hasSpeedVariance = variance > 5.0 && maxSpeed > 15.0;

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
                    isAr ? "مقارنة سرعات العجلات الأربعة (ABS)" : "4-Wheel Independent ABS Speeds",
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
                    isAr ? "فرق سرعة > 5 كم/س" : "Variance > 5 km/h",
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

  Widget _buildWheelBadge(String label, double val) {
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
            "${val.toStringAsFixed(1)} km/h",
            style: const TextStyle(fontSize: 13, color: AppColors.primaryYellow, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetVsActualCard(ObdState state, bool isAr) {
    final railActual = state.sensors.firstWhere(
      (s) => s.pid == "23" && s.category == "Fuel & Turbo",
      orElse: () => state.sensors.first,
    ).currentValue;
    final railTarget = state.sensors.firstWhere(
      (s) => s.pid == "24" && s.category == "Fuel & Turbo",
      orElse: () => state.sensors.first,
    ).currentValue;
    final turboActual = state.sensors.firstWhere(
      (s) => s.pid == "70" && s.category == "Fuel & Turbo",
      orElse: () => state.sensors.first,
    ).currentValue;
    final turboTarget = state.sensors.firstWhere(
      (s) => s.pid == "71" && s.category == "Fuel & Turbo",
      orElse: () => state.sensors.first,
    ).currentValue;

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
                isAr ? "مقارنة القيم المستهدفة والفعلية (Target vs Actual)" : "Target vs Actual OEM Tracking",
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
                      Text(isAr ? "ضغط مسطرة الوقود" : "Common Rail Fuel Pressure", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text("Actual: ${railActual.toStringAsFixed(1)} bar", style: const TextStyle(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.bold)),
                      Text("Target: ${railTarget.toStringAsFixed(1)} bar", style: const TextStyle(fontSize: 11, color: AppColors.textWhite)),
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
                      Text(isAr ? "ضغط شاحن التوربو" : "Turbo Boost Pressure", style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                      const SizedBox(height: 4),
                      Text("Actual: ${turboActual.toStringAsFixed(2)} bar", style: const TextStyle(fontSize: 12, color: AppColors.primaryYellow, fontWeight: FontWeight.bold)),
                      Text("Target: ${turboTarget.toStringAsFixed(2)} bar", style: const TextStyle(fontSize: 11, color: AppColors.textWhite)),
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
