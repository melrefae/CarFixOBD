import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings_en.dart';
import '../../domain/analyzers/fuel_economy_calculator.dart';
import '../providers/obd_state.dart';

/// Screen calculating real-time vehicle fuel consumption and Egyptian Pound (EGP) trip costs
class FuelCostCalculatorScreen extends StatefulWidget {
  const FuelCostCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<FuelCostCalculatorScreen> createState() => _FuelCostCalculatorScreenState();
}

class _FuelCostCalculatorScreenState extends State<FuelCostCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ObdState>(context);
    final fuel = state.fuelEconomy;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.fuelEconomyEgp),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset Trip Odometer",
            onPressed: () => setState(() => fuel.resetTrip()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fuel Grade Selector Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Egyptian Regulated Fuel Grade & Tariff:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFuelGradeChip(fuel, EgyptianFuelGrade.octane80, "80 Octane (13.75 EGP)"),
                      _buildFuelGradeChip(fuel, EgyptianFuelGrade.octane92, "92 Octane (15.25 EGP)"),
                      _buildFuelGradeChip(fuel, EgyptianFuelGrade.octane95, "95 Octane (17.00 EGP)"),
                      _buildFuelGradeChip(fuel, EgyptianFuelGrade.diesel, "Diesel Solar (13.50 EGP)"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Live Fuel Economy Hero Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF263238), Color(0xFF1E262C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  const Text("Instantaneous Fuel Consumption", style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  Text(
                    fuel.instantLitersPer100Km > 0
                        ? "${fuel.instantLitersPer100Km.toStringAsFixed(1)} L/100km"
                        : "${fuel.instantLitersPerHour.toStringAsFixed(1)} L/h (Idle)",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn("Avg Economy", "${fuel.averageLitersPer100Km.toStringAsFixed(1)} L/100km", AppColors.electricBlue),
                      _buildStatColumn("Efficiency", "${fuel.averageKmPerLiter.toStringAsFixed(1)} km/L", AppColors.accentCyan),
                      _buildStatColumn("Trip Distance", "${fuel.totalDistanceKm.toStringAsFixed(1)} km", AppColors.textWhite),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Egyptian Pound (EGP) Financial Trip Summary
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Trip Cost Breakdown (Egyptian Pounds):",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryYellow),
                  ),
                  const SizedBox(height: 14),
                  _buildCostRow("Fuel Tariff Selected:", "${fuel.pricePerLiter.toStringAsFixed(2)} EGP / Liter"),
                  _buildCostRow("Total Fuel Consumed:", "${fuel.totalFuelConsumedLiters.toStringAsFixed(2)} Liters"),
                  _buildCostRow("Cost Per Kilometer:", "${fuel.costPerKmEgp.toStringAsFixed(2)} EGP / km"),
                  const Divider(color: AppColors.cardBorder, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Trip Cost:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite)),
                      Text(
                        "${fuel.totalTripCostEgp.toStringAsFixed(2)} EGP",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.successGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFuelGradeChip(FuelEconomyCalculator fuel, EgyptianFuelGrade grade, String title) {
    final isSel = fuel.selectedGrade == grade;
    return ChoiceChip(
      label: Text(title),
      selected: isSel,
      selectedColor: AppColors.primaryYellow,
      backgroundColor: AppColors.backgroundDark,
      labelStyle: TextStyle(
        color: isSel ? Colors.black : AppColors.textWhite,
        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (_) => setState(() => fuel.selectedGrade = grade),
    );
  }

  Widget _buildStatColumn(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildCostRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
        ],
      ),
    );
  }
}
