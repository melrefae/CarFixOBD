import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/wiring_schematic_models.dart';
import '../providers/obd_state.dart';

/// Screen offering interactive electrical wiring schematics, click-to-trace wire highlighting,
/// and ECU connector pinout multimeter probe test guide
class WiringSchematicsScreen extends StatefulWidget {
  const WiringSchematicsScreen({Key? key}) : super(key: key);

  @override
  State<WiringSchematicsScreen> createState() => _WiringSchematicsScreenState();
}

class _WiringSchematicsScreenState extends State<WiringSchematicsScreen> {
  final List<SchematicDiagram> _diagrams = SchematicDiagram.getAllDiagrams();
  int _selectedDiagramIndex = 0;
  String? _selectedComponentId;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final isAr = state.isArabic;
    final diagram = _diagrams[_selectedDiagramIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? "الدوائر الكهربائية وأطراف الفيش Pinouts" : "Interactive Wiring & Pinouts"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Wire Highlights",
            onPressed: () {
              setState(() {
                _selectedComponentId = null;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // System Selector Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select OEM Circuit Schematic:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    value: _selectedDiagramIndex,
                    dropdownColor: AppColors.cardSurface,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: List.generate(_diagrams.length, (i) {
                      final d = _diagrams[i];
                      return DropdownMenuItem(
                        value: i,
                        child: Text(
                          isAr ? d.titleAr : d.titleEn,
                          style: const TextStyle(fontSize: 12, color: AppColors.textWhite),
                        ),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedDiagramIndex = val;
                          _selectedComponentId = null;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Interactive Schematic Canvas Card
            Card(
              color: const Color(0xFF0F141A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
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
                        Text(
                          isAr ? "مخطط التوصيل التفاعلي (اضغط للمعاينة)" : "Interactive Vector Circuit (Tap to Trace)",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textWhite),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "${diagram.wires.length} Wires • ${diagram.components.length} Nodes",
                            style: const TextStyle(fontSize: 10, color: AppColors.primaryYellow, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Canvas Container
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF080C10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Stack(
                        children: [
                          // Vector Wire Painter
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _SchematicWirePainter(
                                wires: diagram.wires,
                                components: diagram.components,
                                selectedComponentId: _selectedComponentId,
                              ),
                            ),
                          ),
                          // Interactive Component Nodes
                          ...diagram.components.map((c) {
                            final isSelected = c.id == _selectedComponentId;
                            return Align(
                              alignment: Alignment(
                                (c.x * 2.0) - 1.0,
                                (c.y * 2.0) - 1.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedComponentId = isSelected ? null : c.id;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primaryYellow : const Color(0xFF1E262C),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : AppColors.cardBorder,
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: AppColors.primaryYellow.withOpacity(0.5), blurRadius: 10)]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        c.id,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: isSelected ? Colors.black : AppColors.textWhite,
                                        ),
                                      ),
                                      Text(
                                        c.typeName,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: isSelected ? Colors.black87 : AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Color Legend
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildLegendChip("12V Power", const Color(0xFFEF5350)),
                          const SizedBox(width: 8),
                          _buildLegendChip("Sensor Sig", const Color(0xFF29B6F6)),
                          const SizedBox(width: 8),
                          _buildLegendChip("Switched GND", const Color(0xFF66BB6A)),
                          const SizedBox(width: 8),
                          _buildLegendChip("O2 / CAN", const Color(0xFFFFCA28)),
                          const SizedBox(width: 8),
                          _buildLegendChip("LIN Bus", const Color(0xFFAB47BC)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // SECTION 2: ECU Multimeter Probe Test Guide
            Row(
              children: const [
                Icon(Icons.precision_manufacturing, size: 18, color: AppColors.accentCyan),
                SizedBox(width: 8),
                Text(
                  "ECU Pinout Multimeter Probe Guide",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.accentCyan),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...diagram.pinouts.map((pin) {
              return Card(
                color: AppColors.cardSurface,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryYellow.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primaryYellow),
                            ),
                            child: Text(
                              "PIN ${pin.pinNumber}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryYellow),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? pin.circuitNameAr : pin.circuitNameEn,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textWhite),
                                ),
                                Text(
                                  "${pin.connectorName} • Wire: ${pin.wireColor}",
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.cardBorder),
                      const SizedBox(height: 4),
                      _buildPinRow("Key ON (Ignition):", pin.keyOnVoltage, AppColors.electricBlue),
                      _buildPinRow("Engine Running:", pin.runningVoltage, AppColors.successGreen),
                      _buildPinRow("Resistance to Ground:", pin.resistanceToGround, AppColors.textWhite),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF151B20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, size: 14, color: AppColors.primaryYellow),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                isAr ? pin.probeInstructionAr : pin.probeInstructionEn,
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendChip(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildPinRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

/// Custom Painter for Schematic Circuit Wires
class _SchematicWirePainter extends CustomPainter {
  final List<SchematicWire> wires;
  final List<SchematicComponent> components;
  final String? selectedComponentId;

  _SchematicWirePainter({
    required this.wires,
    required this.components,
    this.selectedComponentId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final compMap = {for (final c in components) c.id: c};

    for (final wire in wires) {
      final from = compMap[wire.fromComponentId];
      final to = compMap[wire.toComponentId];
      if (from == null || to == null) continue;

      final startX = from.x * size.width;
      final startY = from.y * size.height;
      final endX = to.x * size.width;
      final endY = to.y * size.height;

      final isHighlighted = selectedComponentId != null &&
          (wire.fromComponentId == selectedComponentId || wire.toComponentId == selectedComponentId);

      final wirePaint = Paint()
        ..color = isHighlighted
            ? Color(wire.wireColorHex)
            : Color(wire.wireColorHex).withOpacity(0.4)
        ..strokeWidth = isHighlighted ? 3.5 : 1.8
        ..style = PaintingStyle.stroke;

      // Draw curved bezier connector path
      final path = Path();
      path.moveTo(startX, startY);
      final midX = (startX + endX) / 2;
      path.cubicTo(midX, startY, midX, endY, endX, endY);

      canvas.drawPath(path, wirePaint);

      if (isHighlighted) {
        // Draw glow aura
        final glowPaint = Paint()
          ..color = Color(wire.wireColorHex).withOpacity(0.3)
          ..strokeWidth = 8.0
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SchematicWirePainter oldDelegate) => true;
}
