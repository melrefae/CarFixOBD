import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/ar_component_models.dart';
import '../../data/models/sensor_pid.dart';
import '../providers/obd_state.dart';

/// Augmented Reality (AR) Engine Bay Component Locator & Live Sensor HUD
class ArEngineBayHudScreen extends StatefulWidget {
  const ArEngineBayHudScreen({super.key});

  @override
  State<ArEngineBayHudScreen> createState() => _ArEngineBayHudScreenState();
}

class _ArEngineBayHudScreenState extends State<ArEngineBayHudScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _radarController;
  EngineComponentCategory? _selectedCategory;
  EngineComponentTag? _activeInspectedComponent;
  int _snapshotCount = 0;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final obdState = Provider.of<ObdState>(context);
    final isAr = obdState.isArabic;

    final filteredComponents = _selectedCategory == null
        ? EngineComponentTag.standardEngineBay
        : EngineComponentTag.standardEngineBay
            .where((c) => c.category == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.8),
        title: Text(isAr ? "نظارة الواقع المعزز لحوض المحرك AR" : "AR Engine Bay HUD Overlay"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_camera, color: AppColors.primaryYellow),
            tooltip: isAr ? "التقاط صورة فحص معتمدة" : "Capture AR Inspection Photo",
            onPressed: () {
              setState(() {
                _snapshotCount++;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.cardSurface,
                  content: Text(
                    isAr
                        ? "تم التقاط صورة الفحص #$_snapshotCount وحفظها في التقرير! 📸"
                        : "AR inspection photo #$_snapshotCount captured and saved to report! 📸",
                    style: const TextStyle(color: AppColors.primaryYellow),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Camera Viewfinder Canvas with HUD Grid & Crosshairs
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _radarController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ArHudViewfinderPainter(
                    radarSweepAngle: _radarController.value * 2 * math.pi,
                  ),
                );
              },
            ),
          ),

          // 2. Center Targeting Reticle
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.electricBlue.withOpacity(0.35), width: 1.5),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryYellow,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // 3. Floating Interactive Component Hotspot Pins
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: filteredComponents.map((comp) {
                  final x = comp.relativeX * constraints.maxWidth;
                  final y = comp.relativeY * constraints.maxHeight;

                  final isSelected = _activeInspectedComponent?.id == comp.id;

                  return Positioned(
                    left: x - 24,
                    top: y - 24,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeInspectedComponent = comp;
                        });
                        _showComponentDetailSheet(context, comp, isAr, obdState);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? AppColors.primaryYellow
                                  : AppColors.cardSurface.withOpacity(0.85),
                              border: Border.all(
                                color: isSelected ? Colors.white : _getCategoryColor(comp.category),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getCategoryColor(comp.category).withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(comp.category),
                              color: isSelected ? Colors.black : _getCategoryColor(comp.category),
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white24, width: 0.5),
                            ),
                            child: Text(
                              comp.name(isAr).split(' ').first,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // 4. Category Filter Chips at Top
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(null, isAr ? "الكل" : "All Components", isAr),
                  _buildFilterChip(EngineComponentCategory.sensor, isAr ? "حساسات" : "Sensors", isAr),
                  _buildFilterChip(EngineComponentCategory.actuator, isAr ? "مشغلات" : "Actuators", isAr),
                  _buildFilterChip(EngineComponentCategory.ignition, isAr ? "إشعال" : "Ignition", isAr),
                  _buildFilterChip(EngineComponentCategory.module, isAr ? "كنترول/SGW" : "Modules", isAr),
                ],
              ),
            ),
          ),

          // 5. Active Target Telemetry HUD at Bottom
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.electricBlue.withOpacity(0.4), width: 1.2),
                boxShadow: const [
                  BoxShadow(color: Colors.black87, blurRadius: 16, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.view_in_ar, color: AppColors.primaryYellow, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _activeInspectedComponent != null
                              ? _activeInspectedComponent!.name(isAr)
                              : (isAr ? "وجّه الكاميرا أو اضغط على أي حساس" : "Aim viewfinder or tap any component tag"),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _activeInspectedComponent != null
                              ? (!obdState.isConnected
                                  ? (isAr ? "المحول مفصول • اعرض التفاصيل لإرشادات الفحص" : "OBD Disconnected • Inspect for testing guide")
                                  : () {
                                      final pidLookup = _activeInspectedComponent!.livePidCode.length >= 2
                                          ? _activeInspectedComponent!.livePidCode.substring(_activeInspectedComponent!.livePidCode.length - 2).toUpperCase()
                                          : _activeInspectedComponent!.livePidCode.toUpperCase();
                                      final s = obdState.sensors.cast<SensorPid?>().firstWhere(
                                        (sp) => sp != null && sp.pid.toUpperCase() == pidLookup,
                                        orElse: () => null,
                                      );
                                      return s != null
                                          ? (isAr ? "قراءة حية: ${s.currentValue.toStringAsFixed(1)} ${s.unit.isNotEmpty ? s.unit : _activeInspectedComponent!.liveUnits}" : "Live: ${s.currentValue.toStringAsFixed(1)} ${s.unit.isNotEmpty ? s.unit : _activeInspectedComponent!.liveUnits}")
                                          : (isAr ? "قيد قراءة الحساس... • OEM: ${_activeInspectedComponent!.nominalReading(isAr)}" : "Polling sensor... • OEM: ${_activeInspectedComponent!.nominalReading(isAr)}");
                                    }())
                              : (isAr ? "8 نقاط فحص نشطة بحوض المحرك" : "8 Active Engine Bay Target Pins"),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (_activeInspectedComponent != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                      ),
                      onPressed: () {
                        _showComponentDetailSheet(context, _activeInspectedComponent!, isAr, obdState);
                      },
                      child: Text(isAr ? "تفاصيل الفيشة" : "Inspect", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(EngineComponentCategory? category, String label, bool isArabic) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        backgroundColor: Colors.black87,
        selectedColor: AppColors.primaryYellow,
        checkmarkColor: Colors.black,
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Color _getCategoryColor(EngineComponentCategory category) {
    switch (category) {
      case EngineComponentCategory.sensor:
        return AppColors.accentCyan;
      case EngineComponentCategory.actuator:
        return AppColors.primaryAmber;
      case EngineComponentCategory.ignition:
        return AppColors.dangerRed;
      case EngineComponentCategory.module:
        return AppColors.electricBlue;
      case EngineComponentCategory.harness:
        return AppColors.successGreen;
    }
  }

  IconData _getCategoryIcon(EngineComponentCategory category) {
    switch (category) {
      case EngineComponentCategory.sensor:
        return Icons.sensors;
      case EngineComponentCategory.actuator:
        return Icons.precision_manufacturing;
      case EngineComponentCategory.ignition:
        return Icons.bolt;
      case EngineComponentCategory.module:
        return Icons.memory;
      case EngineComponentCategory.harness:
        return Icons.cable;
    }
  }

  void _showComponentDetailSheet(
    BuildContext context,
    EngineComponentTag comp,
    bool isArabic,
    ObdState obdState,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(comp.category).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getCategoryIcon(comp.category), color: _getCategoryColor(comp.category), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comp.name(isArabic),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryYellow),
                            ),
                            Text(
                              "PID: 0x${comp.livePidCode} | Category: ${comp.category.name.toUpperCase()}",
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),

                  // Live Telemetry Value
                  _buildSectionTitle(isArabic ? "القيمة الحية من كمبيوتر المركبة:" : "Live Vehicle Telemetry:"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: obdState.isConnected
                            ? AppColors.successGreen.withOpacity(0.4)
                            : AppColors.warningOrange.withOpacity(0.4),
                      ),
                    ),
                    child: Builder(
                      builder: (context) {
                        if (!obdState.isConnected) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isArabic ? "حالة الاتصال:" : "OBD Link:",
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.link_off, size: 16, color: AppColors.warningOrange),
                                  const SizedBox(width: 4),
                                  Text(
                                    isArabic ? "غير متصل (يلزم ربط المحول)" : "Disconnected (Hardware Offline)",
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warningOrange),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }

                        final pidLookup = comp.livePidCode.length >= 2
                            ? comp.livePidCode.substring(comp.livePidCode.length - 2).toUpperCase()
                            : comp.livePidCode.toUpperCase();
                        final matchingSensor = obdState.sensors.cast<SensorPid?>().firstWhere(
                          (s) => s != null && s.pid.toUpperCase() == pidLookup,
                          orElse: () => null,
                        );

                        final displayVal = matchingSensor != null
                            ? "${matchingSensor.currentValue.toStringAsFixed(1)} ${matchingSensor.unit.isNotEmpty ? matchingSensor.unit : comp.liveUnits}"
                            : (isArabic ? "قيد القراءة اللحظية..." : "Polling Live Sensor...");

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isArabic ? "القراءة اللحظية الحية:" : "Current Live Reading:",
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(right: 6),
                                  decoration: const BoxDecoration(
                                    color: AppColors.successGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                Text(
                                  displayVal,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // Factory OEM Range
                  _buildSectionTitle(isArabic ? "النطاق القياسي للمصنع (OEM):" : "Nominal Factory OEM Range:"),
                  Text(
                    comp.nominalReading(isArabic),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Multimeter Probe Test Instructions
                  _buildSectionTitle(isArabic ? "دليل فحص الأطراف بالأفوميتر (Multimeter):" : "Multimeter Probe Testing Guide:"),
                  Text(
                    comp.multimeterTestTip(isArabic),
                    style: const TextStyle(fontSize: 12, color: AppColors.accentCyan, height: 1.3),
                  ),
                  const SizedBox(height: 12),

                  // Pinout Wire Layout
                  _buildSectionTitle(isArabic ? "مخطط أطراف الفيشة (Pinout):" : "Harness Connector Pinout:"),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      comp.pinoutSummary,
                      style: const TextStyle(fontSize: 11, fontFamily: "monospace", color: AppColors.primaryYellow),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Failure Symptoms
                  _buildSectionTitle(isArabic ? "أعراض التلف والأكواد الشائعة:" : "Failure Symptoms & DTCs:"),
                  Text(
                    comp.failureSymptom(isArabic),
                    style: const TextStyle(fontSize: 12, color: AppColors.dangerRed),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Custom painter for AR Camera HUD viewfinder grid, corners, and radar scan
class _ArHudViewfinderPainter extends CustomPainter {
  final double radarSweepAngle;

  _ArHudViewfinderPainter({required this.radarSweepAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.electricBlue.withOpacity(0.08)
      ..strokeWidth = 1.0;

    // Background HUD grid
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Viewfinder 4 corner brackets
    final cornerPaint = Paint()
      ..color = AppColors.primaryYellow
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const cornerLen = 24.0;
    const margin = 20.0;

    // Top-left
    canvas.drawLine(const Offset(margin, margin), const Offset(margin + cornerLen, margin), cornerPaint);
    canvas.drawLine(const Offset(margin, margin), const Offset(margin, margin + cornerLen), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - cornerLen, margin), cornerPaint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + cornerLen), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + cornerLen, size.height - margin), cornerPaint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - cornerLen), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - cornerLen, size.height - margin), cornerPaint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - cornerLen), cornerPaint);

    // Dynamic rotating radar sweep line
    final center = Offset(size.width / 2, size.height / 2);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.electricBlue.withOpacity(0.0),
          AppColors.electricBlue.withOpacity(0.2),
        ],
        transform: GradientRotation(radarSweepAngle),
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.45));

    canvas.drawCircle(center, size.width * 0.4, sweepPaint);
  }

  @override
  bool shouldRepaint(covariant _ArHudViewfinderPainter oldDelegate) {
    return oldDelegate.radarSweepAngle != radarSweepAngle;
  }
}
