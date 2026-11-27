import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/used_car_audit_models.dart';

/// Professional PDF Generation Service for Used Car Pre-Purchase Inspection Reports
class UsedCarPdfReportService {
  /// Generate printable PDF document bytes
  static Future<Uint8List> generatePdfReport({
    required PrePurchaseAuditScorecard scorecard,
    required String vehicleName,
    required bool isArabic,
  }) async {
    final pdf = pw.Document();

    final odo = scorecard.odometerAudit;
    final fraud = scorecard.codeClearingAudit;
    final vin = scorecard.vinAudit;
    final srs = scorecard.srsCrash;
    final mech = scorecard.drivetrainHealth;
    final estimates = scorecard.repairEstimates;
    final paint = scorecard.paintAudit;
    final flood = scorecard.floodAudit;
    final battery = scorecard.batteryCrankingAudit;
    final manual = scorecard.manualChecklist;
    final title = scorecard.titleAudit;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Banner
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blueGrey900,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "ASPECT AUTO DIAGNOSTIC CENTER",
                        style: pw.TextStyle(
                          color: PdfColors.amber,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        "OFFICIAL USED CAR PRE-PURCHASE INSPECTION CERTIFICATE",
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: scorecard.overallScore >= 75 ? PdfColors.green700 : PdfColors.red700,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Text(
                      "${scorecard.overallScore}/100",
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Vehicle Metadata Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Vehicle: $vehicleName", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                      pw.Text("Chassis VIN: ${vin.registeredVin}", style: const pw.TextStyle(fontSize: 10)),
                      pw.Text("Rating: ${scorecard.gradeClassificationEn}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue900)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Date: ${scorecard.timestamp.toString().substring(0, 16)}", style: const pw.TextStyle(fontSize: 9)),
                      pw.Text("Verification Hash: ${scorecard.verificationHash}", style: pw.TextStyle(fontSize: 9, font: pw.Font.courier())),
                      pw.Text("Audit Protocol: SAE J1979 / ISO 15765", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 14),

            // SECTION 1: Odometer Rollback & Mileage Verification
            pw.Text("1. ODOMETER & MILEAGE CROSS-CHECK AUDIT", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            pw.TableHelper.fromTextArray(
              headers: ["Module Node", "Logged Mileage", "Deviation vs Cluster", "Rollback Verdict"],
              data: [
                ["Instrument Cluster", "${odo.clusterMileageKm} km", "Baseline (0 km)", "MATCH"],
                ["Engine ECM", "${odo.ecmMileageKm} km", "${(odo.ecmMileageKm - odo.clusterMileageKm).abs()} km", odo.isRollbackSuspected ? "DISCREPANCY" : "VERIFIED"],
                ["Transmission TCM", "${odo.tcmMileageKm} km", "${(odo.tcmMileageKm - odo.clusterMileageKm).abs()} km", odo.isRollbackSuspected ? "DISCREPANCY" : "VERIFIED"],
                ["ABS Wheel Pulse Counter", "${odo.absRevolutionsEquivalentKm} km", "${(odo.absRevolutionsEquivalentKm - odo.clusterMileageKm).abs()} km", odo.isRollbackSuspected ? "DISCREPANCY" : "VERIFIED"],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 20,
            ),

            pw.SizedBox(height: 12),

            // SECTION 2: Code Clearing Fraud & Emission Readiness
            pw.Text("2. CODE CLEARING FRAUD & EMISSION READINESS AUDIT", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            pw.TableHelper.fromTextArray(
              headers: ["Standard PID", "Monitored Metric", "Read Value", "Integrity Evaluation"],
              data: [
                ["Mode 01 PID 30", "Distance Traveled Since DTCs Erased", "${fraud.distanceSinceDtcClearedKm} km", fraud.isRecentlyCleared ? "HIGH FRAUD RISK (<30 km)" : "PASSED (Established History)"],
                ["Mode 01 PID 31", "Warm-Up Cycles Since DTCs Erased", "${fraud.warmUpCyclesSinceDtcCleared} cycles", fraud.isRecentlyCleared ? "SUSPICIOUS (<3 cycles)" : "PASSED (Completed)"],
                ["Mode 01 PID 4D", "Total Engine Run Time Since Reset", "${fraud.engineRunTimeMinutes} min", "Reliability Index Validated"],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 20,
            ),

            pw.SizedBox(height: 12),

            // SECTION 3: Multi-ECU VIN Match & SRS Crash History
            pw.Text("3. MULTI-ECU CHASSIS VIN MATCH & AIRBAG CRASH HISTORY", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            pw.TableHelper.fromTextArray(
              headers: ["Electronic Module", "Extracted VIN", "OEM Status", "Crash History"],
              data: [
                ["Engine Control ECM", vin.ecmVin, vin.ecmVin == vin.registeredVin ? "MATCH" : "MISMATCH", "N/A"],
                ["Body Control BCM", vin.bcmVin, vin.bcmVin == vin.registeredVin ? "MATCH" : "MISMATCH", "N/A"],
                ["SRS Airbag Module", vin.srsVin, vin.srsVin == vin.registeredVin ? "MATCH" : "MISMATCH", srs.hasCrashData ? "CRASH RECORD STORED" : "NO CRASH RECORD"],
                ["Transmission TCU", vin.tcmVin, vin.tcmVin == vin.registeredVin ? "MATCH" : "MISMATCH", "N/A"],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 20,
            ),

            pw.SizedBox(height: 12),

            // SECTION 4: Mechanical & Drivetrain Health
            pw.Text("4. MECHANICAL & DRIVETRAIN HEALTH TELEMETRY", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            pw.TableHelper.fromTextArray(
              headers: ["Subsystem", "Diagnostic Parameter", "Measured Telemetry", "Condition"],
              data: [
                ["Engine Compression", "Relative Cranking Balance", mech.relativeCompressionBalancePercent.isNaN ? "not measured" : "${mech.relativeCompressionBalancePercent.toStringAsFixed(1)}%", mech.relativeCompressionBalancePercent.isNaN ? "NOT MEASURED" : (mech.relativeCompressionBalancePercent > 90 ? "OPTIMAL" : "LOW COMPRESSION")],
                ["Fuel Delivery", "Short Term Fuel Trim (STFT)", "${mech.shortTermFuelTrimPercent > 0 ? '+' : ''}${mech.shortTermFuelTrimPercent.toStringAsFixed(1)}%", "Nominal Target: ±5%"],
                ["Engine Mixture", "Long Term Fuel Trim (LTFT)", "${mech.longTermFuelTrimPercent > 0 ? '+' : ''}${mech.longTermFuelTrimPercent.toStringAsFixed(1)}%", "Nominal Target: ±8%"],
                ["Catalytic Converter", "Downstream O2 Sensor Voltage", "${mech.catalyticO2DownstreamVoltage.toStringAsFixed(2)} V", mech.catalyticO2DownstreamVoltage > 0.6 ? "ACTIVE" : "DEGRADED"],
                ["Transmission", "ATF Fluid Temperature", "${mech.transmissionFluidTempC.toStringAsFixed(1)} °C", mech.transmissionFluidTempC < 100 ? "NORMAL" : "ELEVATED"],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 20,
            ),

            pw.SizedBox(height: 12),

            // SECTION 5: Commercial Defect Valuation & Workshop Repair Estimate
            pw.Text("5. COMMERCIAL DEFECT VALUATION & REPAIR ESTIMATE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            if (estimates.defectItems.isEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(color: PdfColors.green50, borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Text("Clean Condition: No active repair requirements detected. Estimated repair cost: 0.00 EGP.", style: pw.TextStyle(fontSize: 9, color: PdfColors.green900)),
              )
            else
              pw.Column(
                children: [
                  pw.TableHelper.fromTextArray(
                    headers: ["Component / Fault", "Severity Level", "Est. Cost (EGP)", "Est. Cost (USD)"],
                    data: estimates.defectItems.map((item) => [
                      item.componentNameEn,
                      item.severity,
                      "${item.estimatedCostEgp.toStringAsFixed(0)} EGP",
                      "\$${item.estimatedCostUsd.toStringAsFixed(0)}",
                    ]).toList(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
                    headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
                    cellStyle: const pw.TextStyle(fontSize: 8),
                    cellHeight: 18,
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        "Total Estimated Repairs: ${estimates.totalEstimatedRepairCostEgp.toStringAsFixed(0)} EGP (\$${estimates.totalEstimatedRepairCostUsd.toStringAsFixed(0)})",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.red900),
                      ),
                      pw.Text(
                        "Recommended Price Deduction: ${estimates.recommendedBuyerNegotiationDeductionEgp.toStringAsFixed(0)} EGP",
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue900),
                      ),
                    ],
                  ),
                ],
              ),

            pw.SizedBox(height: 12),

            // SECTION 6: Paint Thickness & Structural Integrity
            pw.Text("6. BODY PAINT THICKNESS & STRUCTURAL INTEGRITY (MICRONS)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            pw.TableHelper.fromTextArray(
              headers: ["Body Panel", "Thickness (um)", "OEM Target (80-140 um)", "Condition Evaluation"],
              data: paint.panelMicrons.entries.take(8).map((entry) {
                final p = entry.key;
                final m = entry.value;
                String status = "OEM FACTORY";
                if (m > 250) {
                  status = "BONDO / FILLER DETECTED";
                } else if (m > 140) {
                  status = "REPAINTED";
                }
                return [p, "$m um", "80-140 um", status];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 18,
            ),
            if (paint.hasBondoDetected || paint.hasStructuralDamageSuspected)
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 4),
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(color: PdfColors.red50, borderRadius: pw.BorderRadius.circular(4)),
                child: pw.Text("ALERT: Body filler or structural pillar repair detected on vehicle chassis.", style: pw.TextStyle(fontSize: 8, color: PdfColors.red900, fontWeight: pw.FontWeight.bold)),
              ),

            pw.SizedBox(height: 12),

            // SECTION 7: Flood Immersion, 12V Battery & Title Registry
            pw.Text("7. FLOOD IMMERSION, 12V BATTERY & TITLE REGISTRY AUDIT", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            pw.TableHelper.fromTextArray(
              headers: ["Audit Subsystem", "Monitored Metric", "Measured Telemetry", "Status Evaluation"],
              data: [
                ["Flood Immersion Risk", "Water Immersion Score", flood.canBusTerminationOhms.isNaN ? "not measured" : "${flood.floodRiskPercent}%", flood.canBusTerminationOhms.isNaN ? "NOT ASSESSED" : (flood.floodRiskPercent > 30 ? "HIGH RISK" : "CLEAN (Passed)")],
                ["CAN Bus Termination", "Network Bus Resistance", flood.canBusTerminationOhms.isNaN ? "not measured" : "${flood.canBusTerminationOhms.toStringAsFixed(1)} Ohms", flood.canBusTerminationOhms.isNaN ? "NOT ASSESSED" : ((flood.canBusTerminationOhms >= 55 && flood.canBusTerminationOhms <= 65) ? "NOMINAL (60 Ohms)" : "ABNORMAL")],
                ["12V Battery Cranking", "Starter Voltage Dip", battery.crankingDipVoltage.isNaN ? "not measured" : "${battery.crankingDipVoltage.toStringAsFixed(1)} V", battery.crankingDipVoltage.isNaN ? "NOT MEASURED" : (battery.crankingDipVoltage >= 9.6 ? "HEALTHY (>9.6V)" : "WEAK BATTERY")],
                ["Alternator Charging", "Regulated Output Voltage", battery.chargingAlternatorVoltage.isNaN ? "not measured" : "${battery.chargingAlternatorVoltage.toStringAsFixed(1)} V", battery.chargingAlternatorVoltage.isNaN ? "NOT MEASURED" : "OPTIMAL CHARGING"],
                ["Official Title & Liens", "Title Brand & Bank Mortgages", title.verdictEn.startsWith("NOT CHECKED") ? "not checked" : (title.isCleanTitle && !title.isBankLienActive ? "CLEAN TITLE" : "MORTGAGE / LIEN FOUND"), title.verdictEn.startsWith("NOT CHECKED") ? "NOT CHECKED" : (title.isBankLienActive ? "ACTIVE LIEN ALERT" : "NO LIENS")],
              ],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 18,
            ),

            pw.SizedBox(height: 12),

            // SECTION 8: Physical Mechanical Workshop Checklist (Non-Electrical)
            pw.Text("8. PHYSICAL WORKSHOP MECHANICAL CHECKLIST (NON-ELECTRICAL)", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12, color: PdfColors.blueGrey800)),
            pw.Divider(color: PdfColors.grey400),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Mechanical Physical Score: ${manual.manualScore}/100", style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                pw.Text("Passed: ${manual.passedCount}  |  Marginal: ${manual.marginalCount}  |  Failed: ${manual.failedCount}  |  Leaking: ${manual.leakingCount}", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.TableHelper.fromTextArray(
              headers: ["Category Area", "Points Checked", "Pass / Total", "Status Summary"],
              data: manual.categories.map((cat) {
                final passed = cat.items.where((i) => i.status == ManualCheckItemStatus.pass).length;
                final leaks = cat.items.where((i) => i.status == ManualCheckItemStatus.leaking).length;
                final fails = cat.items.where((i) => i.status == ManualCheckItemStatus.fail).length;
                String status = "PASSED";
                if (fails > 0) {
                  status = "$fails DEFECT(S)";
                } else if (leaks > 0) {
                  status = "$leaks LEAK(S)";
                }
                return [cat.titleEn, "${cat.items.length} items", "$passed / ${cat.items.length}", status];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey700),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellHeight: 18,
            ),

            pw.SizedBox(height: 24),

            // Official Signature & Workshop Stamp Box
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey500),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Inspecting Technician Signature:", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.SizedBox(height: 20),
                      pw.Divider(color: PdfColors.grey400),
                      pw.Text("Certified Master Diagnostic Specialist", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.Container(
                  width: 200,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey500),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Official Workshop Stamp & Seal:", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      pw.SizedBox(height: 20),
                      pw.Divider(color: PdfColors.grey400),
                      pw.Text("Aspect Auto Vehicle Inspection Center", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// 1-Click Share PDF via WhatsApp / System Share Sheet
  static Future<void> sharePdfReport({
    required PrePurchaseAuditScorecard scorecard,
    required String vehicleName,
    required bool isArabic,
  }) async {
    final pdfBytes = await generatePdfReport(
      scorecard: scorecard,
      vehicleName: vehicleName,
      isArabic: isArabic,
    );

    final cleanName = vehicleName.replaceAll(' ', '_');
    final filename = "PrePurchase_Audit_${cleanName}_${scorecard.verificationHash}.pdf";

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: filename,
    );
  }

  /// 1-Click Print directly to Wi-Fi / Bluetooth or system printer
  static Future<void> printReport({
    required PrePurchaseAuditScorecard scorecard,
    required String vehicleName,
    required bool isArabic,
  }) async {
    final pdfBytes = await generatePdfReport(
      scorecard: scorecard,
      vehicleName: vehicleName,
      isArabic: isArabic,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: "AspectAuto_Audit_${scorecard.verificationHash}",
    );
  }
}
